import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID
from app.models.enums import SessionType


class Intention(Base):
    __tablename__ = "intentions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    session_type = Column(SAEnum(SessionType), nullable=False)
    intended_duration_minutes = Column(Integer, nullable=False)
    intended_purpose = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="intentions")
    usage_sessions = relationship("UsageSession", back_populates="intention")
    focus_sessions = relationship("FocusSession", back_populates="intention")
