from datetime import UTC, datetime, timedelta
from types import SimpleNamespace
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app import worker
from app.core.config import get_settings
from app.core.db import get_sessionmaker
from app.modules.dispatch.queue import CeleryQueue
from app.modules.notifications import push
from app.modules.notifications.push import FcmPushSender, LoggingPushSender, get_push_sender
from app.modules.rides import reservations
from app.modules.rides.models import Ride
from app.modules.users.models import DeviceToken
from tests.conftest import KRAKOW, WIELICZKA, TokenFactory, auth
from tests.dispatch_helpers import current, driver_headers, make_driver, order_now
from tests.fakes import FakeQueue

TOKEN = "fcm-token-" + "x" * 30


async def tokens_in_db() -> list[tuple[str, str, str]]:
    async with get_sessionmaker()() as session:
        rows = await session.execute(
            select(DeviceToken.token, DeviceToken.user_id, DeviceToken.app).order_by(
                DeviceToken.token
            )
        )
        return [tuple(r) for r in rows]  # type: ignore[misc]


# --- device tokens ---


async def test_device_token_registration_and_handover(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    alice, bob = auth(make_token(sub="alice")), auth(make_token(sub="bob"))
    body = {"token": TOKEN, "platform": "android", "app": "passenger"}
    assert (await client.put("/me/device-tokens", headers=alice, json=body)).status_code == 204
    assert (await client.put("/me/device-tokens", headers=alice, json=body)).status_code == 204
    assert await tokens_in_db() == [(TOKEN, "alice", "passenger")]

    # The same phone logs into another account: the token follows the new user.
    moved = {**body, "app": "driver"}
    assert (await client.put("/me/device-tokens", headers=bob, json=moved)).status_code == 204
    assert await tokens_in_db() == [(TOKEN, "bob", "driver")]


async def test_device_token_validation(client: AsyncClient, make_token: TokenFactory) -> None:
    headers = auth(make_token())
    for body in (
        {"token": "short", "platform": "android", "app": "passenger"},
        {"token": TOKEN, "platform": "symbian", "app": "passenger"},
        {"token": TOKEN, "platform": "ios", "app": "other"},
    ):
        assert (
            await client.put("/me/device-tokens", headers=headers, json=body)
        ).status_code == 422
    assert (await client.put("/me/device-tokens", json={})).status_code == 401


# --- which events push ---


@pytest.mark.usefixtures("seeded")
async def test_ride_events_push_to_closed_apps(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    make_token: TokenFactory,
    task_queue: FakeQueue,
) -> None:
    await make_driver("d1")
    ride = await order_now(client, passenger_headers)
    assert task_queue.push_titles("d1") == ["Nowe zlecenie"]
    assert task_queue.pushes[0][3]["ride_id"] == ride["id"]

    headers = driver_headers(make_token, "d1")
    offer = (await current(client, headers))["pending_offer"]
    await client.post(f"/drivers/me/offers/{offer['id']}/accept", headers=headers)
    late = await client.post(f"/drivers/me/offers/{offer['id']}/accept", headers=headers)
    assert late.status_code == 409
    for action in ("depart", "arrived"):
        await client.post(
            f"/drivers/me/rides/{ride['id']}/actions", headers=headers, json={"action": action}
        )
    # Exactly one push per event: the failed second accept did not queue anything.
    assert task_queue.push_titles("passenger-1") == ["Kierowca w drodze", "Kierowca na miejscu"]


@pytest.mark.usefixtures("seeded")
async def test_reservation_events_push(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    make_token: TokenFactory,
    task_queue: FakeQueue,
) -> None:
    await make_driver("d1")
    quote = await client.post(
        "/quotes",
        headers=passenger_headers,
        json={
            "pickup": WIELICZKA,
            "destination": KRAKOW,
            "scheduled_at": (datetime.now(UTC) + timedelta(hours=3)).isoformat(),
        },
    )
    ride = (
        await client.post(
            "/rides",
            headers=passenger_headers,
            json={"quote_id": quote.json()["id"], "payment_method": "cash"},
        )
    ).json()["ride"]
    await client.post(
        f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=driver_headers(make_token, "d1")
    )
    assert task_queue.push_titles("passenger-1") == ["Kierowca przyjął rezerwację"]

    async with get_sessionmaker()() as session:
        await session.execute(
            update(Ride)
            .where(Ride.id == ride["id"])
            .values(scheduled_at=datetime.now(UTC) + timedelta(minutes=50))
        )
        await session.commit()
        await reservations.tick(session)
    assert task_queue.push_titles("d1") == ["Przypomnienie o rezerwacji"]


# --- delivery in the worker ---


class RecordingSender:
    def __init__(self, invalid: list[str]) -> None:
        self.invalid = invalid
        self.sent: list[tuple[list[str], str]] = []

    def send(self, tokens: list[str], title: str, body: str, data: dict[str, str]) -> list[str]:
        self.sent.append((tokens, title))
        return self.invalid


async def test_delivery_sends_to_all_devices_and_forgets_dead_tokens(
    client: AsyncClient, make_token: TokenFactory, monkeypatch: pytest.MonkeyPatch
) -> None:
    headers = auth(make_token(sub="u1"))
    for token in ("token-phone-aaaaaaaa", "token-tablet-bbbbbbbb"):
        await client.put(
            "/me/device-tokens",
            headers=headers,
            json={"token": token, "platform": "android", "app": "passenger"},
        )
    sender = RecordingSender(invalid=["token-tablet-bbbbbbbb"])
    monkeypatch.setattr(worker, "get_push_sender", lambda: sender)
    async with get_sessionmaker()() as session:
        assert await worker.deliver_push(session, "u1", "Tytuł", "Treść", {"a": "b"}) == 1
        assert await worker.deliver_push(session, "nobody", "T", "B", {}) == 0
    assert sorted(sender.sent[0][0]) == ["token-phone-aaaaaaaa", "token-tablet-bbbbbbbb"]
    assert [t for t, _, _ in await tokens_in_db()] == ["token-phone-aaaaaaaa"]


def test_push_task_runs_in_its_own_loop(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(worker, "get_push_sender", lambda: RecordingSender([]))
    assert worker.send_push("nobody", "T", "B", {}) == 0


async def test_celery_queue_hands_push_to_the_worker(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Any, ...]] = []
    monkeypatch.setattr(worker.send_push, "delay", lambda *args: calls.append(args))
    await CeleryQueue().send_push("u1", "T", "B", {"k": "v"})
    assert calls == [("u1", "T", "B", {"k": "v"})]


# --- FCM adapter (fake SDK module, no network) ---


class FakeMessaging:
    class UnregisteredError(Exception):
        pass

    class SenderIdMismatchError(Exception):
        pass

    def __init__(self) -> None:
        self.sent: list[Any] = []

    def MulticastMessage(self, **kwargs: Any) -> Any:
        return SimpleNamespace(**kwargs)

    def Notification(self, **kwargs: Any) -> Any:
        return SimpleNamespace(**kwargs)

    def AndroidConfig(self, **kwargs: Any) -> Any:
        return SimpleNamespace(**kwargs)

    def APNSConfig(self, **kwargs: Any) -> Any:
        return SimpleNamespace(**kwargs)

    def send_each_for_multicast(self, message: Any, app: Any = None) -> Any:
        self.sent.append(message)
        results = [
            SimpleNamespace(success=True, exception=None),
            SimpleNamespace(success=False, exception=self.UnregisteredError("gone")),
            SimpleNamespace(success=False, exception=RuntimeError("quota")),
        ]
        return SimpleNamespace(responses=results[: len(message.tokens)])


def test_fcm_sender_builds_message_and_reports_dead_tokens() -> None:
    fake = FakeMessaging()
    sender = FcmPushSender("unused.json", messaging=fake)
    invalid = sender.send(["ok", "gone", "busy"], "Nowe zlecenie", "Odbiór", {"ride_id": "1"})
    assert invalid == ["gone"]  # transient errors keep the token
    message = fake.sent[0]
    assert message.tokens == ["ok", "gone", "busy"]
    assert message.notification.title == "Nowe zlecenie"
    assert message.data == {"ride_id": "1"}
    assert message.android.priority == "high"


def test_sender_selection_without_credentials(monkeypatch: pytest.MonkeyPatch) -> None:
    get_push_sender.cache_clear()
    assert isinstance(get_push_sender(), LoggingPushSender)
    monkeypatch.setattr(get_settings(), "firebase_credentials_file", "/nope/firebase.json")
    get_push_sender.cache_clear()
    assert isinstance(push.get_push_sender(), LoggingPushSender)  # missing file: only logged
    get_push_sender.cache_clear()
    assert LoggingPushSender().send(["t"], "T", "B", {}) == []
