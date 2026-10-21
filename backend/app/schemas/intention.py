import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.enums import SessionType


class IntentionBase(BaseModel):
    session_type: SessionType
    intended_duration_minutes: int = Field(gt=0, description="Intended duration in minutes")
    intended_purpose: Optional[str] = None


class IntentionCreate(IntentionBase):
    pass


class IntentionResponse(IntentionBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
