from httpx import AsyncClient

from tests.conftest import TokenFactory, auth


async def test_profile_does_not_exist_before_first_upsert(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    response = await client.get("/me", headers=auth(make_token()))
    assert response.status_code == 404


async def test_upsert_creates_profile_from_token(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    token = make_token(sub="user-1", roles=("passenger", "offline_access"))
    response = await client.put("/me", headers=auth(token), json={})
    assert response.status_code == 200
    body = response.json()
    assert body == {
        "id": "user-1",
        "email": "jan@podwozka.test",
        "full_name": "Jan Kowalski",  # taken from the token on first login
        "phone": None,
        "phone_verified": False,
        "roles": ["passenger"],  # technical Keycloak roles are filtered out
    }
    again = await client.get("/me", headers=auth(token))
    assert again.json() == body


async def test_changing_phone_resets_verification(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    token = make_token(sub="user-2")
    await client.put("/me", headers=auth(token), json={"phone": "+48600100200"})
    response = await client.put(
        "/me", headers=auth(token), json={"full_name": "Anna Nowak", "phone": "+48600100300"}
    )
    body = response.json()
    assert body["phone"] == "+48600100300"
    assert body["full_name"] == "Anna Nowak"
    assert body["phone_verified"] is False


async def test_invalid_phone_is_rejected(client: AsyncClient, make_token: TokenFactory) -> None:
    response = await client.put("/me", headers=auth(make_token()), json={"phone": "600100200"})
    assert response.status_code == 422


async def test_users_cannot_see_each_other(client: AsyncClient, make_token: TokenFactory) -> None:
    await client.put("/me", headers=auth(make_token(sub="alice")), json={"full_name": "Alice"})
    response = await client.get("/me", headers=auth(make_token(sub="bob")))
    assert response.status_code == 404
