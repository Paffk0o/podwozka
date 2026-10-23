from fastapi import APIRouter

from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import PrincipalDep
from app.modules.regions.schemas import Region

router = APIRouter(prefix="/regions", tags=["regions"])


@router.get(
    "", response_model=list[Region], summary="Aktywne regiony (gminy)", responses=STUB_RESPONSES
)
async def list_regions(principal: PrincipalDep) -> list[Region]:
    not_implemented()
