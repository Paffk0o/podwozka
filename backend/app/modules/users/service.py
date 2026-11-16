from sqlalchemy import delete, func, select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import Principal
from app.modules.users.models import DeviceToken, User
from app.modules.users.schemas import DeviceTokenIn, Me, MeUpsert


async def get_user(session: AsyncSession, user_id: str) -> User | None:
    user = await session.get(User, user_id)
    if user is None or user.deleted_at is not None:
        return None
    return user


async def upsert_me(session: AsyncSession, principal: Principal, data: MeUpsert) -> User:
    """Create the local profile on first login, or update it. Email always comes from the token."""
    user = await session.get(User, principal.sub)
    if user is None:
        user = User(id=principal.sub, phone_verified=False)
        session.add(user)
    user.email = principal.email
    if data.full_name is not None:
        user.full_name = data.full_name
    elif user.full_name is None:
        user.full_name = principal.name
    if data.phone is not None and data.phone != user.phone:
        user.phone = data.phone
        user.phone_verified = False
    user.deleted_at = None
    await session.commit()
    await session.refresh(user)
    return user


async def ensure_user(session: AsyncSession, principal: Principal) -> User:
    """The local profile, created from the token if the app never called PUT /me."""
    user = await session.get(User, principal.sub)
    if user is None:
        user = User(
            id=principal.sub, email=principal.email, full_name=principal.name, phone_verified=False
        )
        session.add(user)
        await session.flush()
    return user


def to_me(user: User, principal: Principal) -> Me:
    return Me(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        phone_verified=user.phone_verified,
        roles=sorted(principal.roles & {"passenger", "driver", "admin"}),
    )


async def register_device_token(
    session: AsyncSession, principal: Principal, data: DeviceTokenIn
) -> None:
    """Upsert by token: a phone that logs into another account moves its token there."""
    await ensure_user(session, principal)
    statement = insert(DeviceToken).values(
        token=data.token, user_id=principal.sub, platform=data.platform, app=data.app
    )
    await session.execute(
        statement.on_conflict_do_update(
            index_elements=[DeviceToken.token],
            set_={
                "user_id": statement.excluded.user_id,
                "platform": statement.excluded.platform,
                "app": statement.excluded.app,
                "updated_at": func.now(),
            },
        )
    )
    await session.commit()


async def device_tokens(session: AsyncSession, user_id: str) -> list[str]:
    result = await session.execute(select(DeviceToken.token).where(DeviceToken.user_id == user_id))
    return list(result.scalars())


async def forget_device_tokens(session: AsyncSession, tokens: list[str]) -> None:
    if tokens:
        await session.execute(delete(DeviceToken).where(DeviceToken.token.in_(tokens)))
        await session.commit()
