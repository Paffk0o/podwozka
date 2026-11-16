from fastapi import APIRouter

from app.core.db import SessionDep
from app.core.security import PrincipalDep
from app.modules.regions import service
from app.modules.regions.schemas import Region

router = APIRouter(prefix="/regions", tags=["regions"])


@router.get("", response_model=list[Region], summary="Aktywne regiony (gminy)")
async def list_regions(principal: PrincipalDep, session: SessionDep) -> list[Region]:
    return [Region.model_validate(r) for r in await service.list_active(session)]
