"""Redis client (volatile data: online drivers, pub/sub, Celery broker). One client per loop."""

import asyncio
import weakref

from redis.asyncio import Redis

from app.core.config import get_settings

_clients: weakref.WeakKeyDictionary[asyncio.AbstractEventLoop, Redis] = weakref.WeakKeyDictionary()


def get_redis() -> Redis:
    loop = asyncio.get_running_loop()
    client = _clients.get(loop)
    if client is None:
        client = Redis.from_url(get_settings().redis_url, decode_responses=True)
        _clients[loop] = client
    return client


async def close_redis() -> None:
    client = _clients.pop(asyncio.get_running_loop(), None)
    if client is not None:
        await client.aclose()
