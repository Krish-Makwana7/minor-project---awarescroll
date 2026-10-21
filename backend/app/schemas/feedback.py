import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class FeedbackCreate(BaseModel):
    usage_session_id: uuid.UUID
    original_intention: Optional[str] = None
    continuation_motivation: str
    content_type: str
    delayed_planned_work: bool = False
    mood_after: str


class FeedbackResponse(BaseModel):
    id: uuid.UUID
    usage_session_id: uuid.UUID
    original_intention: Optional[str] = None
    continuation_motivation: str
    content_type: str
    delayed_planned_work: bool
    mood_after: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
