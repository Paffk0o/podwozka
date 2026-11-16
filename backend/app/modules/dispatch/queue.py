"""Background jobs scheduled by the API (Celery in production, a fake in tests)."""

import asyncio
import uuid
from typing import Protocol


class TaskQueue(Protocol):
    async def expire_offer_at(self, offer_id: uuid.UUID, delay_s: float) -> None: ...

    async def send_push(
        self, user_id: str, title: str, body: str, data: dict[str, str]
    ) -> None: ...


class CeleryQueue:
    async def expire_offer_at(self, offer_id: uuid.UUID, delay_s: float) -> None:
        from app.worker import expire_offer

        # apply_async talks to Redis synchronously — keep it off the event loop.
        await asyncio.to_thread(expire_offer.apply_async, args=[str(offer_id)], countdown=delay_s)

    async def send_push(self, user_id: str, title: str, body: str, data: dict[str, str]) -> None:
        from app.worker import send_push

        await asyncio.to_thread(send_push.delay, user_id, title, body, data)


_queue: TaskQueue | None = None


def get_task_queue() -> TaskQueue:
    global _queue
    if _queue is None:
        _queue = CeleryQueue()
    return _queue


def set_task_queue(queue: TaskQueue | None) -> None:
    """Tests replace the queue with a fake."""
    global _queue
    _queue = queue
