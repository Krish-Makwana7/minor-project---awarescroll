from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.analytics import (
    PredictOverrunRequest,
    PredictOverrunResponse,
    PredictInterruptionRequest,
    PredictInterruptionResponse,
)
from app.services.prediction_service import PredictionService
from app.models.users import User

router = APIRouter(prefix="/predict", tags=["Behavioral Intelligence Predictions"])


@router.post("/overrun", response_model=PredictOverrunResponse)
def predict_usage_overrun(
    req: PredictOverrunRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = req.uid if req.uid else current_user.id
    return PredictionService.predict_overrun(db, target_uid, req)


@router.post("/interruption", response_model=PredictInterruptionResponse)
def predict_focus_interruption(
    req: PredictInterruptionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_uid = req.uid if req.uid else current_user.id
    return PredictionService.predict_interruption(db, target_uid, req)
