"""A synthetic ING export: made-up people, shops and IBANs, in the formats
the real exports use. No real bank data belongs in this repository."""

from __future__ import annotations

IBAN = "DE00 1234 5678 9012 3456 78"
WRAP = 35


def wrap(text: str) -> str:
    """Wrap like ING: cut every 35 characters, join with a space."""
    return " ".join(
        text[start : start + WRAP] for start in range(0, len(text), WRAP)
    )


HEADER_BLOCK = [
    "Umsatzanzeige;Datei erstellt am: 12.11.2026 13:25",
    "",
    f"IBAN;{IBAN}",
    "Kontoname;Girokonto",
    "Bank;ING",
    "Kunde;Erika Mustermann",
    "Zeitraum;01.12.2025 - 12.11.2026",
    "Saldo;1.000,00;EUR",
    "",
    "Sortierung;Datum absteigend",
    "",
    "In der CSV-Datei finden Sie alle bereits gebuchten Umsätze.",
    "",
]
COLUMNS = (
    "Buchung;Wertstellungsdatum;Auftraggeber/Empfänger;Buchungstext;"
    "Verwendungszweck;Referenz;Saldo;Währung;Betrag;Währung"
)


def line(
    booked: str,
    payee: str,
    text: str,
    purpose: str,
    amount: str,
    *,
    valued: str | None = None,
    ref: str = "",
    balance: str = "1.000,00",
) -> str:
    return ";".join(
        [
            booked,
            valued or booked,
            payee,
            text,
            purpose,
            ref,
            balance,
            "EUR",
            amount,
            "EUR",
        ]
    )


LINES = {
    "visa": line(
        "10.11.2026",
        "VISA SUMUP *CAFE BEISPIEL",
        "Lastschrift",
        "NR XXXX 1111 MUSTERSTADT DE KAUFUMSATZ 08.11 17.00 123127 "
        "ARN11111111111111111111111 Apple Pay",
        "-17,00",
        balance="983,00",
    ),
    "refund": line(
        "25.09.2026",
        "VISA BAUMARKT BEISPIEL",
        "Gutschrift",
        "NR XXXX 2222 BEISPIELORT DE GUTSCHRIFTSBELEG 23.09 7.50",
        "7,50",
        valued="24.09.2026",
        balance="990,50",
    ),
    "fx": line(
        "04.03.2026",
        "VISA SOFTWARE INC",
        "Lastschrift",
        "NR XXXX 1111 SOFTWARE.C US KURS 1.1500000 KAUFUMSATZ 02.03 12.00 "
        "UHR 10.43 120000 ARN22222222222222222222222",
        "-14,99",
        balance="985,01",
    ),
    "fee": line(
        "04.03.2026",
        "VISA SOFTWARE INC",
        "Entgelt",
        "VISA 1234 XXXX XXXX 1111 AUSLANDSEINSATZENTGELT VISA CARD "
        "(DEBITKARTE) ARN22222222222222222222222",
        "-0,33",
        balance="984,68",
    ),
    "cash": line(
        "13.10.2026",
        "Bargeldauszahlung VISA Card MUSTERBANK",
        "Lastschrift",
        "NR XXXX 2222 MUSTERSTADT DE BARGELDAUSZAHLUNG 10.10 100.00 145403 "
        "ARN33333333333333333333333",
        "-100,00",
        valued="12.10.2026",
        balance="884,68",
    ),
    "giro": line(
        "15.07.2026",
        "EDEKA Beispiel",
        "Lastschrift",
        wrap(
            "EDEKA BEISPIEL//BEISPIELHAUSEN/DE 2026-07-13T14:14:05 "
            "Folgenr.000 Verfalld.2027-12"
        ),
        "-3,60",
        ref="11111111111111111111111111",
        balance="881,08",
    ),
    "giro_street": line(
        "30.07.2026",
        "DM DROGERIEMARKT SAGT DANKE",
        "Lastschrift",
        wrap(
            "DM Drogerie/Musterstrasse 11/Beispielstadt/DE "
            "2026-07-29T10:34:27 Folgenr.000 Verfalld.2027-12"
        ),
        "-12,95",
        balance="868,13",
    ),
    "giro_processor": line(
        "20.05.2026",
        "Nexi Germany GmbH",
        "Lastschrift",
        wrap(
            "BAECKEREI KONDITOREI BEISPL 9006 GIR 12345678//MUSTERDORF/DE "
            "2026-05-19T12:56:09 Folgenr.000 Verfalld.2027-12"
        ),
        "-12,15",
        balance="856,00",
    ),
    "paypal": line(
        "28.10.2026",
        "PayPal Europe S.a.r.l. et Cie S.C.A",
        "Lastschrift",
        wrap(
            "1234567890123/PP.1234.PP/. Muster GmbH (Shop24), Ihr Einkauf "
            "bei Muster GmbH (Shop24)"
        ),
        "-71,03",
        ref="1234567890123",
        balance="784,97",
    ),
    "generic": line(
        "05.11.2026",
        "STADTWERKE BEISPIEL",
        "Lastschrift",
        wrap("S/123456789012/987654321098 Beispielweg 4 Strom Abschlag"),
        "-67,00",
        ref="S/123456789012/987654321098",
        balance="717,97",
    ),
    "wrapped": line(
        "03.11.2026",
        "Mobilfunk GmbH",
        "Lastschrift",
        wrap(
            "Kd.Nr. 001234567890 VK 1234567890 Rg.Nr. 009876543210 vom "
            "24.10.26 Mobilfunk sagt Danke"
        ),
        "-19,99",
        ref="123456789012",
        balance="697,98",
    ),
    "new_year": line(
        "02.01.2026",
        "VISA LIDL SAGT DANKE",
        "Lastschrift",
        "NR XXXX 2222 BEISPIELORT DE KAUFUMSATZ 30.12 20.00 101010 "
        "ARN44444444444444444444444 Google Pay",
        "-20,00",
        valued="31.12.2025",
        balance="677,98",
    ),
    "transfer": line(
        "02.11.2026",
        "Max Mustermann",
        "Gutschrift Echtzeitüberweisung",
        "Haushaltsgeld",
        "1.200,00",
        valued="01.11.2026",
        balance="1.877,98",
    ),
}


def export(*keys: str, header: bool = True) -> bytes:
    keys = keys or tuple(LINES)
    rows = [LINES[key] for key in keys]
    lines = (HEADER_BLOCK if header else []) + [COLUMNS] + rows + [""]
    return "\n".join(lines).encode("cp1252")
