"""The Alembic environment: how migrations reach the database.

The URL comes from the configuration `db.migration_config` builds, or, when
the `alembic` command is run during development, from `DATABASE_URL`.
"""

import os

from alembic import context
from firefly_importer_ing.models import Base
from sqlalchemy import create_engine, pool

url = (
    context.config.get_main_option("sqlalchemy.url")
    or os.environ["DATABASE_URL"]
)

if context.is_offline_mode():
    # `alembic upgrade --sql`: print the statements instead of running them
    context.configure(url=url, target_metadata=Base.metadata)
    with context.begin_transaction():
        context.run_migrations()
else:
    engine = create_engine(url, poolclass=pool.NullPool)
    with engine.connect() as connection:
        context.configure(connection=connection, target_metadata=Base.metadata)
        with context.begin_transaction():
            context.run_migrations()
    engine.dispose()
