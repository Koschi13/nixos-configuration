# firefly-importer-ing

> [!WARNING]
> This service was entirely written by AI with minimal reviewing.
> It's intended to run locally and isn't guaranteed to work nor to be safe.

Converts ING "Umsatzanzeige" CSV exports for the
[Firefly III data importer](https://docs.firefly-iii.org/how-to/data-importer/about/)
and imports them.

- Splits the Verwendungszweck into payee, description, notes and dates
  (booking, value date, purchase date).
- Tags card payments (`VISA`, `Karte 1234`, `Girocard`, Apple Pay, SumUp, …).
- Applies payee rules: rename, category, extra tags.

It ships two commands: a CLI and a web service.

## CLI

```sh
ing-to-firefly Umsatzanzeige_….csv [--account-id 1] [--start 10.2026] [--stop 10.2026] [-y]
```

Writes `<input>_firefly.csv` and `firefly_import_config.json` for a manual
upload to the importer. Without `--start`/`--stop` it asks for the window.
It uses the built-in default rules.

## Web service

`firefly-importer-ing-serve [gunicorn options]` runs the Flask app, after
`firefly-importer-ing-migrate` brought the database schema up to date. On
fabricator it is set up by `modules/services/firefly-importer-ing [N]` at
`http://firefly-ing.lan`.

How it works:

1. Sign in with Firefly III.
2. Upload the export, pick the period and check the preview.
3. Send it. The service uploads it to the importer's `/autoupload` and then
   checks in Firefly III what arrived.

What is stored, per user in PostgreSQL: the profile with its (encrypted)
OAuth client ID and tokens, rules, processors, tag names and the assignments
of IBANs to Firefly III accounts (`models.py`).

What is not stored: anything about an upload. The export, its bookings and
the result of the check stay in the memory of the process (`uploads.py`),
one upload per user, until it is discarded, replaced, unused for an hour or
the service restarts. There is no import history. Sending the same bookings
again is harmless: the importer skips those whose internal reference it
knows, and that reference is built from the unchanged line of the export.

Because of that the app must run in **one worker process**
(`--workers 1 --worker-class gthread --threads 8`); a second worker would
not know the uploads of the first.

Configuration comes from the environment:

| Variable             | Meaning                                                  |
| -------------------- | -------------------------------------------------------- |
| `DATABASE_URL`       | SQLAlchemy URL, `postgresql+psycopg://…`                 |
| `FIREFLY_URL`        | Firefly III as reached by the service                    |
| `FIREFLY_VANITY_URL` | Firefly III as reached by the browser (default: `FIREFLY_URL`) |
| `IMPORTER_URL`       | the data importer                                        |
| `PUBLIC_URL`         | this service as reached by the browser                   |
| `SECRET_KEY`         | ≥ 32 characters; encrypts client IDs and tokens          |
| `AUTO_IMPORT_SECRET` | the importer's `AUTO_IMPORT_SECRET`                      |

The two secrets can also be given as `*_FILE` or as systemd credentials
`secret-key` and `auto-import-secret`.

The importer needs `CAN_POST_FILES=true` and an `AUTO_IMPORT_SECRET` of at
least 16 characters.

**One-time setup per user:** in Firefly III, create an OAuth client under
*Profile → OAuth*:

- *Confidential* unticked,
- redirect URL `<PUBLIC_URL>/oauth/callback`.

Enter its client ID on the sign-in page.

## Development

```sh
nix build .#firefly-importer-ing   # builds the CSS, runs all tests
```

Locally, in the devshell of the repository (`nix develop`, or direnv),
which provides uv:

```sh
uv run --extra test pytest
```

The web and migration tests need a PostgreSQL database they may wipe, set
in `TEST_DATABASE_URL` (an SQLAlchemy URL); without one they are skipped.

### Changing the database schema

The schema is defined by the SQLAlchemy models in `models.py` and created by
the Alembic migrations in `src/firefly_importer_ing/migrations/versions`.
After changing a model, let Alembic write the migration against a database
that is at the current head, then review it:

```sh
export DATABASE_URL=postgresql+psycopg:///some-scratch-database
uv run alembic upgrade head
uv run alembic revision --autogenerate -m "what changed"
```

`alembic downgrade -1` takes the last migration back. A test fails when the
models and the migrations disagree.

Tests use synthetic data only (`tests/sample.py`). Never add real bank
exports.
