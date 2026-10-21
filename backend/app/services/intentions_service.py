import uuid
from typing import List
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.intentions import Intention
from app.models.behavioral_events import BehavioralEvent
from app.models.enums import EventSource, SessionType
from app.schemas.intention import IntentionCreate


class IntentionsService:
    @staticmethod
    def create_intention(db: Session, user_id: uuid.UUID, intention_in: IntentionCreate) -> Intention:
        intention = Intention(
            user_id=user_id,
            session_type=intention_in.session_type,
            intended_duration_minutes=intention_in.intended_duration_minutes,
            intended_purpose=intention_in.intended_purpose,
        )
        db.add(intention)

        # Mirror event into behavioral_events
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.AWARESCROLL if intention_in.session_type == SessionType.INSTAGRAM else EventSource.FOCUSLOCK,
            event_type="intention_stated",
            payload={
                "session_type": intention_in.session_type.value,
                "intended_duration_minutes": intention_in.intended_duration_minutes,
                "intended_purpose": intention_in.intended_purpose,
            },
            occurred_at=intention.created_at,
        )
        db.add(event)

        db.commit()
        db.refresh(intention)
        return intention

    @staticmethod
    def get_intentions(db: Session, user_id: uuid.UUID, limit: int = 50) -> List[Intention]:
        return db.query(Intention).filter(Intention.user_id == user_id).order_by(Intention.created_at.desc()).limit(limit).all()

    @staticmethod
    def get_latest_intention(db: Session, user_id: uuid.UUID, session_type: SessionType) -> Intention:
        intention = (
            db.query(Intention)
            .filter(Intention.user_id == user_id, Intention.session_type == session_type)
            .order_by(Intention.created_at.desc())
            .first()
        )
        if not intention:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active intention found.")
        return intention
