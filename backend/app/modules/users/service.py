from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import Principal
from app.modules.users.models import User
from app.modules.users.schemas import Me, MeUpsert


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


def to_me(user: User, principal: Principal) -> Me:
    return Me(
        id=user.id,
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        phone_verified=user.phone_verified,
        roles=sorted(principal.roles & {"passenger", "driver", "admin"}),
    )
