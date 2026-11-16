"""Seed demo data (idempotent). Run from backend/: `uv run python scripts/seed.py`.

docker compose runs it automatically after migrations (service `migrate`).
"""

import asyncio
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.db import dispose_engine, get_sessionmaker
from app.seed import seed


async def main() -> None:
    try:
        async with get_sessionmaker()() as session:
            await seed(session)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    asyncio.run(main())
