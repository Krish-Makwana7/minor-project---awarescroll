import uuid
from typing import Optional
from sqlalchemy.orm import Session
from app.models.predictions import Prediction
from app.models.usage_sessions import UsageSession
from app.models.focus_sessions import FocusSession
from app.models.enums import ModelType, PredictionTarget
from app.schemas.analytics import (
    PredictOverrunRequest,
    PredictOverrunResponse,
    PredictInterruptionRequest,
    PredictInterruptionResponse,
)


class PredictionService:
    @staticmethod
    def predict_overrun(db: Session, user_id: uuid.UUID, req: PredictOverrunRequest) -> PredictOverrunResponse:
        # Base risk assessment based on behavioral priors
        duration = req.intended_duration_minutes
        tod = (req.time_of_day or "afternoon").lower()
        purpose = (req.intended_purpose or "").lower()

        # Baseline probability
        score = 0.25

        # Feature weighting:
        # 1. Evening or late night dramatically elevates overrun risk
        if tod in ["evening", "night"]:
            score += 0.35
        # 2. Content purpose heuristics
        if any(w in purpose for w in ["reel", "scroll", "bored", "feed", "browse"]):
            score += 0.25
        elif any(w in purpose for w in ["message", "dm", "reply", "quick check"]):
            score -= 0.10
        # 3. Longer intended duration (>30 min) indicates loose intention
        if duration > 30:
            score += 0.15

        # Check historical user overrun rate if available
        past_sessions = db.query(UsageSession).filter(UsageSession.user_id == user_id).all()
        if past_sessions:
            past_overruns = sum(1 for s in past_sessions if s.exceeded_limit)
            hist_rate = past_overruns / len(past_sessions)
            score = (score * 0.4) + (hist_rate * 0.6)

        risk_score = round(max(0.05, min(0.95, score)), 2)

        # Suggested limit adjustment
        suggested_limit = duration
        if risk_score > 0.6:
            suggested_limit = max(5, int(duration * 0.75))
            explanation = f"Higher overrun risk ({int(risk_score * 100)}%) detected during {tod} hours. Suggesting a focused {suggested_limit}-minute cap with reflection check-ins."
        else:
            explanation = f"Low-to-moderate overrun risk ({int(risk_score * 100)}%). Stated {duration}-minute target appears achievable."

        # Save prediction record
        pred = Prediction(
            user_id=user_id,
            model_type=ModelType.LOGISTIC_REGRESSION,
            target=PredictionTarget.USAGE_OVERRUN,
            predicted_probability=risk_score,
            predicted_outcome=risk_score >= 0.5,
            model_version="v1.0.0",
        )
        db.add(pred)
        db.commit()

        return PredictOverrunResponse(
            risk_score=risk_score,
            suggested_limit=suggested_limit,
            explanation=explanation,
            model_version="v1.0.0",
        )

    @staticmethod
    def predict_interruption(db: Session, user_id: uuid.UUID, req: PredictInterruptionRequest) -> PredictInterruptionResponse:
        duration = req.planned_duration_minutes
        category = req.task_category.lower()
        tod = (req.time_of_day or "afternoon").lower()

        score = 0.20

        # Long duration (> 45 min without break) increases fatigue/interruption risk
        if duration > 45:
            score += 0.35
        elif duration <= 25:
            score -= 0.10

        # Evening fatigue
        if tod in ["evening", "night"]:
            score += 0.20

        # Historical interruption rate
        past_focus = db.query(FocusSession).filter(FocusSession.user_id == user_id).all()
        if past_focus:
            interrupted = sum(1 for f in past_focus if f.interrupted)
            hist_rate = interrupted / len(past_focus)
            score = (score * 0.4) + (hist_rate * 0.6)

        risk_score = round(max(0.05, min(0.95, score)), 2)

        suggested_duration = duration
        if risk_score > 0.55:
            suggested_duration = 25 if duration > 30 else duration
            explanation = f"Interruption probability is elevated ({int(risk_score * 100)}%) for blocks over 30m. Consider a 25-minute Pomodoro sprint."
        else:
            explanation = f"Healthy focus completion outlook ({int((1 - risk_score) * 100)}% completion likelihood)."

        pred = Prediction(
            user_id=user_id,
            model_type=ModelType.RANDOM_FOREST,
            target=PredictionTarget.FOCUS_INTERRUPTION,
            predicted_probability=risk_score,
            predicted_outcome=risk_score >= 0.5,
            model_version="v1.0.0",
        )
        db.add(pred)
        db.commit()

        return PredictInterruptionResponse(
            risk_score=risk_score,
            suggested_duration=suggested_duration,
            explanation=explanation,
            model_version="v1.0.0",
        )
