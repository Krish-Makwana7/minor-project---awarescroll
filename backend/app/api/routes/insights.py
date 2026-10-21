import uuid
from typing import Optional, List
from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.analytics import (
    AnalyticsSummaryResponse,
    PatternResponse,
    RecommendationResponseItem,
    ExportResponse,
)
from app.services.analytics_service import AnalyticsService
from app.services.recommendation_service import RecommendationService
from app.models.users import User

router = APIRouter(tags=["Analytics, Insights & Export"])


@router.get("/analytics/summary", response_model=AnalyticsSummaryResponse)
def get_analytics_summary(
    uid: Optional[uuid.UUID] = Query(None, description="Optional user ID filter"),
    range_days: int = Query(30, alias="range", description="Date range in days (default 30)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = uid if uid else current_user.id
    return AnalyticsService.get_summary(db, target_uid, range_days=range_days)


@router.get("/analytics/patterns", response_model=PatternResponse)
def get_behavioral_patterns(
    uid: Optional[uuid.UUID] = Query(None, description="Optional user ID filter"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = uid if uid else current_user.id
    return AnalyticsService.get_patterns(db, target_uid)


@router.get("/recommendations", response_model=List[RecommendationResponseItem])
def get_recommendations(
    uid: Optional[uuid.UUID] = Query(None, description="Optional user ID filter"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = uid if uid else current_user.id
    return RecommendationService.get_or_generate_recommendations(db, target_uid)


@router.post("/recommendations/{recommendation_id}/respond", response_model=RecommendationResponseItem)
def respond_to_recommendation(
    recommendation_id: uuid.UUID,
    accepted: bool = Query(..., description="Whether user accepted or declined recommendation"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return RecommendationService.respond_to_recommendation(db, current_user.id, recommendation_id, accepted)


@router.get("/export")
def export_behavioral_dataset_csv(
    uid: Optional[uuid.UUID] = Query(None, description="Optional user ID filter"),
    format: str = Query("csv", description="Export format (csv)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = uid if uid else current_user.id
    csv_content, record_count = AnalyticsService.generate_csv_export(db, target_uid)
    filename = f"awarescroll_focuslock_export_{target_uid}_{datetime_stamp()}.csv"
    
    return Response(
        content=csv_content,
        media_type="text/csv",
        headers={
            "Content-Disposition": f"attachment; filename={filename}",
            "X-Record-Count": str(record_count),
        },
    )


def datetime_stamp():
    from datetime import datetime, timezone
    return datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
