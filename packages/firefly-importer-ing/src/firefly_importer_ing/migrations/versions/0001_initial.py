"""The initial schema: users and what they configure.

Revision ID: 0001
Revises:
"""

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None


def _owner() -> sa.Column:
    return sa.Column(
        "user_id",
        sa.Integer,
        sa.ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("firefly_user_id", sa.Text, nullable=False, unique=True),
        sa.Column("email", sa.Text, nullable=False),
        sa.Column("client_id_enc", sa.LargeBinary, nullable=False),
        sa.Column("access_token_enc", sa.LargeBinary),
        sa.Column("refresh_token_enc", sa.LargeBinary),
        sa.Column("token_expires_at", sa.DateTime(timezone=True)),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("last_login_at", sa.DateTime(timezone=True)),
    )
    op.create_table(
        "bank_accounts",
        sa.Column("id", sa.Integer, primary_key=True),
        _owner(),
        sa.Column("iban", sa.Text, nullable=False),
        sa.Column("firefly_account_id", sa.Integer, nullable=False),
        sa.Column("name", sa.Text, nullable=False, server_default=""),
        sa.UniqueConstraint("user_id", "iban"),
    )
    op.create_table(
        "payee_rules",
        sa.Column("id", sa.Integer, primary_key=True),
        _owner(),
        sa.Column("position", sa.Integer, nullable=False),
        sa.Column("match", sa.Text, nullable=False),
        sa.Column("field", sa.Text, nullable=False),
        sa.Column("pattern", sa.Text, nullable=False),
        sa.Column("new_name", sa.Text, nullable=False, server_default=""),
        sa.Column("category", sa.Text, nullable=False, server_default=""),
        sa.Column(
            "tags",
            postgresql.ARRAY(sa.Text),
            nullable=False,
            server_default="{}",
        ),
        sa.Column(
            "enabled", sa.Boolean, nullable=False, server_default=sa.true()
        ),
        sa.CheckConstraint(
            "match IN ('regex', 'contains', 'exact')", name="match"
        ),
        sa.CheckConstraint("field IN ('payee', 'description')", name="field"),
    )
    op.create_index(
        op.f("ix_payee_rules_user_id_position"),
        "payee_rules",
        ["user_id", "position"],
    )
    op.create_table(
        "processors",
        sa.Column("id", sa.Integer, primary_key=True),
        _owner(),
        sa.Column("kind", sa.Text, nullable=False),
        sa.Column("pattern", sa.Text, nullable=False),
        sa.Column("tag", sa.Text, nullable=False, server_default=""),
        sa.UniqueConstraint("user_id", "kind", "pattern"),
        sa.CheckConstraint(
            "kind IN ('visa_prefix', 'girocard_payee')", name="kind"
        ),
    )
    op.create_table(
        "settings",
        sa.Column(
            "user_id",
            sa.Integer,
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            primary_key=True,
        ),
        sa.Column("key", sa.Text, primary_key=True),
        sa.Column("value", sa.Text, nullable=False),
    )


def downgrade() -> None:
    op.drop_table("settings")
    op.drop_table("processors")
    op.drop_table("payee_rules")
    op.drop_table("bank_accounts")
    op.drop_table("users")
