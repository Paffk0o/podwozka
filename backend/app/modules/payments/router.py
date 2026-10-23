"""Stripe webhooks — the ONLY source of truth for payment state.

Must: verify the `Stripe-Signature` header, be idempotent (store processed event ids),
handle payment_intent.amount_capturable_updated / succeeded / payment_failed / charge.refunded.
"""

from fastapi import APIRouter, Request, status

from app.core.errors import STUB_RESPONSES, not_implemented

router = APIRouter(prefix="/payments", tags=["payments"])


@router.post(
    "/stripe/webhook",
    status_code=status.HTTP_200_OK,
    summary="Webhook Stripe (bez autoryzacji JWT, weryfikacja podpisu)",
    responses=STUB_RESPONSES,
)
async def stripe_webhook(request: Request) -> None:
    not_implemented()
