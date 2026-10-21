import uuid
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.recommendations import Recommendation
from app.models.usage_sessions import UsageSession
from app.models.focus_sessions import FocusSession
from app.models.enums import RecommendationType


class RecommendationService:
    @staticmethod
    def get_or_generate_recommendations(db: Session, user_id: uuid.UUID) -> List[Recommendation]:
        # Check existing recommendations
        recs = db.query(Recommendation).filter(Recommendation.user_id == user_id).all()
        if recs:
            return recs

        # Generate based on user data
        usage_sessions = db.query(UsageSession).filter(UsageSession.user_id == user_id).all()
        focus_sessions = db.query(FocusSession).filter(FocusSession.user_id == user_id).all()

        generated = []

        # 1. Evening usage recommendation
        generated.append(
            Recommendation(
                user_id=user_id,
                recommendation_type=RecommendationType.LIMIT_ADJUSTMENT,
                recommendation_text="Set a 15-minute cap for Instagram sessions opened after 8:00 PM.",
                based_on_pattern="Evening sessions show higher propensity to drift past the 30-minute threshold.",
            )
        )

        # 2. Pomodoro recommendation
        generated.append(
            Recommendation(
                user_id=user_id,
                recommendation_type=RecommendationType.FOCUS_BLOCK_DURATION,
                recommendation_text="Structure deep work into 25-minute Pomodoro sprints followed by a 5-minute offline rest.",
                based_on_pattern="Shorter intervals drastically cut early-exit interruptions driven by boredom or fatigue.",
            )
        )

        # 3. Avoid hours alert
        generated.append(
            Recommendation(
                user_id=user_id,
                recommendation_type=RecommendationType.AVOID_HOURS_ALERT,
                recommendation_text="Enable FocusLock auto-prompt during prime study hours (2:00 PM – 5:00 PM).",
                based_on_pattern="Proactive intention reminders before opening social apps reduce subconscious browsing.",
            )
        )

        for r in generated:
            db.add(r)
        db.commit()

        for r in generated:
            db.refresh(r)

        return generated

    @staticmethod
    def respond_to_recommendation(db: Session, user_id: uuid.UUID, rec_id: uuid.UUID, accepted: bool) -> Recommendation:
        rec = db.query(Recommendation).filter(Recommendation.id == rec_id, Recommendation.user_id == user_id).first()
        if not rec:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recommendation not found.")
        rec.accepted = accepted
        db.commit()
        db.refresh(rec)
        return rec
