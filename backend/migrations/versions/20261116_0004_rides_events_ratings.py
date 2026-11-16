"""rides events ratings

Revision ID: 0004
Revises: 0003
Create Date: 2026-11-16 18:12:21.427243
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from geoalchemy2 import Geometry

revision: str = "0004"
down_revision: str | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "rides",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("passenger_id", sa.String(length=64), nullable=False),
        sa.Column("driver_id", sa.String(length=64), nullable=True),
        sa.Column("region_id", sa.Uuid(), nullable=False),
        sa.Column("quote_id", sa.Uuid(), nullable=False),
        sa.Column("tariff_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column(
            "pickup_location",
            Geometry("POINT", srid=4326, spatial_index=False),
            nullable=False,
        ),
        sa.Column("pickup_address", sa.String(length=300), nullable=False),
        sa.Column("pickup_place_id", sa.String(length=300), nullable=True),
        sa.Column(
            "destination_location",
            Geometry("POINT", srid=4326, spatial_index=False),
            nullable=False,
        ),
        sa.Column("destination_address", sa.String(length=300), nullable=False),
        sa.Column("destination_place_id", sa.String(length=300), nullable=True),
        sa.Column("scheduled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "requested_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("accepted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cancelled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cancel_reason", sa.String(length=300), nullable=True),
        sa.Column("reminder_sent_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("price", sa.Integer(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False),
        sa.Column("payment_method", sa.String(length=16), nullable=False),
        sa.Column("payment_status", sa.String(length=16), nullable=False),
        sa.Column("distance_m", sa.Integer(), nullable=False),
        sa.Column("duration_s", sa.Integer(), nullable=False),
        sa.Column("route_polyline", sa.Text(), nullable=True),
        sa.Column("passenger_note", sa.String(length=300), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["driver_id"], ["users.id"], name=op.f("fk_rides_driver_id_users")),
        sa.ForeignKeyConstraint(
            ["passenger_id"], ["users.id"], name=op.f("fk_rides_passenger_id_users")
        ),
        sa.ForeignKeyConstraint(["quote_id"], ["quotes.id"], name=op.f("fk_rides_quote_id_quotes")),
        sa.ForeignKeyConstraint(
            ["region_id"], ["regions.id"], name=op.f("fk_rides_region_id_regions")
        ),
        sa.ForeignKeyConstraint(
            ["tariff_id"], ["tariffs.id"], name=op.f("fk_rides_tariff_id_tariffs")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_rides")),
        sa.UniqueConstraint("quote_id", name=op.f("uq_rides_quote_id")),
    )
    op.create_index("ix_rides_driver_status", "rides", ["driver_id", "status"], unique=False)
    op.create_index(
        "ix_rides_passenger_requested", "rides", ["passenger_id", "requested_at"], unique=False
    )
    op.create_index("ix_rides_region_status", "rides", ["region_id", "status"], unique=False)
    op.create_index("ix_rides_status_scheduled", "rides", ["status", "scheduled_at"], unique=False)
    op.create_table(
        "ratings",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("ride_id", sa.Uuid(), nullable=False),
        sa.Column("from_user_id", sa.String(length=64), nullable=False),
        sa.Column("to_user_id", sa.String(length=64), nullable=False),
        sa.Column("from_role", sa.String(length=16), nullable=False),
        sa.Column("stars", sa.SmallInteger(), nullable=False),
        sa.Column("comment", sa.String(length=500), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["ride_id"], ["rides.id"], name=op.f("fk_ratings_ride_id_rides")),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_ratings")),
        sa.UniqueConstraint("ride_id", "from_role", name="uq_ratings_ride_from_role"),
    )
    op.create_index(op.f("ix_ratings_to_user_id"), "ratings", ["to_user_id"], unique=False)
    op.create_table(
        "ride_events",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("ride_id", sa.Uuid(), nullable=False),
        sa.Column("from_status", sa.String(length=32), nullable=True),
        sa.Column("to_status", sa.String(length=32), nullable=False),
        sa.Column("actor_id", sa.String(length=64), nullable=True),
        sa.Column("actor_role", sa.String(length=16), nullable=False),
        sa.Column("note", sa.String(length=300), nullable=True),
        sa.Column("at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["ride_id"], ["rides.id"], name=op.f("fk_ride_events_ride_id_rides"), ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_ride_events")),
    )
    op.create_index(op.f("ix_ride_events_ride_id"), "ride_events", ["ride_id"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_ride_events_ride_id"), table_name="ride_events")
    op.drop_table("ride_events")
    op.drop_index(op.f("ix_ratings_to_user_id"), table_name="ratings")
    op.drop_table("ratings")
    op.drop_index("ix_rides_status_scheduled", table_name="rides")
    op.drop_index("ix_rides_region_status", table_name="rides")
    op.drop_index("ix_rides_passenger_requested", table_name="rides")
    op.drop_index("ix_rides_driver_status", table_name="rides")
    op.drop_table("rides")
