"""regions and tariffs

Revision ID: 0002
Revises: 0001
Create Date: 2026-11-16 18:00:07.926863
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from geoalchemy2 import Geometry

revision: str = "0002"
down_revision: str | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "regions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("teryt", sa.String(length=7), nullable=True),
        sa.Column("timezone", sa.String(length=64), nullable=False),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column(
            "area",
            Geometry("MULTIPOLYGON", srid=4326, spatial_index=False),
            nullable=False,
        ),
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
        sa.PrimaryKeyConstraint("id", name=op.f("pk_regions")),
        sa.UniqueConstraint("name", name=op.f("uq_regions_name")),
        sa.UniqueConstraint("teryt", name=op.f("uq_regions_teryt")),
    )
    op.create_index("ix_regions_area", "regions", ["area"], unique=False, postgresql_using="gist")
    op.create_table(
        "tariffs",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("region_id", sa.Uuid(), nullable=False),
        sa.Column("base_fare", sa.Integer(), nullable=False),
        sa.Column("per_km", sa.Integer(), nullable=False),
        sa.Column("per_minute", sa.Integer(), nullable=False),
        sa.Column("minimum_fare", sa.Integer(), nullable=False),
        sa.Column("night_multiplier_percent", sa.Integer(), nullable=False),
        sa.Column("night_start_hour", sa.Integer(), nullable=False),
        sa.Column("night_end_hour", sa.Integer(), nullable=False),
        sa.Column("commission_percent", sa.Integer(), nullable=False),
        sa.Column("valid_from", sa.DateTime(timezone=True), nullable=False),
        sa.Column("valid_to", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_by", sa.String(length=64), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["region_id"], ["regions.id"], name=op.f("fk_tariffs_region_id_regions")
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_tariffs")),
    )
    op.create_index(
        "ix_tariffs_region_valid_from", "tariffs", ["region_id", "valid_from"], unique=False
    )


def downgrade() -> None:
    op.drop_index("ix_tariffs_region_valid_from", table_name="tariffs")
    op.drop_table("tariffs")
    op.drop_index("ix_regions_area", table_name="regions", postgresql_using="gist")
    op.drop_table("regions")
