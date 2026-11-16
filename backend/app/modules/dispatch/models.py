import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Index, Integer, String, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base


class RideOffer(Base):
    """An offer of a ride to one driver (pending -> accepted / declined / expired / cancelled)."""

    __tablename__ = "ride_offers"
    __table_args__ = (
        Index("ix_ride_offers_ride_status", "ride_id", "status"),
        Index("ix_ride_offers_driver_status", "driver_id", "status"),
        Index("ix_ride_offers_status_expires", "status", "expires_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    ride_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("rides.id", ondelete="CASCADE"), nullable=False
    )
    driver_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    pickup_distance_m: Mapped[int] = mapped_column(Integer, nullable=False)
    pickup_eta_s: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    responded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
