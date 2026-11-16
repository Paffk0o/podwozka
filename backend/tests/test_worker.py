"""Celery task bodies run like in the worker: a fresh event loop per task, no broker needed."""

import uuid
from typing import Any

import pytest

from app import worker
from app.modules.dispatch.queue import CeleryQueue


def test_tasks_run_in_their_own_event_loop() -> None:
    assert worker.sweep() == 0  # nothing to do on an empty database
    assert worker.expire_offer(str(uuid.uuid4())) is False  # unknown offer


def test_beat_runs_the_sweeper_often() -> None:
    schedule = worker.celery_app.conf.beat_schedule
    assert schedule["dispatch-sweep"]["task"] == "dispatch.sweep"
    assert schedule["dispatch-sweep"]["schedule"] <= 15


async def test_celery_queue_schedules_expiry(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[dict[str, Any]] = []
    monkeypatch.setattr(worker.expire_offer, "apply_async", lambda **kw: calls.append(kw))
    offer_id = uuid.uuid4()
    await CeleryQueue().expire_offer_at(offer_id, 20)
    assert calls == [{"args": [str(offer_id)], "countdown": 20}]
