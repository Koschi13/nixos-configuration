"""`ing-to-firefly`: convert an ING export on the command line.

    ing-to-firefly Umsatzanzeige_....csv [--account-id 1]
        [-o out.csv] [-c firefly_import_config.json]
        [--start DATE] [--stop DATE] [-y]

DATE accepts 31.10.2026, 2026-10-31, or a whole month: 10.2026 / 2026-10
(start -> first day of that month, stop -> last day of that month).

Uses the built-in default settings; the rules of the web app live in its
database. Like the web app it talks German to the user.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path

from . import converter


def print_overview(dates: list[date]) -> None:
    first, last = min(dates), max(dates)
    print(
        f"\nBuchungsdaten in der Datei: {first:%d.%m.%Y} - {last:%d.%m.%Y}"
        f" ({len(dates)} Buchungen)"
    )
    for month in converter.month_overview(dates):
        hint = f"  <- {month.hint}" if month.hint else ""
        print(
            f"  {month.year}-{month.month:02d}"
            f"  {month.first:%d.%m.} - {month.last:%d.%m.}"
            f"  {month.count:3d} Buchungen{hint}"
        )
    print(
        "Datum: 31.10.2026, 2026-10-31 oder ein Monat wie 10.2026."
        " Enter = Vorgabe.\n"
    )


def ask_date(label: str, default: date, *, end: bool) -> date:
    while True:
        try:
            answer = input(f"{label} [{default:%d.%m.%Y}]: ")
        except (EOFError, KeyboardInterrupt):
            print()
            sys.exit("Abgebrochen.")
        if not answer.strip():
            return default
        try:
            return converter.parse_user_date(answer, end=end)
        except ValueError as exc:
            print(f"  {exc}")


def choose_window(
    dates: list[date], args: argparse.Namespace
) -> tuple[date, date]:
    first, last = min(dates), max(dates)
    try:
        start = (
            converter.parse_user_date(args.start, end=False)
            if args.start
            else None
        )
        stop = (
            converter.parse_user_date(args.stop, end=True)
            if args.stop
            else None
        )
    except ValueError as exc:
        sys.exit(str(exc))
    interactive = (
        not args.yes and sys.stdin.isatty() and (start is None or stop is None)
    )

    if interactive:
        print_overview(dates)
    while True:
        chosen_start = start or (
            ask_date("Beginn", first, end=False) if interactive else first
        )
        chosen_stop = stop or (
            ask_date("Ende  ", last, end=True) if interactive else last
        )
        if chosen_start <= chosen_stop:
            return chosen_start, chosen_stop
        problem = (
            f"Der Beginn {chosen_start:%d.%m.%Y} liegt nach dem Ende"
            f" {chosen_stop:%d.%m.%Y}"
        )
        if not interactive:
            sys.exit(f"{problem}.")
        print(f"  {problem}, bitte noch einmal.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Wandelt eine Umsatzanzeige-CSV der ING für den Data "
        "Importer von Firefly III um."
    )
    parser.add_argument("input", type=Path, help="Umsatzanzeige-CSV der ING")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Ausgabe-CSV (Vorgabe: <input>_firefly.csv)",
    )
    parser.add_argument(
        "-c",
        "--config",
        type=Path,
        help="JSON für den Importer (Vorgabe: firefly_import_config.json)",
    )
    parser.add_argument(
        "--account-id",
        type=int,
        default=1,
        help="ID des Firefly-Bestandskontos zu diesem Bankkonto (Vorgabe: 1)",
    )
    parser.add_argument(
        "--start", help="erstes Buchungsdatum des Imports (statt Nachfrage)"
    )
    parser.add_argument(
        "--stop", help="letztes Buchungsdatum des Imports (statt Nachfrage)"
    )
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="nicht nachfragen: ohne --start/--stop die ganze Datei nehmen",
    )
    args = parser.parse_args()

    output_csv = args.output or args.input.with_name(
        args.input.stem + "_firefly.csv"
    )
    output_config = args.config or args.input.with_name(
        "firefly_import_config.json"
    )

    settings = converter.ConverterSettings()
    try:
        data = args.input.read_bytes()
    except OSError as exc:
        sys.exit(f"{args.input} lässt sich nicht lesen: {exc.strerror}")
    try:
        export = converter.read_export(data)
        rows = converter.convert(export, settings)
    except converter.ConversionError as exc:
        sys.exit(f"Diese Datei lässt sich nicht lesen: {exc}")
    for warning in export.warnings:
        print(f"WARNUNG {warning}", file=sys.stderr)
    if export.metadata:
        info = ", ".join(
            f"{key}: {export.metadata[key]}"
            for key in ("IBAN", "Kontoname", "Zeitraum")
            if key in export.metadata
        )
        print(f"ING-Export - {info}")

    if not rows:
        sys.exit("Keine Buchungen gefunden.")

    dates = converter.booking_dates(rows)
    start, stop = choose_window(dates, args)
    total = len(rows)
    rows = converter.filter_window(rows, start, stop)
    before = sum(day < start for day in dates)
    after = sum(day > stop for day in dates)
    print(
        f"Zeitraum {start:%d.%m.%Y} - {stop:%d.%m.%Y}: {len(rows)} von"
        f" {total} Buchungen ({before} davor, {after} danach übersprungen)"
    )
    if not rows:
        sys.exit(
            "In diesem Zeitraum gibt es nichts zu importieren; es wurden"
            " keine Dateien geschrieben."
        )

    output_csv.write_bytes(converter.to_csv(rows))
    output_config.write_text(
        json.dumps(
            converter.build_config(args.account_id),
            indent=4,
            ensure_ascii=False,
        )
        + "\n",
        encoding="utf-8",
    )

    visa = sum(settings.tag_visa in row["tags"].split(",") for row in rows)
    print(f"{len(rows)} Buchungen ({visa} VISA) -> {output_csv}")
    print(
        f"Konfiguration für den Importer -> {output_config}"
        f"  (default_account={args.account_id})"
    )


if __name__ == "__main__":
    main()
