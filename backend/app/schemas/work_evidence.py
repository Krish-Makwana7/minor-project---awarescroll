import uuid
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.models.enums import WorkEvidenceVerificationStatus


class WorkEvidenceCreate(BaseModel):
    image_url: str
    verification_status: WorkEvidenceVerificationStatus = WorkEvidenceVerificationStatus.SELF_REPORTED


class WorkEvidenceResponse(BaseModel):
    id: uuid.UUID
    focus_session_id: uuid.UUID
    image_url: str
    uploaded_at: datetime
    verification_status: WorkEvidenceVerificationStatus
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
