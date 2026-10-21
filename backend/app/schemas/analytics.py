import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from app.models.enums import RecommendationType, ModelType, PredictionTarget


class AnalyticsSummaryResponse(BaseModel):
    uid: uuid.UUID
    range_days: int
    average_usage_duration_minutes: float
    usage_overrun_rate: float
    usage_continuation_rate: float
    focus_completion_rate: float
    focus_interruption_rate: float
    total_usage_sessions: int
    total_focus_sessions: int
    total_usage_minutes: float
    total_focus_minutes: float
    adherence_score: float  # Composite self-regulation score 0-100


class PatternItem(BaseModel):
    pattern: str
    confidence: float  # 0.0 to 1.0
    evidence_count: int
    category: str


class PatternResponse(BaseModel):
    uid: uuid.UUID
    patterns: List[PatternItem]


class PredictOverrunRequest(BaseModel):
    uid: Optional[uuid.UUID] = None
    intended_duration_minutes: int
    intended_purpose: Optional[str] = None
    time_of_day: Optional[str] = None  # morning, afternoon, evening, night


class PredictOverrunResponse(BaseModel):
    risk_score: float  # 0.0 to 1.0
    suggested_limit: int
    explanation: str
    model_version: str = "v1.0.0"


class PredictInterruptionRequest(BaseModel):
    uid: Optional[uuid.UUID] = None
    task_category: str
    task_description: Optional[str] = None
    planned_duration_minutes: int
    time_of_day: Optional[str] = None


class PredictInterruptionResponse(BaseModel):
    risk_score: float  # 0.0 to 1.0
    suggested_duration: int
    explanation: str
    model_version: str = "v1.0.0"


class RecommendationResponseItem(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    recommendation_type: RecommendationType
    recommendation_text: str
    based_on_pattern: str
    shown_at: datetime
    accepted: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)


class ExportResponse(BaseModel):
    uid: uuid.UUID
    download_url: str
    record_count: int
    format: str = "csv"
    generated_at: datetime
