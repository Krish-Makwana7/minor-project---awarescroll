import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID


class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    usage_session_id = Column(GUID, ForeignKey("usage_sessions.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    original_intention = Column(Text, nullable=True)
    continuation_motivation = Column(String(255), nullable=False)  # e.g., "boredom", "lost track of time", "interesting content", "habit"
    content_type = Column(String(255), nullable=False)             # e.g., "reels", "dm/chat", "explore", "stories"
    delayed_planned_work = Column(Boolean, default=False, nullable=False)
    mood_after = Column(String(64), nullable=False)               # e.g., "guilty", "neutral", "energized", "anxious", "satisfied"
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    usage_session = relationship("UsageSession", back_populates="feedback")
