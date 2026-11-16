from collections.abc import Iterator
from datetime import date, timedelta
from typing import Any

import pytest
from httpx import AsyncClient

from app.core.db import get_sessionmaker
from app.core.keycloak_admin import get_identity_admin_or_503
from app.main import app
from app.modules.drivers import service
from app.modules.drivers.storage import get_storage_or_503
from app.modules.regions.models import Region
from tests.conftest import TokenFactory, auth
from tests.fakes import FakeIdentity, FakeStorage

pytestmark = pytest.mark.usefixtures("seeded")

DOC_TYPES = ("driving_license", "vehicle_registration", "insurance_oc", "driver_photo")
VEHICLE = {"make": "Skoda", "model": "Octavia", "color": "szary", "plate": "kwi 12345", "seats": 4}


@pytest.fixture
def storage() -> Iterator[FakeStorage]:
    fake = FakeStorage()
    app.dependency_overrides[get_storage_or_503] = lambda: fake
    yield fake
    app.dependency_overrides.pop(get_storage_or_503, None)


@pytest.fixture
def identity() -> Iterator[FakeIdentity]:
    fake = FakeIdentity()
    app.dependency_overrides[get_identity_admin_or_503] = lambda: fake
    yield fake
    app.dependency_overrides.pop(get_identity_admin_or_503, None)


@pytest.fixture
def applicant(make_token: TokenFactory) -> dict[str, str]:
    return auth(make_token(sub="applicant-1", client="driver-app", name="Adam Kierowca"))


async def region_id(name: str = "Gmina Wieliczka") -> str:
    async with get_sessionmaker()() as session:
        from sqlalchemy import select

        rid = (await session.execute(select(Region.id).where(Region.name == name))).scalar_one()
    return str(rid)


async def apply(client: AsyncClient, headers: dict[str, str], **body: Any) -> Any:
    body.setdefault("region_id", await region_id())
    body.setdefault("vehicle", VEHICLE)
    response = await client.put("/drivers/me/application", headers=headers, json=body)
    assert response.status_code == 200, response.text
    return response.json()


async def upload(
    client: AsyncClient, headers: dict[str, str], storage: FakeStorage, doc_type: str, **extra: Any
) -> Any:
    slot = await client.post(
        "/drivers/me/documents",
        headers=headers,
        json={"type": doc_type, "content_type": "image/jpeg", "size_bytes": 1000, **extra},
    )
    assert slot.status_code == 201, slot.text
    document_id = slot.json()["document_id"]
    path = slot.json()["upload_url"].removeprefix("https://blob.test/").split("?")[0]
    storage.uploaded.add(path)
    done = await client.post(f"/drivers/me/documents/{document_id}/complete", headers=headers)
    assert done.status_code == 200, done.text
    return done.json()


async def submitted(client: AsyncClient, headers: dict[str, str], storage: FakeStorage) -> Any:
    await apply(client, headers)
    for doc_type in DOC_TYPES:
        await upload(client, headers, storage, doc_type)
    response = await client.post("/drivers/me/application/submit", headers=headers)
    assert response.status_code == 200, response.text
    return response.json()


async def test_full_application_flow(
    client: AsyncClient, applicant: dict[str, str], storage: FakeStorage
) -> None:
    assert (await client.get("/drivers/me", headers=applicant)).status_code == 404

    profile = await apply(client, applicant)
    assert profile["status"] == "draft"
    assert profile["vehicle"]["plate"] == "KWI12345"  # normalised
    assert profile["online"] is False and profile["documents"] == []

    slot = await client.post(
        "/drivers/me/documents",
        headers=applicant,
        json={"type": "driving_license", "content_type": "image/png", "size_bytes": 2048},
    )
    assert slot.status_code == 201
    assert slot.json()["required_headers"]["x-ms-blob-type"] == "BlockBlob"
    not_yet = await client.post(
        f"/drivers/me/documents/{slot.json()['document_id']}/complete", headers=applicant
    )
    assert not_yet.status_code == 409  # file not in storage yet

    missing = await client.post("/drivers/me/application/submit", headers=applicant)
    assert missing.status_code == 422
    assert "driving_license" in missing.json()["detail"]

    for doc_type in DOC_TYPES:
        doc = await upload(client, applicant, storage, doc_type)
        assert doc["status"] == "uploaded" and doc["uploaded_at"] is not None

    response = await client.post("/drivers/me/application/submit", headers=applicant)
    assert response.status_code == 200
    assert response.json()["status"] == "pending"
    assert len(response.json()["documents"]) == 4

    # Locked while waiting for the admin.
    assert (
        await client.put(
            "/drivers/me/application",
            headers=applicant,
            json={"region_id": await region_id(), "vehicle": VEHICLE},
        )
    ).status_code == 409
    again = await client.post(
        "/drivers/me/documents",
        headers=applicant,
        json={"type": "driver_photo", "content_type": "image/jpeg", "size_bytes": 10},
    )
    assert again.status_code == 409
    resubmit = await client.post("/drivers/me/application/submit", headers=applicant)
    assert resubmit.status_code == 409


async def test_reupload_replaces_previous_document(
    client: AsyncClient, applicant: dict[str, str], storage: FakeStorage
) -> None:
    await apply(client, applicant)
    first = await upload(client, applicant, storage, "insurance_oc")
    second = await upload(client, applicant, storage, "insurance_oc")
    profile = (await client.get("/drivers/me", headers=applicant)).json()
    assert [d["id"] for d in profile["documents"]] == [second["id"]]
    assert first["id"] != second["id"]


async def test_application_validation(
    client: AsyncClient, applicant: dict[str, str], storage: FakeStorage
) -> None:
    unknown = await client.put(
        "/drivers/me/application",
        headers=applicant,
        json={"region_id": "00000000-0000-0000-0000-000000000000", "vehicle": VEHICLE},
    )
    assert unknown.status_code == 422

    no_profile = await client.post(
        "/drivers/me/documents",
        headers=applicant,
        json={"type": "driver_photo", "content_type": "image/jpeg", "size_bytes": 10},
    )
    assert no_profile.status_code == 404

    await apply(client, applicant)
    for body in (
        {"type": "driver_photo", "content_type": "image/gif", "size_bytes": 10},
        {"type": "driver_photo", "content_type": "image/jpeg", "size_bytes": 11 * 1024 * 1024},
        {
            "type": "insurance_oc",
            "content_type": "application/pdf",
            "size_bytes": 10,
            "expires_on": (date.today() - timedelta(days=1)).isoformat(),
        },
    ):
        response = await client.post("/drivers/me/documents", headers=applicant, json=body)
        assert response.status_code == 422, body


async def test_cannot_confirm_someone_elses_document(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    make_token: TokenFactory,
) -> None:
    await apply(client, applicant)
    doc = await upload(client, applicant, storage, "driver_photo")
    other = auth(make_token(sub="other-applicant"))
    response = await client.post(f"/drivers/me/documents/{doc['id']}/complete", headers=other)
    assert response.status_code == 404


async def test_admin_approves_and_role_is_granted(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    identity: FakeIdentity,
    admin_headers: dict[str, str],
) -> None:
    await submitted(client, applicant, storage)

    pending = (await client.get("/admin/drivers?status=pending", headers=admin_headers)).json()
    assert [d["user_id"] for d in pending["items"]] == ["applicant-1"]
    assert pending["items"][0]["full_name"] == "Adam Kierowca"
    assert pending["items"][0]["submitted_at"] is not None
    other_region = await region_id("Gmina Niepołomice")
    none = (
        await client.get(f"/admin/drivers?region_id={other_region}", headers=admin_headers)
    ).json()
    assert none["total"] == 0

    response = await client.post("/admin/drivers/applicant-1/approve", headers=admin_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "approved" and body["approved_at"] is not None
    assert {d["status"] for d in body["documents"]} == {"accepted"}
    assert identity.granted == [("applicant-1", "driver")]

    again = await client.post("/admin/drivers/applicant-1/approve", headers=admin_headers)
    assert again.status_code == 409


async def test_keycloak_failure_keeps_application_pending(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    identity: FakeIdentity,
    admin_headers: dict[str, str],
) -> None:
    await submitted(client, applicant, storage)
    identity.fail = True
    response = await client.post("/admin/drivers/applicant-1/approve", headers=admin_headers)
    assert response.status_code == 502
    details = (await client.get("/admin/drivers/applicant-1", headers=admin_headers)).json()
    assert details["status"] == "pending"


async def test_rejected_application_can_be_corrected(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    admin_headers: dict[str, str],
) -> None:
    await submitted(client, applicant, storage)
    response = await client.post(
        "/admin/drivers/applicant-1/reject",
        headers=admin_headers,
        json={"reason": "Nieczytelne prawo jazdy"},
    )
    assert response.json()["status"] == "rejected"
    mine = (await client.get("/drivers/me", headers=applicant)).json()
    assert mine["rejection_reason"] == "Nieczytelne prawo jazdy"

    corrected = await apply(client, applicant)
    assert corrected["status"] == "draft"
    await upload(client, applicant, storage, "driving_license")
    resubmitted = await client.post("/drivers/me/application/submit", headers=applicant)
    assert resubmitted.json()["status"] == "pending"
    assert resubmitted.json()["rejection_reason"] is None


async def test_suspension_takes_effect_immediately(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    identity: FakeIdentity,
    admin_headers: dict[str, str],
    make_token: TokenFactory,
) -> None:
    await submitted(client, applicant, storage)
    cannot = await client.post(
        "/admin/drivers/applicant-1/suspend", headers=admin_headers, json={"reason": "Skargi"}
    )
    assert cannot.status_code == 409  # only approved drivers
    await client.post("/admin/drivers/applicant-1/approve", headers=admin_headers)

    driver = make_token(sub="applicant-1", roles=("passenger", "driver"), client="driver-app")
    from app.core.security import get_token_verifier

    principal = await get_token_verifier().verify(driver)
    async with get_sessionmaker()() as session:
        assert (await service.require_approved_driver(session, principal)).status == "approved"

    response = await client.post(
        "/admin/drivers/applicant-1/suspend", headers=admin_headers, json={"reason": "Skargi"}
    )
    assert response.json()["status"] == "suspended"
    assert response.json()["rejection_reason"] == "Skargi"

    # The token still has the `driver` role, but the database says no.
    from fastapi import HTTPException

    async with get_sessionmaker()() as session:
        with pytest.raises(HTTPException) as exc:
            await service.require_approved_driver(session, principal)
    assert exc.value.status_code == 403

    # Re-activation by approving again.
    back = await client.post("/admin/drivers/applicant-1/approve", headers=admin_headers)
    assert back.json()["status"] == "approved"


async def test_document_view_url(
    client: AsyncClient,
    applicant: dict[str, str],
    storage: FakeStorage,
    admin_headers: dict[str, str],
) -> None:
    await apply(client, applicant)
    doc = await upload(client, applicant, storage, "driver_photo")
    url = await client.get(
        f"/admin/drivers/applicant-1/documents/{doc['id']}/view-url", headers=admin_headers
    )
    assert url.status_code == 200
    assert url.json()["url"].endswith("?sp=r")

    wrong_driver = await client.get(
        f"/admin/drivers/someone/documents/{doc['id']}/view-url", headers=admin_headers
    )
    assert wrong_driver.status_code == 404

    slot = await client.post(
        "/drivers/me/documents",
        headers=applicant,
        json={"type": "insurance_oc", "content_type": "application/pdf", "size_bytes": 10},
    )
    pending_upload = await client.get(
        f"/admin/drivers/applicant-1/documents/{slot.json()['document_id']}/view-url",
        headers=admin_headers,
    )
    assert pending_upload.status_code == 409


async def test_admin_driver_endpoints_require_admin(
    client: AsyncClient, applicant: dict[str, str]
) -> None:
    for method, path in [
        ("GET", "/admin/drivers"),
        ("GET", "/admin/drivers/x"),
        ("POST", "/admin/drivers/x/approve"),
        ("POST", "/admin/drivers/x/reject"),
        ("POST", "/admin/drivers/x/suspend"),
    ]:
        response = await client.request(method, path, headers=applicant, json={"reason": "abc"})
        assert response.status_code == 403, path


async def test_missing_driver_is_404(client: AsyncClient, admin_headers: dict[str, str]) -> None:
    assert (await client.get("/admin/drivers/nobody", headers=admin_headers)).status_code == 404


async def test_storage_must_be_configured(client: AsyncClient, applicant: dict[str, str]) -> None:
    await apply(client, applicant)
    response = await client.post(
        "/drivers/me/documents",
        headers=applicant,
        json={"type": "driver_photo", "content_type": "image/jpeg", "size_bytes": 10},
    )
    assert response.status_code == 503
