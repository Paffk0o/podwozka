import uuid
from datetime import datetime
from typing import Any

from geoalchemy2 import Geometry
from sqlalchemy import (
    BigInteger,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base, TimestampMixin


def _point() -> Any:
    return mapped_column(Geometry("POINT", srid=4326, spatial_index=False), nullable=False)


class Ride(TimestampMixin, Base):
    """A ride. `status` changes ONLY through rides.service.transition()."""

    __tablename__ = "rides"
    __table_args__ = (
        Index("ix_rides_passenger_requested", "passenger_id", "requested_at"),
        Index("ix_rides_driver_status", "driver_id", "status"),
        Index("ix_rides_status_scheduled", "status", "scheduled_at"),
        Index("ix_rides_region_status", "region_id", "status"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    passenger_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    driver_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    region_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("regions.id"), nullable=False)
    quote_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("quotes.id"), unique=True, nullable=False
    )
    tariff_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("tariffs.id"), nullable=False)
    status: Mapped[str] = mapped_column(String(32), nullable=False)

    pickup_location: Mapped[Any] = _point()
    pickup_address: Mapped[str] = mapped_column(String(300), nullable=False)
    pickup_place_id: Mapped[str | None] = mapped_column(String(300))
    destination_location: Mapped[Any] = _point()
    destination_address: Mapped[str] = mapped_column(String(300), nullable=False)
    destination_place_id: Mapped[str | None] = mapped_column(String(300))

    scheduled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    requested_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    accepted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    cancelled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    cancel_reason: Mapped[str | None] = mapped_column(String(300))
    reminder_sent_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    price: Mapped[int] = mapped_column(Integer, nullable=False)
    currency: Mapped[str] = mapped_column(String(3), nullable=False, default="PLN")
    payment_method: Mapped[str] = mapped_column(String(16), nullable=False)
    payment_status: Mapped[str] = mapped_column(String(16), nullable=False)
    distance_m: Mapped[int] = mapped_column(Integer, nullable=False)
    duration_s: Mapped[int] = mapped_column(Integer, nullable=False)
    route_polyline: Mapped[str | None] = mapped_column(Text)
    passenger_note: Mapped[str | None] = mapped_column(String(300))


class RideEvent(Base):
    """Audit log of the ride state machine: one row per status transition."""

    __tablename__ = "ride_events"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    ride_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("rides.id", ondelete="CASCADE"), nullable=False, index=True
    )
    from_status: Mapped[str | None] = mapped_column(String(32))
    to_status: Mapped[str] = mapped_column(String(32), nullable=False)
    actor_id: Mapped[str | None] = mapped_column(String(64))
    actor_role: Mapped[str] = mapped_column(String(16), nullable=False)
    note: Mapped[str | None] = mapped_column(String(300))
    at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)


class Rating(Base):
    __tablename__ = "ratings"
    __table_args__ = (UniqueConstraint("ride_id", "from_role", name="uq_ratings_ride_from_role"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    ride_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("rides.id"), nullable=False)
    from_user_id: Mapped[str] = mapped_column(String(64), nullable=False)
    to_user_id: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    from_role: Mapped[str] = mapped_column(String(16), nullable=False)
    stars: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    comment: Mapped[str | None] = mapped_column(String(500))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
