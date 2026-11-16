from app.common.schemas import ApiModel


class PlaceSuggestion(ApiModel):
    place_id: str
    primary_text: str
    secondary_text: str | None
