import asyncio
import weakref
from collections.abc import AsyncIterator
from datetime import datetime
from typing import Annotated

from fastapi import Depends
from sqlalchemy import DateTime, MetaData, func
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from app.core.config import get_settings

# Deterministic constraint names — required for reliable Alembic autogenerate.
NAMING_CONVENTION = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


class Base(DeclarativeBase):
    metadata = MetaData(naming_convention=NAMING_CONVENTION)


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )


# One engine per event loop: asyncpg connections belong to the loop that created them.
# The API has a single loop; tests (TestClient for WebSockets) and Celery tasks (asyncio.run per
# task) run code in other loops, which must not reuse the API's pool.
_engines: weakref.WeakKeyDictionary[
    asyncio.AbstractEventLoop, tuple[AsyncEngine, async_sessionmaker[AsyncSession]]
] = weakref.WeakKeyDictionary()


def _current() -> tuple[AsyncEngine, async_sessionmaker[AsyncSession]]:
    loop = asyncio.get_running_loop()
    pair = _engines.get(loop)
    if pair is None:
        engine = create_async_engine(get_settings().database_url, pool_pre_ping=True)
        pair = (engine, async_sessionmaker(engine, expire_on_commit=False))
        _engines[loop] = pair
    return pair


def get_engine() -> AsyncEngine:
    return _current()[0]


def get_sessionmaker() -> async_sessionmaker[AsyncSession]:
    return _current()[1]


async def dispose_engine() -> None:
    """Dispose the engine of the current event loop (if any)."""
    pair = _engines.pop(asyncio.get_running_loop(), None)
    if pair is not None:
        await pair[0].dispose()


async def get_session() -> AsyncIterator[AsyncSession]:
    async with get_sessionmaker()() as session:
        yield session


SessionDep = Annotated[AsyncSession, Depends(get_session)]
