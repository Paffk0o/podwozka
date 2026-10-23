from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import sentry_sdk
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.routing import APIRoute

from app.core.config import get_settings
from app.core.db import dispose_engine
from app.modules.admin.router import router as admin_router
from app.modules.drivers.router import router as drivers_router
from app.modules.payments.router import router as payments_router
from app.modules.places.router import router as places_router
from app.modules.pricing.router import router as quotes_router
from app.modules.realtime.ws import router as ws_router
from app.modules.regions.router import router as regions_router
from app.modules.rides.router import router as rides_router
from app.modules.system.router import router as system_router
from app.modules.users.router import router as me_router

API_VERSION = "1.0.0"


def _operation_id(route: APIRoute) -> str:
    """Stable operationIds = Python function names (used as method names in the Dart client)."""
    return route.name


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    yield
    await dispose_engine()


def create_app() -> FastAPI:
    settings = get_settings()
    if settings.sentry_dsn:
        sentry_sdk.init(dsn=settings.sentry_dsn, environment=settings.environment)

    app = FastAPI(
        title="Podwózka API",
        version=API_VERSION,
        description="Kontrakt v1. Kwoty w groszach. Autoryzacja: Bearer token z Keycloaka.",
        generate_unique_id_function=_operation_id,
        lifespan=lifespan,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    for router in (
        system_router,
        me_router,
        regions_router,
        places_router,
        quotes_router,
        rides_router,
        drivers_router,
        admin_router,
        payments_router,
        ws_router,
    ):
        app.include_router(router)
    return app


app = create_app()
