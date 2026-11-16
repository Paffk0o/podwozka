"""drivers vehicles documents

Revision ID: 0005
Revises: 0004
Create Date: 2026-11-16 18:22:12.400321
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op


revision: str = "0005"
down_revision: str | None = "0004"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "driver_profiles",
        sa.Column("user_id", sa.String(length=64), nullable=False),
        sa.Column("region_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("status_reason", sa.String(length=500), nullable=True),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("approved_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("suspended_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("online", sa.Boolean(), nullable=False),
        sa.Column("online_changed_at", sa.DateTime(timezone=True), nullable=True),
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
        sa.ForeignKeyConstraint(
            ["region_id"], ["regions.id"], name=op.f("fk_driver_profiles_region_id_regions")
        ),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name=op.f("fk_driver_profiles_user_id_users")
        ),
        sa.PrimaryKeyConstraint("user_id", name=op.f("pk_driver_profiles")),
    )
    op.create_index(
        "ix_driver_profiles_region_status", "driver_profiles", ["region_id", "status"], unique=False
    )
    op.create_table(
        "driver_documents",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("driver_id", sa.String(length=64), nullable=False),
        sa.Column("type", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("content_type", sa.String(length=64), nullable=False),
        sa.Column("size_bytes", sa.BigInteger(), nullable=False),
        sa.Column("blob_path", sa.String(length=300), nullable=False),
        sa.Column("expires_on", sa.Date(), nullable=True),
        sa.Column("uploaded_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("replaced_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("review_comment", sa.String(length=500), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["driver_id"],
            ["driver_profiles.user_id"],
            name=op.f("fk_driver_documents_driver_id_driver_profiles"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_driver_documents")),
    )
    op.create_index(
        "ix_driver_documents_driver_type", "driver_documents", ["driver_id", "type"], unique=False
    )
    op.create_table(
        "vehicles",
        sa.Column("driver_id", sa.String(length=64), nullable=False),
        sa.Column("make", sa.String(length=60), nullable=False),
        sa.Column("model", sa.String(length=60), nullable=False),
        sa.Column("color", sa.String(length=30), nullable=False),
        sa.Column("plate", sa.String(length=12), nullable=False),
        sa.Column("seats", sa.SmallInteger(), nullable=False),
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
        sa.ForeignKeyConstraint(
            ["driver_id"],
            ["driver_profiles.user_id"],
            name=op.f("fk_vehicles_driver_id_driver_profiles"),
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("driver_id", name=op.f("pk_vehicles")),
    )


def downgrade() -> None:
    op.drop_table("vehicles")
    op.drop_index("ix_driver_documents_driver_type", table_name="driver_documents")
    op.drop_table("driver_documents")
    op.drop_index("ix_driver_profiles_region_status", table_name="driver_profiles")
    op.drop_table("driver_profiles")
