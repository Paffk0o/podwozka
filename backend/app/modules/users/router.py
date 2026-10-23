from fastapi import APIRouter, HTTPException, status

from app.core.db import SessionDep
from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import PrincipalDep
from app.modules.users import service
from app.modules.users.schemas import (
    DeviceTokenIn,
    Me,
    MeUpsert,
    PhoneVerificationConfirm,
    PhoneVerificationRequest,
)

router = APIRouter(prefix="/me", tags=["me"])


@router.get(
    "",
    response_model=Me,
    summary="Mój profil",
    responses={
        404: {"description": "Profil nie istnieje — wywołaj PUT /me po pierwszym logowaniu"}
    },
)
async def get_me(principal: PrincipalDep, session: SessionDep) -> Me:
    user = await service.get_user(session, principal.sub)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Profile not found")
    return service.to_me(user, principal)


@router.put("", response_model=Me, summary="Utwórz lub zaktualizuj mój profil")
async def upsert_me(principal: PrincipalDep, session: SessionDep, body: MeUpsert) -> Me:
    user = await service.upsert_me(session, principal, body)
    return service.to_me(user, principal)


@router.delete(
    "",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Usuń konto (Keycloak + anonimizacja danych)",
    responses=STUB_RESPONSES,
)
async def delete_me(principal: PrincipalDep) -> None:
    not_implemented()


@router.post(
    "/phone/verification",
    status_code=status.HTTP_202_ACCEPTED,
    summary="Wyślij kod SMS na numer telefonu",
    responses=STUB_RESPONSES,
)
async def request_phone_verification(
    principal: PrincipalDep, body: PhoneVerificationRequest
) -> None:
    not_implemented()


@router.post(
    "/phone/verification/confirm",
    response_model=Me,
    summary="Potwierdź numer kodem z SMS",
    responses=STUB_RESPONSES,
)
async def confirm_phone_verification(principal: PrincipalDep, body: PhoneVerificationConfirm) -> Me:
    not_implemented()


@router.put(
    "/device-tokens",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Zarejestruj token push (FCM) urządzenia",
    responses=STUB_RESPONSES,
)
async def register_device_token(principal: PrincipalDep, body: DeviceTokenIn) -> None:
    not_implemented()
