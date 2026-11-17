"""Split rules: divide one booking of the bank into several.

Revision ID: 0002
Revises: 0001
"""

import sqlalchemy as sa
from alembic import op

revision = "0002"
down_revision = "0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "split_rules",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column(
            "user_id",
            sa.Integer,
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("name", sa.Text, nullable=False, server_default=""),
        sa.Column("pattern", sa.Text, nullable=False),
        sa.Column(
            "enabled", sa.Boolean, nullable=False, server_default=sa.true()
        ),
    )
    op.create_index(
        op.f("ix_split_rules_user_id"), "split_rules", ["user_id"]
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_split_rules_user_id"), table_name="split_rules")
    op.drop_table("split_rules")
