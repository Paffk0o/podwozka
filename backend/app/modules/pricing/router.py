from typing import Annotated

from fastapi import APIRouter, Depends, status

from app.core.db import SessionDep
from app.core.security import PassengerDep
from app.modules.pricing import service
from app.modules.pricing.routing import RoutingProvider, get_routing_provider
from app.modules.pricing.schemas import Quote, QuoteRequest

router = APIRouter(prefix="/quotes", tags=["quotes"])

RoutingDep = Annotated[RoutingProvider, Depends(get_routing_provider)]


@router.post(
    "",
    response_model=Quote,
    status_code=status.HTTP_201_CREATED,
    summary="Wycena kursu (cena z góry)",
    responses={
        422: {
            "description": "Punkt odbioru poza obsługiwanymi regionami, brak cennika, "
            "zły termin rezerwacji (30 min - 14 dni) albo cel zbyt blisko"
        },
    },
)
async def create_quote(
    principal: PassengerDep, session: SessionDep, routing: RoutingDep, body: QuoteRequest
) -> Quote:
    return await service.create_quote(session, principal, body, routing)
