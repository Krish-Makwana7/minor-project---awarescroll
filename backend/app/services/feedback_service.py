import uuid
from datetime import datetime, timezone
from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.feedback import Feedback
from app.models.usage_sessions import UsageSession
from app.models.behavioral_events import BehavioralEvent
from app.models.enums import EventSource
from app.schemas.feedback import FeedbackCreate


class FeedbackService:
    @staticmethod
    def create_feedback(db: Session, user_id: uuid.UUID, feedback_in: FeedbackCreate) -> Feedback:
        usage_session = db.query(UsageSession).filter(
            UsageSession.id == feedback_in.usage_session_id,
            UsageSession.user_id == user_id
        ).first()

        if not usage_session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usage session not found.")

        # Check if feedback already recorded for this session
        existing = db.query(Feedback).filter(Feedback.usage_session_id == feedback_in.usage_session_id).first()
        if existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Feedback already submitted for this session.")

        feedback = Feedback(
            usage_session_id=feedback_in.usage_session_id,
            original_intention=feedback_in.original_intention,
            continuation_motivation=feedback_in.continuation_motivation,
            content_type=feedback_in.content_type,
            delayed_planned_work=feedback_in.delayed_planned_work,
            mood_after=feedback_in.mood_after,
        )
        db.add(feedback)

        # Mirror event
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.AWARESCROLL,
            event_type="reflection_feedback_submitted",
            payload={
                "usage_session_id": str(feedback_in.usage_session_id),
                "continuation_motivation": feedback_in.continuation_motivation,
                "content_type": feedback_in.content_type,
                "delayed_planned_work": feedback_in.delayed_planned_work,
                "mood_after": feedback_in.mood_after,
            },
            occurred_at=datetime.now(timezone.utc),
        )
        db.add(event)

        db.commit()
        db.refresh(feedback)
        return feedback

    @staticmethod
    def get_feedback_for_session(db: Session, user_id: uuid.UUID, session_id: uuid.UUID) -> Feedback:
        usage_session = db.query(UsageSession).filter(
            UsageSession.id == session_id,
            UsageSession.user_id == user_id
        ).first()
        if not usage_session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usage session not found.")

        feedback = db.query(Feedback).filter(Feedback.usage_session_id == session_id).first()
        if not feedback:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Feedback not found for this session.")
        return feedback
