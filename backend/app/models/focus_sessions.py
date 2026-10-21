import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID


class FocusSession(Base):
    __tablename__ = "focus_sessions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    intention_id = Column(GUID, ForeignKey("intentions.id", ondelete="SET NULL"), nullable=True, index=True)
    task_category = Column(String(64), nullable=False)
    task_description = Column(String(255), nullable=False)
    planned_duration_minutes = Column(Integer, nullable=False)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)
    completed = Column(Boolean, default=False, nullable=False)
    interrupted = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="focus_sessions")
    intention = relationship("Intention", back_populates="focus_sessions")
    interruptions = relationship("Interruption", back_populates="focus_session", cascade="all, delete-orphan")
    work_evidence = relationship("WorkEvidence", back_populates="focus_session", cascade="all, delete-orphan")
