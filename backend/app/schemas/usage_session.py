import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class UsageSessionCreate(BaseModel):
    intention_id: Optional[uuid.UUID] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    actual_duration_minutes: float = 0.0
    exceeded_limit: bool = False
    reminder_count: int = 0
    time_of_day_bucket: Optional[str] = None


class UsageSessionUpdate(BaseModel):
    end_time: Optional[datetime] = None
    actual_duration_minutes: Optional[float] = None
    exceeded_limit: Optional[bool] = None
    reminder_count: Optional[int] = None
    time_of_day_bucket: Optional[str] = None


class UsageSessionResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    intention_id: Optional[uuid.UUID] = None
    start_time: datetime
    end_time: Optional[datetime] = None
    actual_duration_minutes: float
    exceeded_limit: bool
    reminder_count: int
    time_of_day_bucket: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
