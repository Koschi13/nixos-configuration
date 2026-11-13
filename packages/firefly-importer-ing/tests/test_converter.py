import csv
import io
import re
from datetime import date

import pytest
import sample
from firefly_importer_ing import converter


def convert(*keys, settings=None):
    export = converter.read_export(sample.export(*keys))
    return converter.convert(export, settings or converter.ConverterSettings())


def one(key, settings=None):
    (row,) = convert(key, settings=settings)
    return row


def tags(row):
    return row["tags"].split(",") if row["tags"] else []


# --- reading -----------------------------------------------------------


def test_metadata_block_is_skipped():
    export = converter.read_export(sample.export())
    assert export.iban == "DE00123456789012345678"
    assert export.metadata["Kontoname"] == "Girokonto"
    assert len(export.lines) == len(sample.LINES)


def test_file_without_metadata_block():
    export = converter.read_export(sample.export("visa", header=False))
    assert export.metadata == {}
    assert len(export.lines) == 1


def test_not_an_ing_export():
    with pytest.raises(converter.ConversionError):
        converter.read_export(b"a;b;c\n1;2;3\n")


def test_bytes_that_are_not_windows_1252():
    # 0x81 has no character in Windows-1252
    with pytest.raises(converter.ConversionError, match="Windows-1252"):
        converter.read_export(b"Buchung;\x81\n")


def test_cli_reports_unreadable_files(tmp_path, monkeypatch, capsys):
    from firefly_importer_ing import cli

    binary = tmp_path / "export.csv"
    binary.write_bytes(b"\x81\x8d\x8f")
    for path, message in (
        (binary, "Diese Datei lässt sich nicht lesen"),
        (tmp_path / "missing.csv", "lässt sich nicht lesen"),
    ):
        monkeypatch.setattr("sys.argv", ["ing-to-firefly", str(path), "-y"])
        with pytest.raises(SystemExit) as exit_info:
            cli.main()
        assert message in str(exit_info.value.code)


# --- VISA --------------------------------------------------------------


def test_visa_payment():
    row = one("visa")
    assert row["opposing_name"] == "CAFE BEISPIEL"
    assert row["description"] == "CAFE BEISPIEL - MUSTERSTADT"
    assert tags(row) == ["VISA", "SumUp", "Karte 1111", "Apple Pay"]
    assert row["date"] == "2026-11-10"
    assert row["payment_date"] == "2026-11-08"
    assert row["amount"] == "-17.00"
    assert row["external_id"] == "ARN11111111111111111111111"
    assert "- Zeitpunkt: 08.11.2026 12:31:27" in row["notes"]


def test_visa_refund_without_time_and_arn():
    row = one("refund")
    assert row["description"] == "Gutschrift BAUMARKT BEISPIEL - BEISPIELORT"
    assert tags(row) == ["VISA", "Karte 2222"]
    assert row["payment_date"] == "2026-09-23"
    assert row["interest_date"] == "2026-09-24"
    assert row["amount"] == "7.50"


def test_visa_foreign_currency():
    row = one("fx")
    assert "Fremdwährung" in tags(row)
    assert "- Kurs: 1.1500000" in row["notes"]
    assert "- Details: 12.00 UHR 10.43 120000" in row["notes"]


def test_visa_fee():
    row = one("fee")
    assert row["opposing_name"] == "ING"
    assert tags(row) == ["VISA", "Karte 1111", "Gebühr"]
    assert row["description"].startswith("Auslandseinsatzentgelt")
    assert "- Händler: SOFTWARE INC" in row["notes"]


def test_visa_cash_withdrawal():
    row = one("cash")
    assert row["opposing_name"] == "Bargeld"
    assert row["description"] == ("Bargeldauszahlung MUSTERBANK - MUSTERSTADT")
    assert tags(row) == ["VISA", "Karte 2222", "Bargeld"]


def test_purchase_is_never_after_its_booking():
    infer_year = converter.infer_year
    # a refund of last year's purchase, booked earlier in the same month
    assert infer_year(20, 11, date(2026, 11, 5)) == date(2025, 11, 20)
    assert infer_year(5, 11, date(2026, 11, 5)) == date(2026, 11, 5)
    assert infer_year(30, 12, date(2026, 1, 2)) == date(2025, 12, 30)
    assert infer_year(29, 2, date(2029, 1, 10)) == date(2028, 2, 29)


def test_purchase_in_december_booked_in_january():
    row = one("new_year")
    assert row["date"] == "2026-01-02"
    assert row["payment_date"] == "2025-12-30"
    assert row["interest_date"] == "2025-12-31"


# --- Girocard ----------------------------------------------------------


def test_girocard_wrapped_timestamp():
    row = one("giro")
    assert row["opposing_name"] == "EDEKA Beispiel"
    assert row["description"] == "EDEKA BEISPIEL - BEISPIELHAUSEN"
    assert tags(row) == ["Girocard"]
    assert row["payment_date"] == "2026-07-13"
    assert "- Zeitpunkt: 13.07.2026 14:14:05" in row["notes"]
    assert "- Verfalldatum: 2027-12" in row["notes"]


def test_girocard_with_street():
    row = one("giro_street")
    assert row["description"] == "DM Drogerie - Beispielstadt"
    assert "- Ort: Musterstrasse 11, Beispielstadt (DE)" in row["notes"]
    # the default rule for "DM DROGERIE…" renames the payee
    assert row["opposing_name"] == "dm-drogerie markt"


def test_girocard_processor_payee_and_wrapped_terminal():
    row = one("giro_processor")
    assert row["opposing_name"] == "BAECKEREI KONDITOREI BEISPL 9006"
    assert tags(row) == ["Girocard", "Nexi"]
    assert "- Terminal: 12345678" in row["notes"]
    assert row["payment_date"] == "2026-05-19"


# --- others ------------------------------------------------------------


def test_paypal():
    row = one("paypal")
    assert row["opposing_name"] == "Muster GmbH (Shop24)"
    assert row["description"] == "PayPal-Einkauf bei Muster GmbH (Shop24)"
    assert tags(row) == ["PayPal"]
    assert row["external_id"] == "1234567890123"


def test_reference_is_stripped_from_description():
    row = one("generic")
    assert row["description"] == "Beispielweg 4 Strom Abschlag"
    assert row["external_id"] == "S/123456789012/987654321098"


def test_wrapping_is_undone():
    assert one("wrapped")["description"] == (
        "Kd.Nr. 001234567890 VK 1234567890 Rg.Nr. 009876543210 vom "
        "24.10.26 Mobilfunk sagt Danke"
    )


def test_dates_of_a_transfer():
    row = one("transfer")
    assert row["date"] == "2026-11-02"
    assert row["interest_date"] == "2026-11-01"
    assert row["payment_date"] == "2026-11-02"
    assert row["amount"] == "1200.00"


def test_dewrap_keeps_real_word_boundaries():
    text = sample.wrap(
        "123456789012 MUSTER FAEL.V.12.10.26 -12.10.2027 "
        "BAHNHOFSTRASSE 4, 12345 MUSTERHAUSEN"
    )
    assert "12345 MUSTERHAUSEN" in converter.dewrap(text)


# --- rules ---------------------------------------------------------------


def settings_with(*rules):
    return converter.ConverterSettings(rules=list(rules))


def test_rule_renames_and_adds_category_and_tags():
    row = one(
        "visa",
        settings_with(
            converter.Rule(
                r"^CAFE", "Café Beispiel", category="Essen", tags=["x"]
            )
        ),
    )
    assert row["opposing_name"] == "Café Beispiel"
    assert row["category"] == "Essen"
    assert tags(row)[-1] == "x"
    assert row["_rule"]


def test_rule_match_kinds_and_fields():
    payee, description = "CAFE BEISPIEL", "Strom Abschlag"
    assert converter.Rule("cafe beispiel", match="exact").matches(payee, "")
    assert not converter.Rule("cafe", match="exact").matches(payee, "")
    assert converter.Rule("FE BEI", match="contains").matches(payee, "")
    assert converter.Rule(
        "strom", match="contains", field="description"
    ).matches(payee, description)
    assert not converter.Rule("^cafe", enabled=False).matches(payee, "")


def test_first_matching_rule_wins():
    row = one(
        "visa",
        settings_with(
            converter.Rule("^CAFE", "first"), converter.Rule("CAFE", "second")
        ),
    )
    assert row["opposing_name"] == "first"


def test_invalid_regex_is_refused():
    with pytest.raises(re.error):
        converter.Rule("([")


def test_processor_names_ignore_case():
    settings = converter.ConverterSettings(
        processors={"sumup ": "SumUp"},
        girocard_processors={"nexi germany gmbh": "Nexi"},
    )
    assert settings.processor("SumUp") == "SumUp"
    assert settings.girocard_processor(" NEXI Germany GmbH") == "Nexi"
    assert tags(one("visa", settings))[:2] == ["VISA", "SumUp"]


def test_custom_names():
    settings = converter.ConverterSettings(
        tag_visa="Kreditkarte", card_tag_format="Card {card} {card}"
    )
    assert tags(one("visa", settings))[:1] == ["Kreditkarte"]
    assert "Card 1111 1111" in tags(one("visa", settings))


# --- window and output ---------------------------------------------------


def test_parse_user_date():
    assert converter.parse_user_date("10.2026", end=False) == date(2026, 10, 1)
    assert converter.parse_user_date("2026-02", end=True) == date(2026, 2, 28)
    assert converter.parse_user_date("31.10.2026", end=True) == date(
        2026, 10, 31
    )
    with pytest.raises(ValueError):
        converter.parse_user_date("soon", end=False)


def test_window_filters_on_booking_date():
    rows = convert()
    october = converter.filter_window(
        rows, date(2026, 10, 1), date(2026, 10, 31)
    )
    assert {row["date"][:7] for row in october} == {"2026-10"}


def test_month_overview():
    months = converter.month_overview(
        [date(2026, 10, 12), date(2026, 10, 30), date(2026, 11, 2)],
        today=date(2026, 11, 12),
    )
    assert [(month.month, month.count) for month in months] == [
        (10, 2),
        (11, 1),
    ]
    assert "möglicherweise unvollständig" in months[0].hint
    assert "noch nicht abgeschlossen" in months[1].hint


def test_internal_reference_is_stable_and_unique():
    first_run, second_run = convert(), convert()
    references = [row["internal_reference"] for row in first_run]
    assert references == [row["internal_reference"] for row in second_run]
    assert len(set(references)) == len(references)
    assert references[0].startswith("ING-20261110-")


def test_internal_reference_ignores_the_settings():
    """The importer recognises a booking by its reference, so a user who
    changes rules or names must still get the same one."""
    changed = converter.ConverterSettings(
        tag_visa="Kreditkarte",
        cash_opposing_name="Geldbeutel",
        processors={},
        girocard_processors={},
        rules=[
            converter.Rule(
                ".", new_name="Umbenannt", category="Alles", tags=["neu"]
            )
        ],
    )
    renamed = convert(settings=changed)
    assert {row["opposing_name"] for row in renamed} == {"Umbenannt"}
    assert [row["internal_reference"] for row in renamed] == [
        row["internal_reference"] for row in convert()
    ]


def test_identical_lines_get_distinct_references():
    data = sample.export("visa", "visa")
    rows = converter.convert(
        converter.read_export(data), converter.ConverterSettings()
    )
    assert rows[0]["internal_reference"] != rows[1]["internal_reference"]


def test_csv_and_config_fit_together():
    rows = convert()
    out = list(csv.DictReader(io.StringIO(converter.to_csv(rows).decode())))
    assert len(out) == len(rows)
    assert "_kind" not in out[0]
    config = converter.build_config(3)
    assert list(out[0]) == [column for column, _ in converter.OUTPUT_COLUMNS]
    assert config["roles"][config["unique_column_index"]] == (
        "internal_reference"
    )
    assert config["default_account"] == 3
    assert config["ignore_duplicate_transactions"] is False
