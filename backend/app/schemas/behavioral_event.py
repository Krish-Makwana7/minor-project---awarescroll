import uuid
from datetime import datetime
from typing import Dict, Any
from pydantic import BaseModel, ConfigDict
from app.models.enums import EventSource


class BehavioralEventCreate(BaseModel):
    event_source: EventSource
    event_type: str
    payload: Dict[str, Any] = {}
    occurred_at: datetime


class BehavioralEventResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    event_source: EventSource
    event_type: str
    payload: Dict[str, Any]
    occurred_at: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
