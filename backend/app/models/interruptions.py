import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID
from app.models.enums import InterruptionReasonCategory


class Interruption(Base):
    __tablename__ = "interruptions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    focus_session_id = Column(GUID, ForeignKey("focus_sessions.id", ondelete="CASCADE"), nullable=False, index=True)
    interruption_time = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    reason_text = Column(Text, nullable=False)
    reason_category = Column(SAEnum(InterruptionReasonCategory), default=InterruptionReasonCategory.OTHER, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    focus_session = relationship("FocusSession", back_populates="interruptions")
