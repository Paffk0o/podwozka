"""Adapters for Azure Blob Storage and the Keycloak Admin API (no network)."""

import json
from datetime import timedelta
from typing import Any
from urllib.parse import parse_qs, urlsplit

import httpx
import pytest

from app.core import keycloak_admin
from app.core.config import get_settings
from app.core.keycloak_admin import IdentityAdminError, KeycloakAdmin, get_identity_admin
from app.modules.drivers.storage import (
    AzureBlobStorage,
    StorageNotConfiguredError,
    get_document_storage,
)

# Public, documented Azurite development account (not a secret).
AZURITE = (
    "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;"
    "AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;"
    "BlobEndpoint=http://azurite:10000/devstoreaccount1;"
)


def test_sas_links_are_scoped_and_use_the_public_address() -> None:
    storage = AzureBlobStorage(
        AZURITE, "docs", public_url="http://localhost:10000/devstoreaccount1"
    )
    upload = storage.upload_url("drivers/u1/d1", "image/jpeg", timedelta(minutes=15))
    parts = urlsplit(upload.url)
    assert f"{parts.scheme}://{parts.netloc}{parts.path}" == (
        "http://localhost:10000/devstoreaccount1/docs/drivers/u1/d1"
    )
    query = parse_qs(parts.query)
    assert query["sp"] == ["cw"]  # create + write only
    assert "sig" in query and "se" in query
    assert upload.headers == {"x-ms-blob-type": "BlockBlob", "Content-Type": "image/jpeg"}

    view, _ = storage.view_url("drivers/u1/d1", timedelta(minutes=5))
    assert parse_qs(urlsplit(view).query)["sp"] == ["r"]  # read only


def test_storage_requires_account_key_and_configuration(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    with pytest.raises(StorageNotConfiguredError):
        AzureBlobStorage(
            "BlobEndpoint=https://x.blob.core.windows.net/;SharedAccessSignature=sv=1", "docs"
        )
    get_document_storage.cache_clear()
    with pytest.raises(StorageNotConfiguredError):
        get_document_storage()
    monkeypatch.setattr(get_settings(), "azure_storage_connection_string", AZURITE)
    get_document_storage.cache_clear()
    assert isinstance(get_document_storage(), AzureBlobStorage)
    get_document_storage.cache_clear()


DRIVER_ROLE = {"id": "role-id", "name": "driver"}


def keycloak(available: list[dict[str, str]], assigned: list[dict[str, str]], **codes: int) -> Any:
    calls: list[tuple[str, str]] = []

    def handler(request: httpx.Request) -> httpx.Response:
        calls.append((request.method, request.url.path))
        if codes.get("network"):
            raise httpx.ConnectError("down")
        if request.url.path.endswith("/token"):
            assert b"grant_type=client_credentials" in request.content
            return httpx.Response(codes.get("token", 200), json={"access_token": "svc"})
        assert request.headers["Authorization"] == "Bearer svc"
        if request.url.path.endswith("/available"):
            return httpx.Response(codes.get("available_code", 200), json=available)
        if request.method == "GET":
            return httpx.Response(200, json=assigned)
        assert json.loads(request.content) == [DRIVER_ROLE]
        return httpx.Response(codes.get("mapping", 204))

    admin = KeycloakAdmin(
        "http://kc:8080", "podwozka", "podwozka-backend", "s", httpx.MockTransport(handler)
    )
    return admin, calls


async def test_keycloak_grants_role_with_manage_users_only() -> None:
    admin, calls = keycloak(available=[DRIVER_ROLE, {"name": "admin"}], assigned=[])
    await admin.grant_realm_role("user-1", "driver")
    mappings = "/admin/realms/podwozka/users/user-1/role-mappings/realm"
    assert calls == [
        ("POST", "/realms/podwozka/protocol/openid-connect/token"),
        ("GET", f"{mappings}/available"),
        ("POST", mappings),
    ]


async def test_keycloak_grant_is_idempotent() -> None:
    admin, calls = keycloak(available=[], assigned=[DRIVER_ROLE])
    await admin.grant_realm_role("user-1", "driver")
    assert [method for method, _ in calls] == ["POST", "GET", "GET"]  # no new mapping


@pytest.mark.parametrize(
    "codes", [{"token": 401}, {"available_code": 403}, {"mapping": 404}, {"network": 1}]
)
async def test_keycloak_errors(codes: dict[str, int]) -> None:
    admin, _ = keycloak(available=[DRIVER_ROLE], assigned=[], **codes)
    with pytest.raises(IdentityAdminError):
        await admin.grant_realm_role("u", "driver")


async def test_keycloak_unknown_role() -> None:
    admin, _ = keycloak(available=[], assigned=[])
    with pytest.raises(IdentityAdminError):
        await admin.grant_realm_role("u", "driver")


def test_keycloak_admin_configuration(monkeypatch: pytest.MonkeyPatch) -> None:
    get_identity_admin.cache_clear()
    with pytest.raises(IdentityAdminError):
        get_identity_admin()
    settings = get_settings()
    monkeypatch.setattr(settings, "keycloak_backend_client_secret", "s")
    get_identity_admin.cache_clear()
    assert isinstance(keycloak_admin.get_identity_admin(), KeycloakAdmin)
    get_identity_admin.cache_clear()
    # Base URL and realm are derived from the issuer unless an internal URL is given.
    assert settings.keycloak_realm == "podwozka"
    assert settings.keycloak_base_url == "http://keycloak.test"
    monkeypatch.setattr(settings, "keycloak_internal_url", "http://keycloak:8080")
    assert settings.keycloak_base_url == "http://keycloak:8080"
