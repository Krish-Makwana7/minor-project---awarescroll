import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Boolean, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID
from app.models.enums import RecommendationType


class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    recommendation_type = Column(SAEnum(RecommendationType), nullable=False)
    recommendation_text = Column(Text, nullable=False)
    based_on_pattern = Column(Text, nullable=False)
    shown_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    accepted = Column(Boolean, nullable=True)  # True, False, or None if pending
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="recommendations")
