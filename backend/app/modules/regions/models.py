import uuid
from typing import Any

from geoalchemy2 import Geometry
from sqlalchemy import Boolean, Index, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base, TimestampMixin


class Region(TimestampMixin, Base):
    """A municipality (gmina). `area` is always stored as MultiPolygon, SRID 4326."""

    __tablename__ = "regions"
    __table_args__ = (Index("ix_regions_area", "area", postgresql_using="gist"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(120), unique=True, nullable=False)
    teryt: Mapped[str | None] = mapped_column(String(7), unique=True)
    timezone: Mapped[str] = mapped_column(String(64), default="Europe/Warsaw", nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    area: Mapped[Any] = mapped_column(
        Geometry("MULTIPOLYGON", srid=4326, spatial_index=False), nullable=False
    )
