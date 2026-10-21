import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict
from app.models.enums import GoalType


class GoalBase(BaseModel):
    goal_type: GoalType
    target_value: float
    unit: str = "minutes"
    active: bool = True


class GoalCreate(GoalBase):
    pass


class GoalUpdate(BaseModel):
    target_value: Optional[float] = None
    unit: Optional[str] = None
    active: Optional[bool] = None


class GoalResponse(GoalBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
