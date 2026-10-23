from typing import Any, NoReturn

from fastapi import HTTPException, status


def not_implemented() -> NoReturn:
    """Placeholder for endpoints that are part of the v1 contract but not built yet."""
    raise HTTPException(status.HTTP_501_NOT_IMPLEMENTED, "Not implemented yet")


Responses = dict[int | str, dict[str, Any]]

STUB_RESPONSES: Responses = {501: {"description": "Jeszcze nie zaimplementowane"}}
