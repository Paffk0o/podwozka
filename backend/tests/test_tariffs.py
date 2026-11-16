from datetime import UTC, datetime, timedelta
from typing import Any

from httpx import AsyncClient, Response

from app.core.db import get_sessionmaker
from app.modules.pricing.tariffs import active_tariff
from tests.test_regions import create

TARIFF = {
    "base_fare": 800,
    "per_km": 300,
    "per_minute": 50,
    "minimum_fare": 1500,
    "night_multiplier_percent": 120,
    "commission_percent": 10,
}


async def post_tariff(
    client: AsyncClient, headers: dict[str, str], region_id: str, **overrides: Any
) -> Response:
    return await client.post(
        f"/admin/regions/{region_id}/tariffs", headers=headers, json={**TARIFF, **overrides}
    )


async def test_new_version_closes_previous(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    region = await create(client, admin_headers, name="Gmina T")
    t1_from = datetime.now(UTC) - timedelta(days=10)
    t2_from = datetime.now(UTC) + timedelta(days=1)

    first = await post_tariff(client, admin_headers, region["id"], valid_from=t1_from.isoformat())
    assert first.status_code == 201
    assert first.json()["valid_to"] is None
    assert first.json()["night_start_hour"] == 22  # default from the contract

    second = await post_tariff(
        client, admin_headers, region["id"], base_fare=900, valid_from=t2_from.isoformat()
    )
    assert second.status_code == 201

    history = (
        await client.get(f"/admin/regions/{region['id']}/tariffs", headers=admin_headers)
    ).json()
    assert [t["id"] for t in history] == [second.json()["id"], first.json()["id"]]
    assert datetime.fromisoformat(history[1]["valid_to"]) == t2_from

    # Versions are looked up by time: today the old one applies, tomorrow the new one.
    async with get_sessionmaker()() as session:
        now = await active_tariff(session, region["id"])
        later = await active_tariff(session, region["id"], t2_from + timedelta(hours=1))
        before = await active_tariff(session, region["id"], t1_from - timedelta(days=1))
    assert now is not None and str(now.id) == first.json()["id"]
    assert later is not None and str(later.id) == second.json()["id"]
    assert before is None


async def test_version_cannot_start_before_current_one(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    region = await create(client, admin_headers, name="Gmina T")
    await post_tariff(client, admin_headers, region["id"])
    past = (datetime.now(UTC) - timedelta(days=1)).isoformat()
    response = await post_tariff(client, admin_headers, region["id"], valid_from=past)
    assert response.status_code == 409


async def test_tariff_validation(client: AsyncClient, admin_headers: dict[str, str]) -> None:
    region = await create(client, admin_headers, name="Gmina T")
    rid = region["id"]
    assert (await post_tariff(client, admin_headers, rid, minimum_fare=100)).status_code == 422
    assert (await post_tariff(client, admin_headers, rid, per_km=-1)).status_code == 422
    assert (
        await post_tariff(client, admin_headers, rid, night_multiplier_percent=90)
    ).status_code == 422
    naive = await post_tariff(client, admin_headers, rid, valid_from="2030-01-01T00:00:00")
    assert naive.status_code == 422


async def test_tariffs_of_missing_region_are_404(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    missing = "00000000-0000-0000-0000-000000000000"
    listed = await client.get(f"/admin/regions/{missing}/tariffs", headers=admin_headers)
    assert listed.status_code == 404
    assert (await post_tariff(client, admin_headers, missing)).status_code == 404
