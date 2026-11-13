"""The Alembic migrations against a real PostgreSQL."""

import sqlalchemy
from alembic.autogenerate import compare_metadata
from alembic.migration import MigrationContext
from conftest import DATABASE_URL, needs_database
from firefly_importer_ing import db
from firefly_importer_ing.models import Base

pytestmark = needs_database


def _tables(engine) -> set[str]:
    return set(sqlalchemy.inspect(engine).get_table_names())


def test_migrations_run_up_and_down(empty_database):
    db.upgrade(DATABASE_URL)
    assert _tables(empty_database) == {
        "alembic_version",
        *Base.metadata.tables,
    }
    db.downgrade(DATABASE_URL, "base")
    assert _tables(empty_database) == {"alembic_version"}
    db.upgrade(DATABASE_URL)


def test_migrations_create_what_the_models_describe(empty_database):
    """Fails when `models.py` was changed without adding a migration."""
    db.upgrade(DATABASE_URL)
    with empty_database.connect() as connection:
        context = MigrationContext.configure(connection)
        assert compare_metadata(context, Base.metadata) == []
