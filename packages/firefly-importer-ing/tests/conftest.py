"""A PostgreSQL database for the tests that need one, which they may wipe:
`TEST_DATABASE_URL` (an SQLAlchemy URL), or the libpq environment (PGHOST,
...) that `postgresqlTestHook` sets in the Nix build. Without one those
tests are skipped."""

import os

import pytest
import sqlalchemy
from sqlalchemy import text

DATABASE_URL = os.environ.get("TEST_DATABASE_URL", "postgresql+psycopg://")


def _database_available() -> bool:
    if not (os.environ.get("TEST_DATABASE_URL") or os.environ.get("PGHOST")):
        return False
    engine = sqlalchemy.create_engine(DATABASE_URL)
    try:
        engine.connect().close()
    except sqlalchemy.exc.OperationalError:
        return False
    finally:
        engine.dispose()
    return True


needs_database = pytest.mark.skipif(
    not _database_available(), reason="no PostgreSQL for these tests"
)


@pytest.fixture
def empty_database():
    """An engine for the test database, without any tables."""
    engine = sqlalchemy.create_engine(DATABASE_URL)
    with engine.begin() as connection:
        connection.execute(text("DROP SCHEMA public CASCADE"))
        connection.execute(text("CREATE SCHEMA public"))
    yield engine
    engine.dispose()
