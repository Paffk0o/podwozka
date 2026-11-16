"""Test doubles for external integrations (no network in tests)."""

from datetime import UTC, datetime, timedelta

from app.core.keycloak_admin import IdentityAdminError
from app.modules.drivers.storage import SignedUpload


class FakeStorage:
    def __init__(self) -> None:
        self.uploaded: set[str] = set()

    def upload_url(self, path: str, content_type: str, ttl: timedelta) -> SignedUpload:
        return SignedUpload(
            url=f"https://blob.test/{path}?sp=cw",
            headers={"x-ms-blob-type": "BlockBlob", "Content-Type": content_type},
            expires_at=datetime.now(UTC) + ttl,
        )

    def view_url(self, path: str, ttl: timedelta) -> tuple[str, datetime]:
        return f"https://blob.test/{path}?sp=r", datetime.now(UTC) + ttl

    async def exists(self, path: str) -> bool:
        return path in self.uploaded

    async def ensure_container(self) -> None:
        return None


class FakeIdentity:
    def __init__(self) -> None:
        self.granted: list[tuple[str, str]] = []
        self.fail = False

    async def grant_realm_role(self, user_id: str, role: str) -> None:
        if self.fail:
            raise IdentityAdminError("keycloak down")
        self.granted.append((user_id, role))


class FakeQueue:
    def __init__(self) -> None:
        self.expiries: list[tuple[str, float]] = []
        self.pushes: list[tuple[str, str, str, dict[str, str]]] = []

    async def expire_offer_at(self, offer_id: object, delay_s: float) -> None:
        self.expiries.append((str(offer_id), delay_s))

    async def send_push(self, user_id: str, title: str, body: str, data: dict[str, str]) -> None:
        self.pushes.append((user_id, title, body, data))

    def push_titles(self, user_id: str) -> list[str]:
        return [title for uid, title, _, _ in self.pushes if uid == user_id]
