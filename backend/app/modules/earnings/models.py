import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Index, Integer, String, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.db import Base


class LedgerEntry(Base):
    """Driver earnings register: one row per completed ride (amounts in grosze)."""

    __tablename__ = "driver_ledger"
    __table_args__ = (Index("ix_driver_ledger_driver_completed", "driver_id", "completed_at"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    driver_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    ride_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("rides.id"), unique=True, nullable=False)
    payment_method: Mapped[str] = mapped_column(String(16), nullable=False)
    gross: Mapped[int] = mapped_column(Integer, nullable=False)
    commission_percent: Mapped[int] = mapped_column(Integer, nullable=False)
    commission: Mapped[int] = mapped_column(Integer, nullable=False)
    net: Mapped[int] = mapped_column(Integer, nullable=False)
    # Cash: the driver holds the whole fare and owes the commission to the platform.
    cash_collected: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    completed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    settled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
