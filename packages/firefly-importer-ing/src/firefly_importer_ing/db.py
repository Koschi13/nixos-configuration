"""PostgreSQL storage: the queries of the web app and the schema migrations.

Every table but `users` belongs to one user, so each query takes the
`user_id` of the signed-in user and users never see each other's data.

`DATABASE_URL` is an SQLAlchemy URL of the psycopg driver, e.g.
`postgresql+psycopg:///firefly-importer-ing?host=/run/postgresql`.
"""

from __future__ import annotations

from datetime import datetime
from pathlib import Path

import sqlalchemy
from alembic import command
from alembic.config import Config
from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from . import converter
from .models import BankAccount, PayeeRule, Processor, Setting, User

MIGRATIONS = Path(__file__).parent / "migrations"


def create_engine(url: str) -> sqlalchemy.Engine:
    """The connection pool of an app. `pool_pre_ping` replaces connections
    that a restart of PostgreSQL closed."""
    return sqlalchemy.create_engine(url, pool_pre_ping=True)


# ---------------------------------------------------------------------------
# Migrations
# ---------------------------------------------------------------------------


def migration_config(url: str) -> Config:
    """The Alembic configuration of a database, without an `alembic.ini`:
    the migrations are part of the installed package."""
    config = Config()
    config.set_main_option("script_location", str(MIGRATIONS))
    config.set_main_option("sqlalchemy.url", url.replace("%", "%%"))
    return config


def upgrade(url: str, revision: str = "head") -> None:
    """Migrate the schema up to a revision."""
    command.upgrade(migration_config(url), revision)


def downgrade(url: str, revision: str) -> None:
    """Migrate the schema back to a revision (`base`: an empty database)."""
    command.downgrade(migration_config(url), revision)


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------


def list_users(session: Session, user_ids: list[int]) -> list[User]:
    """The profiles with these IDs, most recently used first."""
    return list(
        session.scalars(
            select(User)
            .where(User.id.in_(user_ids))
            .order_by(User.last_login_at.desc().nulls_last(), User.email)
        )
    )


def get_user(
    session: Session, user_id: int, *, lock: bool = False
) -> User | None:
    """`lock` rereads the row and holds it until the transaction ends, so
    that only one request at a time refreshes the user's tokens."""
    return session.get(
        User, user_id, with_for_update=lock, populate_existing=lock
    )


def upsert_user(
    session: Session,
    *,
    firefly_user_id: str,
    email: str,
    client_id_enc: bytes,
    access_token_enc: bytes,
    refresh_token_enc: bytes | None,
    token_expires_at: datetime | None,
) -> tuple[User, bool]:
    """Store a sign-in. Returns the user and whether they are new."""
    user = session.scalar(
        select(User).where(User.firefly_user_id == firefly_user_id)
    )
    created = user is None
    if created:
        user = User(firefly_user_id=firefly_user_id)
        session.add(user)
    user.email = email
    user.client_id_enc = client_id_enc
    user.access_token_enc = access_token_enc
    user.refresh_token_enc = refresh_token_enc
    user.token_expires_at = token_expires_at
    user.last_login_at = func.now()
    session.flush()  # assigns the ID of a new user
    return user, created


def delete_user(session: Session, user_id: int) -> None:
    """Delete a user and, by the foreign keys, everything they own."""
    session.execute(delete(User).where(User.id == user_id))


def seed_defaults(session: Session, user_id: int) -> None:
    """The starting rules and processors of a new user."""
    for position, rule in enumerate(converter.DEFAULT_RULES, start=1):
        session.add(
            PayeeRule(
                user_id=user_id,
                position=position,
                match=rule.match,
                field=rule.field,
                pattern=rule.pattern,
                new_name=rule.new_name,
                category=rule.category,
                tags=rule.tags,
            )
        )
    for kind, mapping in (
        ("visa_prefix", converter.DEFAULT_PROCESSORS),
        ("girocard_payee", converter.DEFAULT_GIROCARD_PROCESSORS),
    ):
        for pattern, tag in mapping.items():
            add_processor(session, user_id, kind, pattern, tag)


def _delete_owned(session: Session, model, user_id: int, row_id: int) -> None:
    """Delete a row by its ID, if it belongs to the user."""
    session.execute(
        delete(model).where(model.id == row_id, model.user_id == user_id)
    )


# ---------------------------------------------------------------------------
# Converter settings
# ---------------------------------------------------------------------------


def list_rules(session: Session, user_id: int) -> list[PayeeRule]:
    return list(
        session.scalars(
            select(PayeeRule)
            .where(PayeeRule.user_id == user_id)
            .order_by(PayeeRule.position, PayeeRule.id)
        )
    )


def _converter_rule(rule: PayeeRule) -> converter.Rule:
    return converter.Rule(
        pattern=rule.pattern,
        new_name=rule.new_name,
        match=rule.match,
        field=rule.field,
        category=rule.category,
        tags=list(rule.tags),
        enabled=rule.enabled,
        id=rule.id,
    )


def add_rule(session: Session, user_id: int, values: dict) -> None:
    """Append a rule. `values` are the columns a user can set."""
    last = session.scalar(
        select(func.max(PayeeRule.position)).where(
            PayeeRule.user_id == user_id
        )
    )
    session.add(PayeeRule(user_id=user_id, position=(last or 0) + 1, **values))


def update_rule(
    session: Session, user_id: int, rule_id: int, values: dict
) -> None:
    rule = session.scalar(
        select(PayeeRule).where(
            PayeeRule.id == rule_id, PayeeRule.user_id == user_id
        )
    )
    if rule is None:
        return
    for column, value in values.items():
        setattr(rule, column, value)


def delete_rule(session: Session, user_id: int, rule_id: int) -> None:
    _delete_owned(session, PayeeRule, user_id, rule_id)


def move_rule(
    session: Session, user_id: int, rule_id: int, direction: int
) -> None:
    """Swap the rule with its neighbour (-1 = up, +1 = down)."""
    rules = list_rules(session, user_id)
    ids = [rule.id for rule in rules]
    if rule_id not in ids:
        return
    current = ids.index(rule_id)
    target = current + direction
    if not 0 <= target < len(rules):
        return
    rules[current], rules[target] = rules[target], rules[current]
    for position, rule in enumerate(rules, start=1):
        rule.position = position


def list_processors(session: Session, user_id: int) -> list[Processor]:
    return list(
        session.scalars(
            select(Processor)
            .where(Processor.user_id == user_id)
            .order_by(Processor.kind, Processor.pattern)
        )
    )


def add_processor(
    session: Session, user_id: int, kind: str, pattern: str, tag: str
) -> None:
    """Add a processor, or change the tag of the one with that pattern."""
    pattern = pattern.strip().upper()
    processor = session.scalar(
        select(Processor).where(
            Processor.user_id == user_id,
            Processor.kind == kind,
            Processor.pattern == pattern,
        )
    )
    if processor is None:
        processor = Processor(user_id=user_id, kind=kind, pattern=pattern)
        session.add(processor)
    processor.tag = tag.strip()


def delete_processor(
    session: Session, user_id: int, processor_id: int
) -> None:
    _delete_owned(session, Processor, user_id, processor_id)


def get_names(session: Session, user_id: int) -> dict[str, str]:
    """The name settings, defaults filled in."""
    names = {
        key: default for key, (default, _) in converter.NAME_SETTINGS.items()
    }
    for setting in session.scalars(
        select(Setting).where(Setting.user_id == user_id)
    ):
        if setting.key in names:
            names[setting.key] = setting.value
    return names


def set_names(session: Session, user_id: int, names: dict[str, str]) -> None:
    for key, value in names.items():
        if key in converter.NAME_SETTINGS:
            session.merge(Setting(user_id=user_id, key=key, value=value))


def load_settings(
    session: Session, user_id: int
) -> converter.ConverterSettings:
    processors = list_processors(session, user_id)
    return converter.ConverterSettings(
        **get_names(session, user_id),
        processors={
            processor.pattern: processor.tag
            for processor in processors
            if processor.kind == "visa_prefix"
        },
        girocard_processors={
            processor.pattern: processor.tag
            for processor in processors
            if processor.kind == "girocard_payee"
        },
        rules=[_converter_rule(rule) for rule in list_rules(session, user_id)],
    )


# ---------------------------------------------------------------------------
# Bank accounts
# ---------------------------------------------------------------------------


def list_bank_accounts(session: Session, user_id: int) -> list[BankAccount]:
    return list(
        session.scalars(
            select(BankAccount)
            .where(BankAccount.user_id == user_id)
            .order_by(BankAccount.iban)
        )
    )


def get_bank_account(
    session: Session, user_id: int, iban: str
) -> BankAccount | None:
    return session.scalar(
        select(BankAccount).where(
            BankAccount.user_id == user_id, BankAccount.iban == iban
        )
    )


def save_bank_account(
    session: Session,
    user_id: int,
    iban: str,
    firefly_account_id: int,
    name: str,
) -> None:
    """Assign an IBAN to a Firefly III account, replacing an assignment."""
    account = get_bank_account(session, user_id, iban)
    if account is None:
        account = BankAccount(user_id=user_id, iban=iban)
        session.add(account)
    account.firefly_account_id = firefly_account_id
    account.name = name


def delete_bank_account(
    session: Session, user_id: int, account_id: int
) -> None:
    _delete_owned(session, BankAccount, user_id, account_id)
