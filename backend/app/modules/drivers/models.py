import uuid
from datetime import date, datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base, TimestampMixin


class DriverProfile(TimestampMixin, Base):
    """Driver application / profile. Driver endpoints require role `driver` AND status approved."""

    __tablename__ = "driver_profiles"
    __table_args__ = (Index("ix_driver_profiles_region_status", "region_id", "status"),)

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), primary_key=True)
    region_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("regions.id"), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    # Reason of the last rejection or suspension (shown to the driver).
    status_reason: Mapped[str | None] = mapped_column(String(500))
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    approved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    suspended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    online: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    online_changed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class Vehicle(TimestampMixin, Base):
    __tablename__ = "vehicles"

    driver_id: Mapped[str] = mapped_column(
        ForeignKey("driver_profiles.user_id", ondelete="CASCADE"), primary_key=True
    )
    make: Mapped[str] = mapped_column(String(60), nullable=False)
    model: Mapped[str] = mapped_column(String(60), nullable=False)
    color: Mapped[str] = mapped_column(String(30), nullable=False)
    plate: Mapped[str] = mapped_column(String(12), nullable=False)
    seats: Mapped[int] = mapped_column(SmallInteger, nullable=False)


class DriverDocument(Base):
    """A document file in Blob Storage. A newer upload of the same type replaces the older one."""

    __tablename__ = "driver_documents"
    __table_args__ = (Index("ix_driver_documents_driver_type", "driver_id", "type"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    driver_id: Mapped[str] = mapped_column(
        ForeignKey("driver_profiles.user_id", ondelete="CASCADE"), nullable=False
    )
    type: Mapped[str] = mapped_column(String(32), nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False)
    content_type: Mapped[str] = mapped_column(String(64), nullable=False)
    size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)
    blob_path: Mapped[str] = mapped_column(String(300), nullable=False)
    expires_on: Mapped[date | None] = mapped_column(Date)
    uploaded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    replaced_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    review_comment: Mapped[str | None] = mapped_column(String(500))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
