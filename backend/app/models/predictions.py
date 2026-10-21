import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, Boolean, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from app.core.database import Base, GUID
from app.models.enums import ModelType, PredictionTarget


class Prediction(Base):
    __tablename__ = "predictions"

    id = Column(GUID, primary_key=True, default=uuid.uuid4)
    user_id = Column(GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    model_type = Column(SAEnum(ModelType), nullable=False)
    target = Column(SAEnum(PredictionTarget), nullable=False)
    predicted_probability = Column(Float, nullable=False)
    predicted_outcome = Column(Boolean, nullable=False)
    actual_outcome = Column(Boolean, nullable=True)
    model_version = Column(String(64), default="v1.0.0", nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="predictions")
