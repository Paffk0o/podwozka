"""Keycloak Admin API, called with the service account of the confidential client
`podwozka-backend` (needs only `manage-users` / `view-users`, not `view-realm`)."""

from functools import lru_cache
from typing import Any, Protocol

import httpx
from fastapi import HTTPException, status

from app.core.config import get_settings


class IdentityAdminError(Exception):
    pass


class IdentityAdmin(Protocol):
    async def grant_realm_role(self, user_id: str, role: str) -> None: ...


class KeycloakAdmin:
    def __init__(
        self,
        base_url: str,
        realm: str,
        client_id: str,
        client_secret: str,
        transport: httpx.AsyncBaseTransport | None = None,
    ) -> None:
        self._base = base_url.rstrip("/")
        self._realm = realm
        self._client_id = client_id
        self._client_secret = client_secret
        self._transport = transport

    async def _token(self, client: httpx.AsyncClient) -> str:
        response = await client.post(
            f"{self._base}/realms/{self._realm}/protocol/openid-connect/token",
            data={
                "grant_type": "client_credentials",
                "client_id": self._client_id,
                "client_secret": self._client_secret,
            },
        )
        if response.status_code != 200:
            raise IdentityAdminError(f"service account login failed: {response.status_code}")
        token: str = response.json()["access_token"]
        return token

    async def grant_realm_role(self, user_id: str, role: str) -> None:
        """Idempotent. The role representation is taken from the roles still available to
        the user, so the service account does not need `view-realm`."""
        try:
            async with httpx.AsyncClient(timeout=10, transport=self._transport) as client:
                headers = {"Authorization": f"Bearer {await self._token(client)}"}
                mappings = (
                    f"{self._base}/admin/realms/{self._realm}/users/{user_id}/role-mappings/realm"
                )
                available = await client.get(f"{mappings}/available", headers=headers)
                if available.status_code != 200:
                    raise IdentityAdminError(f"available roles: HTTP {available.status_code}")
                matching: list[dict[str, Any]] = [
                    r for r in available.json() if r.get("name") == role
                ]
                if not matching:
                    assigned = await client.get(mappings, headers=headers)
                    if assigned.status_code == 200 and any(
                        r.get("name") == role for r in assigned.json()
                    ):
                        return  # already has the role
                    raise IdentityAdminError(f"role {role} does not exist")
                mapped = await client.post(mappings, headers=headers, json=matching)
                if mapped.status_code not in (200, 204):
                    raise IdentityAdminError(f"role mapping: HTTP {mapped.status_code}")
        except httpx.HTTPError as exc:
            raise IdentityAdminError(str(exc)) from exc


@lru_cache
def get_identity_admin() -> IdentityAdmin:
    settings = get_settings()
    if not settings.keycloak_backend_client_secret:
        raise IdentityAdminError("KEYCLOAK_BACKEND_CLIENT_SECRET is not set")
    return KeycloakAdmin(
        settings.keycloak_base_url,
        settings.keycloak_realm,
        settings.keycloak_backend_client_id,
        settings.keycloak_backend_client_secret,
    )


def get_identity_admin_or_503() -> IdentityAdmin:
    try:
        return get_identity_admin()
    except IdentityAdminError as exc:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE, "Keycloak service account is not configured"
        ) from exc
