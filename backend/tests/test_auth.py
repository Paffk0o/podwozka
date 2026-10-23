from typing import Any

import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from httpx import AsyncClient

from app.core.security import JwksCache, TokenError
from tests.conftest import TokenFactory, auth


async def test_missing_token_is_401(client: AsyncClient) -> None:
    response = await client.get("/me")
    assert response.status_code == 401
    assert response.headers["www-authenticate"].startswith("Bearer")


@pytest.mark.parametrize(
    "overrides",
    [
        pytest.param({"audience": "some-other-api"}, id="wrong-audience"),
        pytest.param({"issuer": "http://evil.example/realms/podwozka"}, id="wrong-issuer"),
        pytest.param({"expires_in": -120}, id="expired"),
        pytest.param({"client": "unknown-client"}, id="client-not-allowed"),
        pytest.param({"kid": "unknown-kid"}, id="unknown-kid"),
        pytest.param(
            {"key": rsa.generate_private_key(public_exponent=65537, key_size=2048)},
            id="bad-signature",
        ),
    ],
)
async def test_invalid_tokens_are_rejected(
    client: AsyncClient, make_token: TokenFactory, overrides: dict[str, Any]
) -> None:
    response = await client.get("/me", headers=auth(make_token(**overrides)))
    assert response.status_code == 401


async def test_garbage_token_is_401(client: AsyncClient) -> None:
    response = await client.get("/me", headers=auth("not-a-jwt"))
    assert response.status_code == 401


async def test_passenger_cannot_use_admin_endpoints(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    response = await client.get("/admin/regions", headers=auth(make_token(roles=("passenger",))))
    assert response.status_code == 403


async def test_passenger_cannot_use_driver_endpoints(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    response = await client.get(
        "/drivers/me/current", headers=auth(make_token(roles=("passenger",)))
    )
    assert response.status_code == 403


async def test_admin_role_passes_to_stub(client: AsyncClient, make_token: TokenFactory) -> None:
    token = make_token(roles=("admin",), client="admin-panel")
    response = await client.get("/admin/regions", headers=auth(token))
    assert response.status_code == 501  # authorized; feature not built yet


async def test_jwks_cache_refetches_on_key_rotation() -> None:
    calls = 0
    keysets: list[dict[str, Any]] = [{"keys": []}, {"keys": []}]

    async def fetch() -> dict[str, Any]:
        nonlocal calls
        calls += 1
        return keysets[min(calls - 1, 1)]

    cache = JwksCache(fetch, min_refresh=0)
    with pytest.raises(TokenError):
        await cache.get_key("rotated")
    with pytest.raises(TokenError):
        await cache.get_key("rotated")
    assert calls == 2  # unknown kid triggered a second fetch


async def test_jwks_cache_rate_limits_refetch() -> None:
    calls = 0

    async def fetch() -> dict[str, Any]:
        nonlocal calls
        calls += 1
        return {"keys": []}

    cache = JwksCache(fetch, min_refresh=60)
    for _ in range(3):
        with pytest.raises(TokenError):
            await cache.get_key("missing")
    assert calls == 1  # an attacker sending random kids cannot hammer Keycloak
