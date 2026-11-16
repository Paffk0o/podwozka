"""User notifications: a `notification` message on the user's WebSocket channel.

Queued inside the caller's transaction (sent only after commit). Push (FCM) for closed apps
is added on top of this in the push module.
"""

from sqlalchemy.ext.asyncio import AsyncSession

from app.core import events
from app.modules.rides.service import queue_message


def notify(
    session: AsyncSession, user_id: str, title: str, body: str, data: dict[str, str]
) -> None:
    queue_message(
        session,
        events.user_channel(user_id),
        {"type": "notification", "title": title, "body": body, "data": data},
    )
