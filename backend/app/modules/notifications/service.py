"""User notifications.

`notify()` queues, inside the caller's transaction (sent only after commit):
- a `notification` message on the user's WebSocket channel (unless `push_only`), and
- a push notification (Celery task `push.send` -> FCM) for when the app is closed.
Use `push_only` when the app already gets a dedicated WebSocket event (e.g. `offer.new`).
"""

from sqlalchemy.ext.asyncio import AsyncSession

from app.core import events
from app.modules.rides.service import queue_message, queue_push


def notify(
    session: AsyncSession,
    user_id: str,
    title: str,
    body: str,
    data: dict[str, str],
    push_only: bool = False,
) -> None:
    if not push_only:
        queue_message(
            session,
            events.user_channel(user_id),
            {"type": "notification", "title": title, "body": body, "data": data},
        )
    queue_push(session, user_id, title, body, data)
