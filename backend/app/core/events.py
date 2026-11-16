"""Live notifications through Redis pub/sub (docs/ws-protocol.md §6).

Channels: `ride:{id}` (passenger + assigned driver), `user:{sub}` (one user's devices).
Every API replica forwards messages from these channels to its own WebSocket connections.
Publishing never fails the request: REST stays the source of truth and the apps refresh state
via REST after reconnecting.
"""

import json
import logging
from typing import Any

from app.core.redis import get_redis

log = logging.getLogger(__name__)


def ride_channel(ride_id: object) -> str:
    return f"ride:{ride_id}"


def user_channel(user_id: str) -> str:
    return f"user:{user_id}"


async def publish(channel: str, message: dict[str, Any]) -> None:
    try:
        await get_redis().publish(channel, json.dumps(message, default=str))
    except Exception:  # pragma: no cover - Redis down must not break the request
        log.exception("publish to %s failed", channel)
