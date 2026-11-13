"""Convert an ING "Umsatzanzeige" CSV export for the Firefly III importer.

* reads the Windows-1252 / semicolon / German-number export, skipping the
  metadata block (IBAN, Kontoname, Zeitraum, ...) before the column header
* repairs the "Verwendungszweck": the bank wraps it into 35-char lines and
  joins them with a space, which splits words ("Ei nkauf", "Gm bH", ...)
* splits the "Verwendungszweck" into its real parts: VISA payments, refunds,
  fees and cash withdrawals, Girocard payments, PayPal, everything else
* strips "VISA " (and processor prefixes like "SUMUP *") from the payee and
  records them as tags instead: VISA, Karte 2023, Apple Pay, SumUp, ...
* applies the payee rules: rename, category and extra tags
* writes a clean UTF-8 CSV with ISO dates and dot decimals, plus the matching
  importer JSON config

Everything here is pure: bytes in, rows and bytes out. The settings come
from the caller (the CLI uses the defaults, the web app the database).
"""

from __future__ import annotations

import calendar
import csv
import dataclasses
import hashlib
import io
import re
from collections import Counter
from datetime import date, datetime
from decimal import Decimal

INPUT_ENCODING = "cp1252"
WRAP_WIDTH = 35  # ING wraps the Verwendungszweck every 35 characters

# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------

MATCH_KINDS = ("regex", "contains", "exact")
MATCH_FIELDS = ("payee", "description")


@dataclasses.dataclass
class Rule:
    """A payee rule: the first enabled rule that matches wins.

    `field` is matched after the conversion, so `payee` sees the cleaned
    name ("LIDL SAGT DANKE", without "VISA "). Matching ignores case.
    """

    pattern: str
    new_name: str = ""
    match: str = "regex"
    field: str = "payee"
    category: str = ""
    tags: list[str] = dataclasses.field(default_factory=list)
    enabled: bool = True
    id: int | None = None

    def __post_init__(self) -> None:
        if self.match not in MATCH_KINDS:
            raise ValueError(f"unbekannte Vergleichsart {self.match!r}")
        if self.field not in MATCH_FIELDS:
            raise ValueError(f"unbekanntes Feld {self.field!r}")
        # Raises re.error for an invalid pattern, so it surfaces when saved
        self._regex = (
            re.compile(self.pattern, re.IGNORECASE)
            if self.match == "regex"
            else None
        )

    def matches(self, payee: str, description: str) -> bool:
        if not self.enabled:
            return False
        value = payee if self.field == "payee" else description
        if self._regex is not None:
            return bool(self._regex.search(value))
        if self.match == "contains":
            return self.pattern.casefold() in value.casefold()
        return self.pattern.casefold() == value.strip().casefold()


DEFAULT_RULES = [
    Rule(r"^LIDL\b", "Lidl"),
    Rule(r"^DM DROGERIE", "dm-drogerie markt"),
    Rule(r"^HORNBACH", "Hornbach"),
    Rule(r"^SPOTIFY\b", "Spotify"),
    Rule(r"^NETTO MARKEN-DISCOUNT", "Netto"),
    Rule(r"^JYSK\b", "JYSK"),
    Rule(r"^EBAY\b", "eBay"),
    Rule(r"^AMAZON (PAYMENTS EUROPE|EU S\.A R\.L\.)", "Amazon"),
    Rule(r"^Telefonica Germany", "Telefonica Germany"),
]

# Payment processors that prefix the merchant of a VISA payment:
# "SUMUP *MERCHANT" -> payee "MERCHANT", tag "SumUp"
DEFAULT_PROCESSORS = {
    "SUMUP": "SumUp",
    "PAYPAL": "PayPal",
    "SQ": "Square",
    "ZETTLE": "Zettle",
    "IZ": "Zettle",
    "STRIPE": "Stripe",
}

# Girocard payments where the payee column is the payment processor (or a
# placeholder) instead of the shop. The shop is taken from the purpose text
# then; a non-empty value is added as a tag.
DEFAULT_GIROCARD_PROCESSORS = {
    "SG-VR PAYMENT GMBH": "SG-VR Payment",
    "NEXI GERMANY GMBH": "Nexi",
    "LASTSCHRIFT AUS KARTENZAHLUNG": "",
}

# The names a user can change, with their defaults and a (German) label for
# the UI
NAME_SETTINGS = {
    "tag_visa": ("VISA", "Schlagwort für VISA-Kartenumsätze"),
    "tag_girocard": ("Girocard", "Schlagwort für Girocard-Zahlungen"),
    "tag_paypal": ("PayPal", "Schlagwort für PayPal-Zahlungen"),
    "tag_cash": ("Bargeld", "Schlagwort für Bargeldabhebungen"),
    "tag_fee": ("Gebühr", "Schlagwort für Kartengebühren"),
    "tag_foreign_currency": (
        "Fremdwährung",
        "Schlagwort für Zahlungen in Fremdwährung",
    ),
    "card_tag_format": (
        "Karte {card}",
        "Schlagwort je Karte, {card} = letzte vier Ziffern",
    ),
    "cash_opposing_name": (
        "Bargeld",
        "Empfänger von Bargeldabhebungen (z. B. dein Bargeldkonto)",
    ),
    "fee_opposing_name": ("ING", "Empfänger der Kartengebühren der Bank"),
}


def _upper_keys(mapping: dict[str, str]) -> dict[str, str]:
    return {key.strip().upper(): value for key, value in mapping.items()}


@dataclasses.dataclass
class ConverterSettings:
    tag_visa: str = NAME_SETTINGS["tag_visa"][0]
    tag_girocard: str = NAME_SETTINGS["tag_girocard"][0]
    tag_paypal: str = NAME_SETTINGS["tag_paypal"][0]
    tag_cash: str = NAME_SETTINGS["tag_cash"][0]
    tag_fee: str = NAME_SETTINGS["tag_fee"][0]
    tag_foreign_currency: str = NAME_SETTINGS["tag_foreign_currency"][0]
    card_tag_format: str = NAME_SETTINGS["card_tag_format"][0]
    cash_opposing_name: str = NAME_SETTINGS["cash_opposing_name"][0]
    fee_opposing_name: str = NAME_SETTINGS["fee_opposing_name"][0]
    processors: dict[str, str] = dataclasses.field(
        default_factory=lambda: dict(DEFAULT_PROCESSORS)
    )
    girocard_processors: dict[str, str] = dataclasses.field(
        default_factory=lambda: dict(DEFAULT_GIROCARD_PROCESSORS)
    )
    rules: list[Rule] = dataclasses.field(
        default_factory=lambda: list(DEFAULT_RULES)
    )

    def __post_init__(self) -> None:
        # Looked up once or twice per row: normalise the keys only once
        self.processors = _upper_keys(self.processors)
        self.girocard_processors = _upper_keys(self.girocard_processors)

    def card_tag(self, card: str) -> str:
        # replace, not format(): the format comes from the user
        return self.card_tag_format.replace("{card}", card)

    def processor(self, prefix: str) -> str | None:
        return self.processors.get(prefix.strip().upper())

    def girocard_processor(self, payee: str) -> str | None:
        return self.girocard_processors.get(payee.strip().upper())

    def rule_for(self, payee: str, description: str) -> Rule | None:
        return next(
            (rule for rule in self.rules if rule.matches(payee, description)),
            None,
        )


# ---------------------------------------------------------------------------
# Patterns
# ---------------------------------------------------------------------------

VISA_PAYEE = re.compile(r"^VISA\s+(?P<name>.+)$", re.IGNORECASE)
CASH_PAYEE = re.compile(
    r"^Bargeldauszahlung\s+VISA\s+Card\s+(?P<bank>.+)$", re.IGNORECASE
)

# NR XXXX 1111 MUSTERSTAD DE KAUFUMSATZ 06.11 24.33 120000 ARN1111... Apple Pay
# NR XXXX 2222 MUSTERDORF DE GUTSCHRIFTSBELEG 23.09 7.50 120000     (refund)
# NR XXXX 1111 MUSTERDORF DE GUTSCHRIFTSBELEG 14.04 8.79            (refund)
# NR XXXX 1111 SOFTWARE.C US KURS 1.1500000 KAUFUMSATZ 02.03 12.00 UHR
#   10.43 120000 ARN1111...                                (foreign currency)
VISA_PURPOSE = re.compile(
    r"^NR\s+XXXX\s+(?P<card>\d{4})\s+(?P<city>.+?)\s+(?P<country>[A-Z]{2})"
    r"(?:\s+KURS\s+(?P<rate>[\d.,]+))?\s+(?P<kind>[A-Z]{6,})\s+"
    r"(?P<day>\d{2})\.(?P<month>\d{2})\b\s*(?P<rest>.*?)"
    r"(?:\s*(?P<arn>ARN\d+)\s*(?P<wallet>.*))?$"
)
# "<amount> [<hhmmss>]" after the purchase date; anything else goes to notes
VISA_REST = re.compile(r"^(?P<amount>\d[\d.,]*)(?:\s+(?P<time>\d{6}))?$")

# VISA 1234 XXXX XXXX 1111 AUSLANDSEINSATZENTGELT VISA CARD (DEBITKARTE) ARN..
VISA_FEE = re.compile(
    r"^VISA\s+\d{4}\s+XXXX\s+XXXX\s+(?P<card>\d{4})\s+(?P<what>.+?)"
    r"\s*(?P<arn>ARN\d+)?$"
)

PROCESSOR_PREFIX = re.compile(r"^(?P<processor>[A-Z]+)\s*\*\s*(?P<name>.+)$")

# Girocard:
#   "<shop>[ GIR <terminal>]//<city>/<CC> <timestamp> Folgenr.<n>
#    Verfalld.<yyyy-mm>"
#   or "<shop>/<street>/<city>/<CC> <timestamp> ..."
# The tail is matched with all spaces removed, because the 35-char wrapping
# also cuts through the timestamp ("2026- 07-13", "Verfalld .2027").
GIROCARD_TAIL = re.compile(
    r"(?P<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})"
    r"(?:Folgenr\.(?P<sequence>\d+))?"
    r"(?:Verfalld\.(?P<expiry>\d{4}-\d{2}))?$"
)
GIROCARD_LOCATION = re.compile(r"^(?P<body>.+?)\s*/\s*(?P<country>[A-Z]{2})$")
GIROCARD_TERMINAL = re.compile(r"\s+G ?I ?R ?(?P<terminal>\d(?:[\d ]*\d)?)$")

# 1234567890123/PP.1234.PP/. Muster GmbH (Shop24), Ihr Einkauf bei
# Muster GmbH (Shop24)
PAYPAL_PURPOSE = re.compile(
    r"^(?P<reference>\d+)/PP\.\d+\.PP/\.\s*(?P<name>.*?)\s*,"
    r"\s*Ihr Einkauf bei\s*(?P<shop>.*)$"
)

OUTPUT_COLUMNS = [
    # (csv header, firefly importer role)
    ("date", "date_transaction"),  # Buchung - matches the bank statement
    ("interest_date", "date_interest"),  # Wertstellungsdatum (value date)
    ("payment_date", "date_payment"),  # card: purchase date, else Buchung
    ("amount", "amount"),
    ("currency", "currency-code"),
    ("opposing_name", "opposing-name"),
    ("description", "description"),
    ("tags", "tags-comma"),
    ("category", "category-name"),
    ("notes", "note"),
    ("external_id", "external-id"),
    ("internal_reference", "internal_reference"),
]

# Positional, because the header contains "Währung" twice.
INPUT_FIELDS = [
    "booking_date",  # Buchung
    "value_date",  # Wertstellungsdatum
    "payee",  # Auftraggeber/Empfänger
    "booking_text",  # Buchungstext
    "purpose",  # Verwendungszweck
    "reference",  # Referenz
    "balance",  # Saldo
    "balance_currency",  # Währung
    "amount",  # Betrag
    "currency",  # Währung
]


class ConversionError(ValueError):
    """An export that can't be converted. The message is shown to the user
    and therefore German, like every message and label in this module."""


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def parse_amount(value: str) -> Decimal:
    return Decimal(value.replace(".", "").replace(",", "."))


def parse_date(value: str) -> date:
    return datetime.strptime(value.strip(), "%d.%m.%Y").date()


def normalize_iban(value: str) -> str:
    return re.sub(r"\s+", "", value or "").upper()


def _splits_word(previous: str, following: str) -> bool:
    return following.islower() or (previous.isdigit() and following.isdigit())


def dewrap(text: str, width: int = WRAP_WIDTH, join=None) -> str:
    """Undo ING's fixed-width line wrapping.

    The bank cuts the text every `width` chars and joins the pieces with a
    space. That space is dropped when it obviously splits a word (next char
    is lowercase, or it sits between two digits); otherwise it is kept,
    because the line break may have been a real word boundary.

    `join(position, previous, following)` can override the decision;
    `position` is the index of the joining space in `text`.
    """
    if len(text) <= width:
        return text
    join = join or (
        lambda position, previous, following: _splits_word(previous, following)
    )
    pieces: list[str] = []
    position = 0
    while position < len(text):
        pieces.append(text[position : position + width])
        position += width
        if position < len(text) and text[position] == " ":
            previous = text[position - 1]
            following = text[position + 1 : position + 2]
            if not join(position, previous, following):
                pieces.append(" ")
            position += 1
    return "".join(pieces)


def parse_girocard(raw: str) -> dict[str, str] | None:
    """Split a Girocard purpose text, or return None if it isn't one."""
    kept = [
        position for position, character in enumerate(raw) if character != " "
    ]
    compact = "".join(raw[position] for position in kept)
    tail = GIROCARD_TAIL.search(compact)
    if not tail:
        return None
    head_raw = raw[: kept[tail.start()]].rstrip()
    if "/" not in head_raw:
        return None
    # Behind the first "/" there is only location data (street, city,
    # country), so any wrap-space there splits a word ("MA RKTOBERDORF").
    first_slash = head_raw.index("/")
    head = dewrap(
        head_raw,
        join=lambda position, previous, following: (
            position > first_slash or _splits_word(previous, following)
        ),
    )
    location = GIROCARD_LOCATION.match(head)
    if not location:
        return None
    body = location.group("body")
    if "//" in body:
        merchant, place = body.split("//", 1)
        street = ""
    else:
        parts = body.split("/")
        merchant, place = parts[0], parts[-1] if len(parts) > 1 else ""
        street = "/".join(parts[1:-1])
    terminal = ""
    terminal_match = GIROCARD_TERMINAL.search(merchant)
    if terminal_match:
        terminal = terminal_match.group("terminal").replace(" ", "")
        merchant = merchant[: terminal_match.start()]
    return {
        "merchant": merchant.strip(),
        "street": street.strip(),
        "place": re.sub(r"\s+", " ", place).strip(),
        "country": location.group("country"),
        "terminal": terminal,
        "timestamp": tail.group("timestamp"),
        "sequence": tail.group("sequence") or "",
        "expiry": tail.group("expiry") or "",
    }


def strip_reference(text: str, reference: str) -> str:
    """Remove the 'Referenz' (possibly with wrap-spaces in it) from text."""
    reference = reference.replace(" ", "")
    if not reference:
        return text
    pattern = r"\s?".join(re.escape(character) for character in reference)
    cleaned = re.sub(pattern, " ", text, count=1)
    return re.sub(r"\s{2,}", " ", cleaned).strip(" /,;-")


def infer_year(day: int, month: int, booked: date) -> date:
    """Purchase dates have no year. A purchase is never after its booking:
    take the booking year, or the year before if that would be later (a
    December purchase booked in January, a refund of an old purchase)."""
    try:
        candidate = date(booked.year, month, day)
    except ValueError:  # 29.02. in a year without it: the year before
        candidate = None
    if candidate is None or candidate > booked:
        return date(booked.year - 1, month, day)
    return candidate


def format_time(hhmmss: str) -> str:
    return f"{hhmmss[0:2]}:{hhmmss[2:4]}:{hhmmss[4:6]}"


def notes_block(items: list[tuple[str, str]]) -> str:
    return "\n".join(f"- {label}: {value}" for label, value in items if value)


# ---------------------------------------------------------------------------
# Row transformation
# ---------------------------------------------------------------------------


def transform(
    row: dict[str, str], raw_line: str, settings: ConverterSettings
) -> dict:
    """Convert one bank row. Keys starting with `_` are for display only and
    not written to the CSV."""
    payee = row["payee"].strip()
    text = row["booking_text"].strip()
    purpose_raw = row["purpose"].strip()
    reference = row["reference"].strip()
    booked = parse_date(row["booking_date"])
    valued = parse_date(row["value_date"])

    purchase_date: date | None = None  # card payments only
    opposing = payee
    description = ""
    tags: list[str] = []
    notes: list[tuple[str, str]] = [("Buchungstext", text)]
    external_id = reference
    kind = "other"

    visa_payee = VISA_PAYEE.match(payee)
    cash_payee = CASH_PAYEE.match(payee)
    visa = VISA_PURPOSE.match(purpose_raw)
    fee = VISA_FEE.match(purpose_raw)
    is_visa = bool(visa_payee or cash_payee or visa or fee)
    girocard = None if is_visa else parse_girocard(purpose_raw)

    if is_visa:
        # -------------------------------------------------------- VISA --
        kind = "visa"
        tags.append(settings.tag_visa)
        merchant = visa_payee.group("name").strip() if visa_payee else payee
        processor_match = PROCESSOR_PREFIX.match(merchant)
        processor_tag = (
            settings.processor(processor_match.group("processor"))
            if processor_match
            else None
        )
        if processor_match and processor_tag is not None:
            if processor_tag:
                tags.append(processor_tag)
            merchant = processor_match.group("name").strip()
        city = ""

        if fee:
            # Auslandseinsatzentgelt: charged by the bank for a foreign
            # purchase
            fee_parts = fee.groupdict()
            tags += [settings.card_tag(fee_parts["card"]), settings.tag_fee]
            external_id = reference or fee_parts["arn"] or ""
            notes += [
                ("Karte", f"XXXX {fee_parts['card']}"),
                ("Händler", merchant),
                ("ARN", fee_parts["arn"] or ""),
            ]
            opposing = settings.fee_opposing_name
            description = f"{fee_parts['what'].title()} - {merchant}"
        elif visa:
            visa_parts = visa.groupdict()
            tags.append(settings.card_tag(visa_parts["card"]))
            wallet = (visa_parts["wallet"] or "").strip()
            if wallet:
                tags.append(wallet)
            if visa_parts["rate"]:
                tags.append(settings.tag_foreign_currency)
            purchase_date = infer_year(
                int(visa_parts["day"]), int(visa_parts["month"]), booked
            )
            external_id = reference or visa_parts["arn"] or ""
            city = visa_parts["city"].strip()
            rest = visa_parts["rest"].strip()
            rest_match = VISA_REST.match(rest)
            time = (
                rest_match.group("time")
                if rest_match and rest_match.group("time")
                else ""
            )
            when = f"{purchase_date:%d.%m.%Y}"
            notes += [
                ("Karte", f"XXXX {visa_parts['card']}"),
                ("Art", visa_parts["kind"].title()),
                ("Ort", f"{city} ({visa_parts['country']})"),
                (
                    "Zeitpunkt",
                    when + (f" {format_time(time)}" if time else ""),
                ),
                (
                    "Betrag lt. Beleg",
                    rest_match.group("amount") if rest_match else "",
                ),
                ("Kurs", visa_parts["rate"] or ""),
                ("Details", "" if rest_match else rest),
                ("ARN", visa_parts["arn"] or ""),
                ("Wallet", wallet),
            ]
        else:
            notes.append(("Verwendungszweck", purpose_raw))

        if fee:
            pass
        elif cash_payee or (
            visa and visa.group("kind") == "BARGELDAUSZAHLUNG"
        ):
            tags.append(settings.tag_cash)
            bank = cash_payee.group("bank").strip() if cash_payee else merchant
            opposing = settings.cash_opposing_name
            description = f"Bargeldauszahlung {bank}" + (
                f" - {city}" if city else ""
            )
        else:
            opposing = merchant
            description = merchant + (f" - {city}" if city else "")
            if visa and visa.group("kind") == "GUTSCHRIFTSBELEG":
                description = f"Gutschrift {description}"

    elif girocard:
        # ---------------------------------------------------- Girocard --
        kind = "girocard"
        tags.append(settings.tag_girocard)
        processor_tag = settings.girocard_processor(payee)
        if processor_tag is not None:  # payee is a processor -> shop from text
            opposing = girocard["merchant"] or payee
            if processor_tag:
                tags.append(processor_tag)
        timestamp = datetime.fromisoformat(girocard["timestamp"])
        purchase_date = timestamp.date()
        description = girocard["merchant"] + (
            f" - {girocard['place']}" if girocard["place"] else ""
        )
        place = ", ".join(
            part for part in (girocard["street"], girocard["place"]) if part
        )
        notes += [
            ("Händler lt. Terminal", girocard["merchant"]),
            ("Terminal", girocard["terminal"]),
            ("Ort", f"{place} ({girocard['country']})"),
            ("Zeitpunkt", f"{timestamp:%d.%m.%Y %H:%M:%S}"),
            ("Folgenr.", girocard["sequence"]),
            ("Verfalldatum", girocard["expiry"]),
        ]

    else:
        purpose = dewrap(purpose_raw)
        paypal = PAYPAL_PURPOSE.match(purpose)

        if paypal:
            # -------------------------------------------------- PayPal --
            kind = "paypal"
            tags.append(settings.tag_paypal)
            shop = (paypal.group("shop") or paypal.group("name")).strip()
            if shop:
                opposing = shop
                description = f"PayPal-Einkauf bei {shop}"
            else:
                description = "PayPal-Zahlung"
            external_id = reference or paypal.group("reference")
            notes += [
                ("Zahlungsdienst", payee),
                ("Verwendungszweck", purpose),
            ]
        else:
            # ------------------------------------------------- generic --
            description = (
                strip_reference(purpose, reference) if reference else purpose
            )
            if description != purpose:
                notes.append(("Verwendungszweck", purpose))

    if not description:
        description = text or opposing

    if reference and reference != external_id:
        notes.append(("Referenz", reference))

    rule = settings.rule_for(opposing, description)
    category = ""
    if rule:
        opposing = rule.new_name or opposing
        category = rule.category
        tags += rule.tags

    return {
        "date": booked.isoformat(),
        "interest_date": valued.isoformat(),
        # never empty: the importer turns an empty date cell into *today*
        "payment_date": (purchase_date or booked).isoformat(),
        "amount": str(parse_amount(row["amount"])),
        "currency": row["currency"].strip() or "EUR",
        "opposing_name": opposing,
        "description": description,
        "tags": ",".join(dict.fromkeys(tag for tag in tags if tag)),
        "category": category,
        "notes": notes_block(notes),
        "external_id": external_id,
        # ING-<Buchung>-<fingerprint of the original bank line>: searchable
        # by date in Firefly III, and stable across overlapping exports.
        # The importer skips bookings whose reference it knows, so the
        # reference must not depend on what settings and rules make of the
        # booking
        "internal_reference": f"ING-{booked:%Y%m%d}-"
        + hashlib.sha256(raw_line.encode()).hexdigest()[:16],
        "_kind": kind,
        "_rule_id": rule.id if rule else None,
        "_rule": rule is not None,
        "_bank_payee": payee,
    }


# ---------------------------------------------------------------------------
# Reading the export
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class Export:
    metadata: dict[str, str]
    # (line number, row, raw line)
    lines: list[tuple[int, dict[str, str], str]]
    warnings: list[str] = dataclasses.field(default_factory=list)

    @property
    def iban(self) -> str:
        return normalize_iban(self.metadata.get("IBAN", ""))


def is_header(cells: list[str]) -> bool:
    return (
        len(cells) >= len(INPUT_FIELDS)
        and cells[0].strip() == "Buchung"
        and "Betrag" in cells
    )


def read_export(data: bytes) -> Export:
    """Parse the raw bytes of an ING export.

    A full export starts with a metadata block (IBAN, Kontoname, Zeitraum,
    Saldo, a notice ...) before the column header. Everything before the
    "Buchung;Wertstellungsdatum;..." line is collected as metadata and not
    imported. Files without that block (header on line 1) work as well.

    Raises ConversionError, also for bytes that aren't Windows-1252.
    """
    try:
        text = data.decode(INPUT_ENCODING)
    except UnicodeDecodeError as exc:
        raise ConversionError(
            f"Keine Textdatei in Windows-1252 ({exc.reason} bei Byte "
            f"{exc.start}). Ist das eine Umsatzanzeige-CSV der ING?"
        ) from exc
    reader = csv.reader(io.StringIO(text, newline=""), delimiter=";")
    metadata: dict[str, str] = {}
    for cells in reader:
        if is_header(cells):
            break
        if len(cells) >= 2 and cells[0].strip():
            metadata[cells[0].strip()] = ";".join(
                cell.strip() for cell in cells[1:]
            )
    else:
        raise ConversionError(
            "Keine Kopfzeile 'Buchung;Wertstellungsdatum;...' gefunden. "
            "Ist das eine Umsatzanzeige-CSV der ING?"
        )

    export = Export(metadata=metadata, lines=[])
    for cells in reader:
        line_number = reader.line_num
        if not any(cell.strip() for cell in cells):
            continue
        if len(cells) < len(INPUT_FIELDS):
            export.warnings.append(
                f"Zeile {line_number}: {len(cells)} Spalten, übersprungen"
            )
            continue
        export.lines.append(
            (line_number, dict(zip(INPUT_FIELDS, cells)), ";".join(cells))
        )
    return export


def convert(export: Export, settings: ConverterSettings) -> list[dict]:
    seen: Counter[str] = Counter()
    rows = []
    for line_number, row, raw_line in export.lines:
        # identical raw lines (should not happen thanks to the balance
        # column) still get distinct internal references
        seen[raw_line] += 1
        key = (
            raw_line if seen[raw_line] == 1 else f"{raw_line}#{seen[raw_line]}"
        )
        try:
            rows.append(transform(row, key, settings))
        except Exception as exc:
            raise ConversionError(
                f"Zeile {line_number}: {exc}\n{raw_line}"
            ) from exc
    return rows


# ---------------------------------------------------------------------------
# Import window
# ---------------------------------------------------------------------------


def parse_user_date(text: str, *, end: bool) -> date:
    """Parse a day (31.10.2026, 2026-10-31) or a month (10.2026, 2026-10).

    A month resolves to its first day for the start and its last day for the
    stop, so "10.2026" for both imports exactly October.
    """
    text = text.strip()
    for date_format in ("%d.%m.%Y", "%Y-%m-%d", "%d.%m.%y"):
        try:
            return datetime.strptime(text, date_format).date()
        except ValueError:
            pass
    for date_format in ("%m.%Y", "%Y-%m", "%m/%Y"):
        try:
            first_day = datetime.strptime(text, date_format).date()
        except ValueError:
            continue
        return month_end(first_day) if end else first_day
    raise ValueError(
        f"Das Datum {text!r} ist nicht lesbar (möglich sind 31.10.2026,"
        " 2026-10-31 oder 10.2026)"
    )


def month_end(day: date) -> date:
    return day.replace(day=calendar.monthrange(day.year, day.month)[1])


@dataclasses.dataclass
class Month:
    year: int
    month: int
    first: date
    last: date
    count: int
    hint: str = ""

    @property
    def start(self) -> date:
        return date(self.year, self.month, 1)

    @property
    def stop(self) -> date:
        return month_end(self.start)


def month_overview(
    dates: list[date], today: date | None = None
) -> list[Month]:
    """Which booking dates a file covers, month by month."""
    today = today or date.today()
    groups: dict[tuple[int, int], list[date]] = {}
    for day in sorted(dates):
        groups.setdefault((day.year, day.month), []).append(day)
    months = []
    for index, ((year, month), days) in enumerate(groups.items()):
        hint = ""
        if (year, month) == (today.year, today.month):
            hint = "laufender Monat, noch nicht abgeschlossen"
        elif index == 0 and days[0].day > 1:
            hint = "erster Monat im Export, möglicherweise unvollständig"
        months.append(Month(year, month, days[0], days[-1], len(days), hint))
    return months


def booking_dates(rows: list[dict]) -> list[date]:
    return [date.fromisoformat(row["date"]) for row in rows]


def filter_window(rows: list[dict], start: date, stop: date) -> list[dict]:
    """Filter on the booking date (= Firefly transaction date): the export is
    complete per booking date, so consecutive windows never miss a
    transaction, and a window shows up in Firefly exactly as selected."""
    return [
        row for row in rows if start <= date.fromisoformat(row["date"]) <= stop
    ]


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------


def to_csv(rows: list[dict]) -> bytes:
    buffer = io.StringIO(newline="")
    writer = csv.DictWriter(
        buffer,
        fieldnames=[column for column, _ in OUTPUT_COLUMNS],
        quoting=csv.QUOTE_MINIMAL,
        lineterminator="\n",
        extrasaction="ignore",
    )
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue().encode("utf-8")


def build_config(account_id: int) -> dict:
    roles = [role for _, role in OUTPUT_COLUMNS]
    return {
        "version": 3,
        "source": "ff3-importer-ing-preprocessor",
        "created_at": datetime.now()
        .astimezone()
        .isoformat(timespec="seconds"),
        "flow": "file",
        "content_type": "csv",
        "date": "Y-m-d",
        "default_account": account_id,
        "delimiter": "comma",
        "headers": True,
        "conversion": False,
        "rules": True,
        "skip_form": False,
        "add_import_tag": True,
        "custom_tag": "",
        "roles": roles,
        "do_mapping": [role == "opposing-name" for role in roles],
        "mapping": {},
        "duplicate_detection_method": "cell",
        "ignore_duplicate_lines": True,
        # required by the v3 schema; the importer only sets it true for
        # "classic"
        "ignore_duplicate_transactions": False,
        "unique_column_index": roles.index("internal_reference"),
        "unique_column_type": "internal_reference",
    }
