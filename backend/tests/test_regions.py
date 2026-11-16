from typing import Any

from httpx import AsyncClient

from app.core.db import get_sessionmaker
from app.modules.regions import service
from app.seed import seed

WIELICZKA_POINT = (49.99, 20.06)
NIEPOLOMICE_POINT = (50.03, 20.22)
OUTSIDE_POINT = (52.23, 21.01)  # Warszawa


def square(west: float, south: float, size: float = 0.1) -> dict[str, Any]:
    e, n = west + size, south + size
    return {
        "type": "Polygon",
        "coordinates": [[[west, south], [e, south], [e, n], [west, n], [west, south]]],
    }


async def create(client: AsyncClient, headers: dict[str, str], **body: Any) -> Any:
    body.setdefault("area", square(19.0, 50.0))
    response = await client.post("/admin/regions", headers=headers, json=body)
    assert response.status_code == 201, response.text
    return response.json()


async def test_admin_creates_region_stored_as_multipolygon(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    region = await create(client, admin_headers, name="Gmina Testowa", teryt="1219011")
    assert region["name"] == "Gmina Testowa"
    assert region["teryt"] == "1219011"
    assert region["active"] is True
    assert region["timezone"] == "Europe/Warsaw"
    assert region["area"]["type"] == "MultiPolygon"
    assert region["area"]["coordinates"][0][0][0] == [19.0, 50.0]  # GeoJSON order: lng, lat


async def test_region_endpoints_require_admin(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    missing = "00000000-0000-0000-0000-000000000000"
    for method, path in [
        ("GET", "/admin/regions"),
        ("POST", "/admin/regions"),
        ("PATCH", f"/admin/regions/{missing}"),
        ("GET", f"/admin/regions/{missing}/tariffs"),
        ("POST", f"/admin/regions/{missing}/tariffs"),
    ]:
        response = await client.request(method, path, headers=passenger_headers, json={})
        assert response.status_code == 403, path


async def test_invalid_geometries_are_rejected(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    bow_tie = {"type": "Polygon", "coordinates": [[[0, 0], [1, 1], [1, 0], [0, 1], [0, 0]]]}
    for area in (
        {"type": "Point", "coordinates": [20.0, 50.0]},
        {"type": "Polygon", "coordinates": "nope"},
        {"type": "Polygon", "coordinates": [[[0, 0], [1, 1]]]},  # not a closed ring
        bow_tie,
    ):
        response = await client.post(
            "/admin/regions", headers=admin_headers, json={"name": "Zla", "area": area}
        )
        assert response.status_code == 422, area


async def test_duplicate_name_conflicts(client: AsyncClient, admin_headers: dict[str, str]) -> None:
    await create(client, admin_headers, name="Gmina A")
    response = await client.post(
        "/admin/regions", headers=admin_headers, json={"name": "Gmina A", "area": square(1, 1)}
    )
    assert response.status_code == 409


async def test_update_region_and_public_list_shows_only_active(
    client: AsyncClient, admin_headers: dict[str, str], passenger_headers: dict[str, str]
) -> None:
    a = await create(client, admin_headers, name="Gmina A")
    b = await create(client, admin_headers, name="Gmina B", area=square(21.0, 50.0))

    response = await client.patch(
        f"/admin/regions/{b['id']}",
        headers=admin_headers,
        json={"active": False, "name": "Gmina B2", "area": square(22.0, 50.0)},
    )
    assert response.status_code == 200
    assert response.json()["name"] == "Gmina B2"
    assert response.json()["area"]["coordinates"][0][0][0] == [22.0, 50.0]

    public = await client.get("/regions", headers=passenger_headers)
    assert public.status_code == 200
    assert [r["id"] for r in public.json()] == [a["id"]]
    assert "area" not in public.json()[0]

    admin_list = await client.get("/admin/regions", headers=admin_headers)
    assert {r["name"] for r in admin_list.json()} == {"Gmina A", "Gmina B2"}


async def test_update_missing_region_is_404(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    response = await client.patch(
        "/admin/regions/00000000-0000-0000-0000-000000000000",
        headers=admin_headers,
        json={"active": False},
    )
    assert response.status_code == 404


async def test_regions_require_login(client: AsyncClient) -> None:
    assert (await client.get("/regions")).status_code == 401


async def test_point_is_assigned_to_the_containing_active_region(
    client: AsyncClient, admin_headers: dict[str, str]
) -> None:
    async with get_sessionmaker()() as session:
        await seed(session)
        wieliczka = await service.find_region_for_point(session, *WIELICZKA_POINT)
        niepolomice = await service.find_region_for_point(session, *NIEPOLOMICE_POINT)
        outside = await service.find_region_for_point(session, *OUTSIDE_POINT)
    assert wieliczka is not None and wieliczka.name == "Gmina Wieliczka"
    assert niepolomice is not None and niepolomice.name == "Gmina Niepołomice"
    assert outside is None

    await client.patch(
        f"/admin/regions/{wieliczka.id}", headers=admin_headers, json={"active": False}
    )
    async with get_sessionmaker()() as session:
        assert await service.find_region_for_point(session, *WIELICZKA_POINT) is None


async def test_seed_is_idempotent(client: AsyncClient, admin_headers: dict[str, str]) -> None:
    async with get_sessionmaker()() as session:
        await seed(session)
        await seed(session)
    regions = (await client.get("/admin/regions", headers=admin_headers)).json()
    assert sorted(r["name"] for r in regions) == ["Gmina Niepołomice", "Gmina Wieliczka"]
    base_fares = {}
    for region in regions:
        tariffs = await client.get(f"/admin/regions/{region['id']}/tariffs", headers=admin_headers)
        assert len(tariffs.json()) == 1
        base_fares[region["name"]] = tariffs.json()[0]["base_fare"]
    assert base_fares["Gmina Wieliczka"] != base_fares["Gmina Niepołomice"]
