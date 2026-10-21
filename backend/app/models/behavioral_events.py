import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID, JSONBType
from app.models.enums import EventSource


class BehavioralEvent(Base):
    __tablename__ = "behavioral_events"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    event_source = Column(SAEnum(EventSource), nullable=False)
    event_type = Column(String(64), nullable=False)  # e.g. "intention_logged", "session_start", "limit_reached", "reflection_answered", "focus_started", "interrupted"
    payload = Column(JSONBType, default=dict, nullable=False)
    occurred_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False, index=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="behavioral_events")
