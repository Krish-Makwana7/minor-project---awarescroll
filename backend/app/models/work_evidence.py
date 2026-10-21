import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID
from app.models.enums import WorkEvidenceVerificationStatus


class WorkEvidence(Base):
    __tablename__ = "work_evidence"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    focus_session_id = Column(GUID, ForeignKey("focus_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    image_url = Column(String(512), nullable=False)
    uploaded_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    verification_status = Column(
        SAEnum(WorkEvidenceVerificationStatus),
        default=WorkEvidenceVerificationStatus.SELF_REPORTED,
        nullable=False,
    )
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    focus_session = relationship("FocusSession", back_populates="work_evidence")
