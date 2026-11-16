import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Index, Integer, String, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base


class Tariff(Base):
    """A tariff version of a region. Versions never overlap: [valid_from, valid_to)."""

    __tablename__ = "tariffs"
    __table_args__ = (Index("ix_tariffs_region_valid_from", "region_id", "valid_from"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    region_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("regions.id"), nullable=False)
    base_fare: Mapped[int] = mapped_column(Integer, nullable=False)
    per_km: Mapped[int] = mapped_column(Integer, nullable=False)
    per_minute: Mapped[int] = mapped_column(Integer, nullable=False)
    minimum_fare: Mapped[int] = mapped_column(Integer, nullable=False)
    night_multiplier_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    night_start_hour: Mapped[int] = mapped_column(Integer, nullable=False)
    night_end_hour: Mapped[int] = mapped_column(Integer, nullable=False)
    commission_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    valid_from: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    valid_to: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_by: Mapped[str | None] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
