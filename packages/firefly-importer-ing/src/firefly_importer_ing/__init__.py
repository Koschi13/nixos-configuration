"""Convert ING exports and import them into Firefly III."""

import sys

__version__ = "0.1.0"


def serve() -> None:
    """`firefly-importer-ing-serve [gunicorn options]`: run the web app."""
    from gunicorn.app.wsgiapp import run

    sys.argv = [
        "gunicorn",
        *sys.argv[1:],
        "firefly_importer_ing.web:create_app()",
    ]
    run()


def migrate() -> None:
    """`firefly-importer-ing-migrate`: bring the schema of `DATABASE_URL` up
    to date. Run before the web app starts."""
    import os

    from . import db

    db.upgrade(os.environ["DATABASE_URL"])
