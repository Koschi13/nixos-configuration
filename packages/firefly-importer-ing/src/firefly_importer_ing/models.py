"""The tables of the web app: what a user configures, and the tokens to act
as them in Firefly III. Nothing about an upload is stored, see `uploads`.

Every table but `users` belongs to one user and is deleted with them.
A change here needs a migration, see the README.
"""

from __future__ import annotations

from datetime import datetime

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    MetaData,
    Text,
    UniqueConstraint,
    func,
    true,
)
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from . import converter


def _one_of(column: str, values: tuple[str, ...]) -> str:
    """The SQL of a check that a text column holds one of the values."""
    return f"{column} IN ({', '.join(repr(value) for value in values)})"


class Base(DeclarativeBase):
    # Every constraint gets a predictable name, so that a migration can
    # change or drop it later
    metadata = MetaData(
        naming_convention={
            "ix": "ix_%(table_name)s_%(column_0_N_name)s",
            "uq": "uq_%(table_name)s_%(column_0_N_name)s",
            "ck": "ck_%(table_name)s_%(constraint_name)s",
            "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
            "pk": "pk_%(table_name)s",
        }
    )


def _owner() -> Mapped[int]:
    return mapped_column(ForeignKey("users.id", ondelete="CASCADE"))


class User(Base):
    """A Firefly III user who signed in. The client ID and the tokens are
    encrypted, see `crypto`."""

    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    firefly_user_id: Mapped[str] = mapped_column(Text, unique=True)
    email: Mapped[str] = mapped_column(Text)
    client_id_enc: Mapped[bytes]
    access_token_enc: Mapped[bytes | None]
    refresh_token_enc: Mapped[bytes | None]
    token_expires_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    last_login_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True)
    )


class BankAccount(Base):
    """Which Firefly III asset account the exports of an IBAN go to."""

    __tablename__ = "bank_accounts"
    __table_args__ = (UniqueConstraint("user_id", "iban"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = _owner()
    iban: Mapped[str] = mapped_column(Text)
    firefly_account_id: Mapped[int]
    name: Mapped[str] = mapped_column(Text, server_default="")


class PayeeRule(Base):
    """A `converter.Rule`. The rules of a user apply in `position` order."""

    __tablename__ = "payee_rules"
    __table_args__ = (
        CheckConstraint(_one_of("match", converter.MATCH_KINDS), name="match"),
        CheckConstraint(
            _one_of("field", converter.MATCH_FIELDS), name="field"
        ),
        Index(None, "user_id", "position"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = _owner()
    position: Mapped[int]
    match: Mapped[str] = mapped_column(Text)
    field: Mapped[str] = mapped_column(Text)
    pattern: Mapped[str] = mapped_column(Text)
    new_name: Mapped[str] = mapped_column(Text, server_default="")
    category: Mapped[str] = mapped_column(Text, server_default="")
    tags: Mapped[list[str]] = mapped_column(ARRAY(Text), server_default="{}")
    enabled: Mapped[bool] = mapped_column(server_default=true())


PROCESSOR_KINDS = ("visa_prefix", "girocard_payee")


class Processor(Base):
    """A payment processor whose name hides the actual payee."""

    __tablename__ = "processors"
    __table_args__ = (
        UniqueConstraint("user_id", "kind", "pattern"),
        CheckConstraint(_one_of("kind", PROCESSOR_KINDS), name="kind"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = _owner()
    kind: Mapped[str] = mapped_column(Text)
    pattern: Mapped[str] = mapped_column(Text)
    tag: Mapped[str] = mapped_column(Text, server_default="")


class Setting(Base):
    """A name of `converter.NAME_SETTINGS` that the user changed."""

    __tablename__ = "settings"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    key: Mapped[str] = mapped_column(Text, primary_key=True)
    value: Mapped[str] = mapped_column(Text)
