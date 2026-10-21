import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from app.schemas.interruption import InterruptionResponse
from app.schemas.work_evidence import WorkEvidenceResponse


class FocusSessionCreate(BaseModel):
    intention_id: Optional[uuid.UUID] = None
    task_category: str
    task_description: str
    planned_duration_minutes: int
    start_time: datetime
    end_time: Optional[datetime] = None
    completed: bool = False
    interrupted: bool = False


class FocusSessionUpdate(BaseModel):
    end_time: Optional[datetime] = None
    completed: Optional[bool] = None
    interrupted: Optional[bool] = None


class FocusSessionResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    intention_id: Optional[uuid.UUID] = None
    task_category: str
    task_description: str
    planned_duration_minutes: int
    start_time: datetime
    end_time: Optional[datetime] = None
    completed: bool
    interrupted: bool
    created_at: datetime
    interruptions: List[InterruptionResponse] = []
    work_evidence: List[WorkEvidenceResponse] = []

    model_config = ConfigDict(from_attributes=True)
