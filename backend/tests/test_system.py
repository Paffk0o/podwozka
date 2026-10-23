from httpx import AsyncClient


async def test_health(client: AsyncClient) -> None:
    response = await client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "environment": "test"}


async def test_public_config_needs_no_auth(client: AsyncClient) -> None:
    response = await client.get("/config")
    assert response.status_code == 200
    assert response.json()["oidc_issuer"].endswith("/realms/podwozka")
