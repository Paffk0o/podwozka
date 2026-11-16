"""ride offers

Revision ID: 0006
Revises: 0005
Create Date: 2026-11-16 18:34:33.955640
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "0006"
down_revision: str | None = "0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "ride_offers",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ride_id", sa.Uuid(), nullable=False),
        sa.Column("driver_id", sa.String(length=64), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("pickup_distance_m", sa.Integer(), nullable=False),
        sa.Column("pickup_eta_s", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("responded_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(
            ["driver_id"], ["users.id"], name=op.f("fk_ride_offers_driver_id_users")
        ),
        sa.ForeignKeyConstraint(
            ["ride_id"], ["rides.id"], name=op.f("fk_ride_offers_ride_id_rides"), ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_ride_offers")),
    )
    op.create_index(
        "ix_ride_offers_driver_status", "ride_offers", ["driver_id", "status"], unique=False
    )
    op.create_index(
        "ix_ride_offers_ride_status", "ride_offers", ["ride_id", "status"], unique=False
    )
    op.create_index(
        "ix_ride_offers_status_expires", "ride_offers", ["status", "expires_at"], unique=False
    )


def downgrade() -> None:
    op.drop_index("ix_ride_offers_status_expires", table_name="ride_offers")
    op.drop_index("ix_ride_offers_ride_status", table_name="ride_offers")
    op.drop_index("ix_ride_offers_driver_status", table_name="ride_offers")
    op.drop_table("ride_offers")
