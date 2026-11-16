"""driver ledger

Revision ID: 0007
Revises: 0006
Create Date: 2026-11-16 21:20:24.030831
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "0007"
down_revision: str | None = "0006"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "driver_ledger",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("driver_id", sa.String(length=64), nullable=False),
        sa.Column("ride_id", sa.Uuid(), nullable=False),
        sa.Column("payment_method", sa.String(length=16), nullable=False),
        sa.Column("gross", sa.Integer(), nullable=False),
        sa.Column("commission_percent", sa.Integer(), nullable=False),
        sa.Column("commission", sa.Integer(), nullable=False),
        sa.Column("net", sa.Integer(), nullable=False),
        sa.Column("cash_collected", sa.Boolean(), nullable=False),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("settled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["driver_id"], ["users.id"], name=op.f("fk_driver_ledger_driver_id_users")
        ),
        sa.ForeignKeyConstraint(
            ["ride_id"], ["rides.id"], name=op.f("fk_driver_ledger_ride_id_rides")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_driver_ledger")),
        sa.UniqueConstraint("ride_id", name=op.f("uq_driver_ledger_ride_id")),
    )
    op.create_index(
        "ix_driver_ledger_driver_completed",
        "driver_ledger",
        ["driver_id", "completed_at"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index("ix_driver_ledger_driver_completed", table_name="driver_ledger")
    op.drop_table("driver_ledger")
