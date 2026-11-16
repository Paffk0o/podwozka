"""Celery worker and beat schedule.

    celery -A app.worker worker --loglevel=info
    celery -A app.worker beat --loglevel=info

Task bodies are async service functions; each task runs them in a fresh event loop with its own
DB engine and Redis client (closed afterwards). State lives in PostgreSQL, so a restarted worker
loses nothing: the beat `sweep` re-expires overdue offers and restarts stuck dispatches.
"""

import asyncio
import uuid
from collections.abc import Awaitable, Callable

from celery import Celery
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.db import dispose_engine, get_sessionmaker
from app.core.redis import close_redis
from app.modules.dispatch import service as dispatch
from app.modules.notifications.push import get_push_sender
from app.modules.rides import reservations
from app.modules.users import service as users_service

celery_app = Celery("podwozka", broker=get_settings().redis_url)
celery_app.conf.update(
    timezone="UTC",
    task_ignore_result=True,
    broker_connection_retry_on_startup=True,
    worker_hijack_root_logger=False,
    beat_schedule={
        "dispatch-sweep": {"task": "dispatch.sweep", "schedule": 10.0},
        "reservations-tick": {"task": "reservations.tick", "schedule": 60.0},
    },
)


async def _with_session[T](fn: Callable[[AsyncSession], Awaitable[T]]) -> T:
    try:
        async with get_sessionmaker()() as session:
            return await fn(session)
    finally:
        await dispose_engine()
        await close_redis()


def run[T](fn: Callable[[AsyncSession], Awaitable[T]]) -> T:
    return asyncio.run(_with_session(fn))


@celery_app.task(name="dispatch.expire_offer")
def expire_offer(offer_id: str) -> bool:
    return run(lambda session: dispatch.expire_offer(session, uuid.UUID(offer_id)))


async def deliver_push(
    session: AsyncSession, user_id: str, title: str, body: str, data: dict[str, str]
) -> int:
    """Send to all devices of the user; forget tokens FCM says are dead."""
    tokens = await users_service.device_tokens(session, user_id)
    if not tokens:
        return 0
    invalid = await asyncio.to_thread(get_push_sender().send, tokens, title, body, data)
    await users_service.forget_device_tokens(session, invalid)
    return len(tokens) - len(invalid)


@celery_app.task(name="push.send")
def send_push(user_id: str, title: str, body: str, data: dict[str, str]) -> int:
    return run(lambda session: deliver_push(session, user_id, title, body, data))


@celery_app.task(name="reservations.tick")
def reservations_tick() -> tuple[int, int]:
    return run(reservations.tick)


@celery_app.task(name="dispatch.sweep")
def sweep() -> int:
    return run(dispatch.sweep)
