"""Address search proxied through the backend (the Google API key never reaches the apps)."""

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.common.schemas import GeoPoint, Lat, Lng, Place
from app.core.errors import Responses
from app.core.security import PrincipalDep
from app.modules.places.providers import PlacesProvider, PlacesUnavailableError, get_places_provider
from app.modules.places.schemas import PlaceSuggestion

router = APIRouter(prefix="/places", tags=["places"])

ProviderDep = Annotated[PlacesProvider, Depends(get_places_provider)]

UNAVAILABLE: Responses = {503: {"description": "Usługa adresów chwilowo niedostępna"}}
NOT_FOUND: Responses = {404: {"description": "Nie znaleziono adresu"}}

SessionToken = Annotated[
    str,
    Query(
        min_length=8,
        max_length=64,
        description="Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie)",
    ),
]


def _unavailable(exc: PlacesUnavailableError) -> HTTPException:
    return HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, "Address service unavailable")


@router.get(
    "/autocomplete",
    response_model=list[PlaceSuggestion],
    summary="Podpowiedzi adresów",
    responses=UNAVAILABLE,
)
async def autocomplete_places(
    principal: PrincipalDep,
    provider: ProviderDep,
    session_token: SessionToken,
    input: Annotated[str, Query(min_length=2, max_length=200)],
    lat: Annotated[Lat | None, Query()] = None,
    lng: Annotated[Lng | None, Query()] = None,
) -> list[PlaceSuggestion]:
    near = GeoPoint(lat=lat, lng=lng) if lat is not None and lng is not None else None
    try:
        return await provider.autocomplete(input, session_token, near)
    except PlacesUnavailableError as exc:
        raise _unavailable(exc) from exc


@router.get(
    "/reverse",
    response_model=Place,
    summary="Adres dla punktu na mapie",
    responses={**NOT_FOUND, **UNAVAILABLE},
)
async def reverse_geocode(
    principal: PrincipalDep,
    provider: ProviderDep,
    lat: Annotated[Lat, Query()],
    lng: Annotated[Lng, Query()],
) -> Place:
    try:
        place = await provider.reverse(GeoPoint(lat=lat, lng=lng))
    except PlacesUnavailableError as exc:
        raise _unavailable(exc) from exc
    if place is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No address for this point")
    return place


@router.get(
    "/{place_id}",
    response_model=Place,
    summary="Szczegóły podpowiedzi (współrzędne)",
    responses={**NOT_FOUND, **UNAVAILABLE},
)
async def get_place(
    principal: PrincipalDep, provider: ProviderDep, place_id: str, session_token: SessionToken
) -> Place:
    try:
        place = await provider.details(place_id, session_token)
    except PlacesUnavailableError as exc:
        raise _unavailable(exc) from exc
    if place is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Place not found")
    return place
