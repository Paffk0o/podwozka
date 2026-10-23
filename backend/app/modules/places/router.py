"""Address search proxied through the backend (the Google API key never reaches the apps)."""

from typing import Annotated

from fastapi import APIRouter, Query

from app.common.schemas import ApiModel, Lat, Lng, Place
from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import PrincipalDep

router = APIRouter(prefix="/places", tags=["places"])


class PlaceSuggestion(ApiModel):
    place_id: str
    primary_text: str
    secondary_text: str | None


SessionToken = Annotated[
    str,
    Query(
        min_length=8,
        max_length=64,
        description="Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie)",
    ),
]


@router.get(
    "/autocomplete",
    response_model=list[PlaceSuggestion],
    summary="Podpowiedzi adresów",
    responses=STUB_RESPONSES,
)
async def autocomplete_places(
    principal: PrincipalDep,
    session_token: SessionToken,
    input: Annotated[str, Query(min_length=2, max_length=200)],
    lat: Annotated[Lat | None, Query()] = None,
    lng: Annotated[Lng | None, Query()] = None,
) -> list[PlaceSuggestion]:
    not_implemented()


@router.get(
    "/reverse",
    response_model=Place,
    summary="Adres dla punktu na mapie",
    responses=STUB_RESPONSES,
)
async def reverse_geocode(
    principal: PrincipalDep, lat: Annotated[Lat, Query()], lng: Annotated[Lng, Query()]
) -> Place:
    not_implemented()


@router.get(
    "/{place_id}",
    response_model=Place,
    summary="Szczegóły podpowiedzi (współrzędne)",
    responses=STUB_RESPONSES,
)
async def get_place(principal: PrincipalDep, place_id: str, session_token: SessionToken) -> Place:
    not_implemented()
