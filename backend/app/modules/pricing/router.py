from fastapi import APIRouter, status

from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import PassengerDep
from app.modules.pricing.schemas import Quote, QuoteRequest

router = APIRouter(prefix="/quotes", tags=["quotes"])


@router.post(
    "",
    response_model=Quote,
    status_code=status.HTTP_201_CREATED,
    summary="Wycena kursu (cena z góry)",
    responses={
        **STUB_RESPONSES,
        422: {"description": "Punkt odbioru poza obsługiwanymi regionami"},
    },
)
async def create_quote(principal: PassengerDep, body: QuoteRequest) -> Quote:
    not_implemented()
