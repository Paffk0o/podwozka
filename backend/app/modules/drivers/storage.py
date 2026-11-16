"""Driver documents in Azure Blob Storage (locally: Azurite), behind an interface.

The apps upload files directly to Blob Storage with a short-lived, write-only SAS link; admins
view them with a short-lived, read-only SAS link. The container is private.
"""

import asyncio
import contextlib
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from functools import lru_cache
from typing import Protocol

from azure.core.exceptions import ResourceExistsError
from azure.storage.blob import BlobSasPermissions, BlobServiceClient, generate_blob_sas
from fastapi import HTTPException, status

from app.core.config import get_settings


@dataclass(frozen=True, slots=True)
class SignedUpload:
    url: str
    headers: dict[str, str]
    expires_at: datetime


class StorageNotConfiguredError(Exception):
    pass


class DocumentStorage(Protocol):
    def upload_url(self, path: str, content_type: str, ttl: timedelta) -> SignedUpload: ...

    def view_url(self, path: str, ttl: timedelta) -> tuple[str, datetime]: ...

    async def exists(self, path: str) -> bool: ...

    async def ensure_container(self) -> None: ...


class AzureBlobStorage:
    def __init__(
        self, connection_string: str, container: str, public_url: str | None = None
    ) -> None:
        self._client = BlobServiceClient.from_connection_string(connection_string)
        self._container = container
        account_key = getattr(self._client.credential, "account_key", None)
        if not account_key:
            raise StorageNotConfiguredError("Connection string must contain AccountKey")
        self._account_key: str = account_key
        # Links go to the apps: inside Docker the API reaches Azurite at http://azurite:10000,
        # but phones/browsers need the public address (e.g. http://localhost:10000/...).
        self._public_url = (public_url or self._client.url).rstrip("/")
        self._container_ready = False

    def _signed(self, path: str, permission: BlobSasPermissions, expires_at: datetime) -> str:
        sas = generate_blob_sas(
            account_name=self._client.account_name or "",
            container_name=self._container,
            blob_name=path,
            account_key=self._account_key,
            permission=permission,
            expiry=expires_at,
            start=datetime.now(UTC) - timedelta(minutes=2),  # tolerate clock skew
        )
        return f"{self._public_url}/{self._container}/{path}?{sas}"

    def upload_url(self, path: str, content_type: str, ttl: timedelta) -> SignedUpload:
        expires_at = datetime.now(UTC) + ttl
        url = self._signed(path, BlobSasPermissions(create=True, write=True), expires_at)
        headers = {"x-ms-blob-type": "BlockBlob", "Content-Type": content_type}
        return SignedUpload(url=url, headers=headers, expires_at=expires_at)

    def view_url(self, path: str, ttl: timedelta) -> tuple[str, datetime]:
        expires_at = datetime.now(UTC) + ttl
        return self._signed(path, BlobSasPermissions(read=True), expires_at), expires_at

    async def exists(self, path: str) -> bool:
        blob = self._client.get_blob_client(self._container, path)
        return bool(await asyncio.to_thread(blob.exists))

    async def ensure_container(self) -> None:
        """Create the private container on first use (once per process)."""
        if self._container_ready:
            return
        container = self._client.get_container_client(self._container)
        with contextlib.suppress(ResourceExistsError):
            await asyncio.to_thread(container.create_container)
        self._container_ready = True


@lru_cache
def get_document_storage() -> DocumentStorage:
    settings = get_settings()
    if not settings.azure_storage_connection_string:
        raise StorageNotConfiguredError("AZURE_STORAGE_CONNECTION_STRING is not set")
    return AzureBlobStorage(
        settings.azure_storage_connection_string,
        settings.azure_storage_container,
        settings.azure_storage_public_url,
    )


STORAGE_UNAVAILABLE: dict[int | str, dict[str, str]] = {
    503: {"description": "Magazyn dokumentów nie jest skonfigurowany"}
}


def get_storage_or_503() -> DocumentStorage:
    try:
        return get_document_storage()
    except StorageNotConfiguredError as exc:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE, "Document storage is not configured"
        ) from exc
