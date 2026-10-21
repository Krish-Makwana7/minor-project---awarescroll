import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID


class UsageSession(Base):
    __tablename__ = "usage_sessions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    intention_id = Column(GUID, ForeignKey("intentions.id", ondelete="SET NULL"), nullable=True, index=True)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)
    actual_duration_minutes = Column(Float, default=0.0, nullable=False)
    exceeded_limit = Column(Boolean, default=False, nullable=False)
    reminder_count = Column(Integer, default=0, nullable=False)
    time_of_day_bucket = Column(String(32), nullable=True)  # e.g. morning, afternoon, evening, night
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="usage_sessions")
    intention = relationship("Intention", back_populates="usage_sessions")
    feedback = relationship("Feedback", back_populates="usage_session", uselist=False, cascade="all, delete-orphan")
