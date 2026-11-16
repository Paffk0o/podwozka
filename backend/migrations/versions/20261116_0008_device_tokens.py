"""device tokens

Revision ID: 0008
Revises: 0007
Create Date: 2026-11-16 22:09:40.958673
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "0008"
down_revision: str | None = "0007"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "device_tokens",
        sa.Column("token", sa.String(length=4096), nullable=False),
        sa.Column("user_id", sa.String(length=64), nullable=False),
        sa.Column("platform", sa.String(length=16), nullable=False),
        sa.Column("app", sa.String(length=16), nullable=False),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name=op.f("fk_device_tokens_user_id_users"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("token", name=op.f("pk_device_tokens")),
    )
    op.create_index(op.f("ix_device_tokens_user_id"), "device_tokens", ["user_id"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_device_tokens_user_id"), table_name="device_tokens")
    op.drop_table("device_tokens")
