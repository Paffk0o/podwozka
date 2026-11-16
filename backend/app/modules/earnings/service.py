"""Earnings register (brutto / prowizja / netto, cash vs. online)."""

from datetime import date, datetime, time, timedelta
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.drivers.schemas import EarningEntry, EarningsSummary
from app.modules.earnings.models import LedgerEntry
from app.modules.pricing.calculator import commission
from app.modules.pricing.models import Tariff
from app.modules.rides.models import Ride
from app.modules.rides.schemas import PaymentMethod

LOCAL_TZ = ZoneInfo("Europe/Warsaw")
MAX_RANGE = timedelta(days=366)


async def record_completed_ride(session: AsyncSession, ride: Ride) -> LedgerEntry:
    """Inside the completion transaction; the commission % comes from the ride's tariff."""
    if ride.driver_id is None or ride.completed_at is None:  # pragma: no cover - caller ensures
        raise ValueError("ride is not completed")
    tariff = await session.get(Tariff, ride.tariff_id)
    percent = tariff.commission_percent if tariff else 0
    fee = commission(ride.price, percent)
    entry = LedgerEntry(
        driver_id=ride.driver_id,
        ride_id=ride.id,
        payment_method=ride.payment_method,
        gross=ride.price,
        commission_percent=percent,
        commission=fee,
        net=ride.price - fee,
        completed_at=ride.completed_at,
    )
    session.add(entry)
    return entry


async def mark_cash_collected(session: AsyncSession, ride: Ride) -> None:
    await session.execute(
        update(LedgerEntry).where(LedgerEntry.ride_id == ride.id).values(cash_collected=True)
    )


async def summary(
    session: AsyncSession, driver_id: str, date_from: date, date_to: date
) -> EarningsSummary:
    """Days are local (Europe/Warsaw), both ends inclusive."""
    if date_to < date_from:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "date_to przed date_from")
    if date_to - date_from > MAX_RANGE:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, "Zakres najwyżej 366 dni")
    start = datetime.combine(date_from, time.min, LOCAL_TZ)
    end = datetime.combine(date_to + timedelta(days=1), time.min, LOCAL_TZ)
    rows = list(
        (
            await session.execute(
                select(LedgerEntry)
                .where(
                    LedgerEntry.driver_id == driver_id,
                    LedgerEntry.completed_at >= start,
                    LedgerEntry.completed_at < end,
                )
                .order_by(LedgerEntry.completed_at.desc())
            )
        ).scalars()
    )
    cash_rows = [r for r in rows if r.payment_method == PaymentMethod.CASH and r.cash_collected]
    return EarningsSummary(
        date_from=date_from,
        date_to=date_to,
        rides_count=len(rows),
        gross=sum(r.gross for r in rows),
        commission=sum(r.commission for r in rows),
        net=sum(r.net for r in rows),
        cash_collected=sum(r.gross for r in cash_rows),
        commission_due_from_cash=sum(r.commission for r in cash_rows),
        items=[
            EarningEntry(
                ride_id=r.ride_id,
                completed_at=r.completed_at,
                payment_method=PaymentMethod(r.payment_method),
                gross=r.gross,
                commission=r.commission,
                net=r.net,
            )
            for r in rows
        ],
    )
