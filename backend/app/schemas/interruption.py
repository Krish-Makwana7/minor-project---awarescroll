import uuid
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.models.enums import InterruptionReasonCategory


class InterruptionCreate(BaseModel):
    interruption_time: datetime
    reason_text: str
    reason_category: InterruptionReasonCategory = InterruptionReasonCategory.OTHER


class InterruptionResponse(BaseModel):
    id: uuid.UUID
    focus_session_id: uuid.UUID
    interruption_time: datetime
    reason_text: str
    reason_category: InterruptionReasonCategory
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
