"""Push notifications behind an interface.

- `FcmPushSender` — Firebase Cloud Messaging (HTTP v1 via firebase-admin), used when
  FIREBASE_CREDENTIALS_FILE points to a service-account JSON (never committed to the repo).
- `LoggingPushSender` — default without credentials: logs what would be sent.

Senders are synchronous: they run only in the Celery worker (`push.send` task).
"""

import logging
from functools import lru_cache
from pathlib import Path
from typing import Any, Protocol

from app.core.config import get_settings

log = logging.getLogger(__name__)


class PushSender(Protocol):
    def send(self, tokens: list[str], title: str, body: str, data: dict[str, str]) -> list[str]:
        """Send to all tokens; return the tokens FCM reported as no longer valid."""
        ...


class LoggingPushSender:
    def send(self, tokens: list[str], title: str, body: str, data: dict[str, str]) -> list[str]:
        log.info(
            "push (not sent, no FCM credentials) to %d device(s): %s — %s %s",
            len(tokens),
            title,
            body,
            data,
        )
        return []


class FcmPushSender:
    def __init__(self, credentials_file: str, messaging: Any = None) -> None:
        if messaging is None:  # pragma: no cover - real Firebase SDK
            import firebase_admin
            from firebase_admin import credentials
            from firebase_admin import messaging as fcm

            app = firebase_admin.initialize_app(
                credentials.Certificate(credentials_file), name="podwozka-push"
            )
            self._app: Any = app
            messaging = fcm
        else:
            self._app = None
        self._messaging = messaging

    def send(self, tokens: list[str], title: str, body: str, data: dict[str, str]) -> list[str]:
        m = self._messaging
        message = m.MulticastMessage(
            tokens=tokens,
            data=data,
            notification=m.Notification(title=title, body=body),
            android=m.AndroidConfig(priority="high"),
            apns=m.APNSConfig(headers={"apns-priority": "10"}),
        )
        response = m.send_each_for_multicast(message, app=self._app)
        invalid = []
        for token, result in zip(tokens, response.responses, strict=True):
            if result.success:
                continue
            if isinstance(result.exception, (m.UnregisteredError, m.SenderIdMismatchError)):
                invalid.append(token)
            else:
                log.warning("push to a device failed: %s", result.exception)
        return invalid


@lru_cache
def get_push_sender() -> PushSender:
    path = get_settings().firebase_credentials_file
    if path and Path(path).is_file():
        return FcmPushSender(path)
    if path:
        log.warning("FIREBASE_CREDENTIALS_FILE=%s not found — push is only logged", path)
    return LoggingPushSender()
