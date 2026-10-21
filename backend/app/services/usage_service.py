import uuid
from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.usage_sessions import UsageSession
from app.models.intentions import Intention
from app.models.behavioral_events import BehavioralEvent
from app.models.enums import EventSource
from app.schemas.usage_session import UsageSessionCreate, UsageSessionUpdate


def calculate_time_of_day(dt: datetime) -> str:
    hour = dt.hour
    if 5 <= hour < 12:
        return "morning"
    elif 12 <= hour < 17:
        return "afternoon"
    elif 17 <= hour < 22:
        return "evening"
    else:
        return "night"


class UsageService:
    @staticmethod
    def create_session(db: Session, user_id: uuid.UUID, session_in: UsageSessionCreate) -> UsageSession:
        time_bucket = session_in.time_of_day_bucket or calculate_time_of_day(session_in.start_time)
        
        # Check intention
        exceeded = session_in.exceeded_limit
        if session_in.intention_id:
            intention = db.query(Intention).filter(Intention.id == session_in.intention_id).first()
            if intention and session_in.actual_duration_minutes > intention.intended_duration_minutes:
                exceeded = True

        session = UsageSession(
            user_id=user_id,
            intention_id=session_in.intention_id,
            start_time=session_in.start_time,
            end_time=session_in.end_time,
            actual_duration_minutes=session_in.actual_duration_minutes,
            exceeded_limit=exceeded,
            reminder_count=session_in.reminder_count,
            time_of_day_bucket=time_bucket,
        )
        db.add(session)

        # Mirror event
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.AWARESCROLL,
            event_type="usage_session_started",
            payload={
                "intention_id": str(session_in.intention_id) if session_in.intention_id else None,
                "start_time": session_in.start_time.isoformat(),
                "time_of_day_bucket": time_bucket,
            },
            occurred_at=session_in.start_time,
        )
        db.add(event)

        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def update_session(db: Session, user_id: uuid.UUID, session_id: uuid.UUID, session_in: UsageSessionUpdate) -> UsageSession:
        session = db.query(UsageSession).filter(UsageSession.id == session_id, UsageSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usage session not found.")

        if session_in.end_time is not None:
            session.end_time = session_in.end_time
            if session_in.actual_duration_minutes is None and session.start_time:
                diff_minutes = max(0.0, (session.end_time - session.start_time).total_seconds() / 60.0)
                session.actual_duration_minutes = round(diff_minutes, 2)

        if session_in.actual_duration_minutes is not None:
            session.actual_duration_minutes = session_in.actual_duration_minutes

        if session_in.reminder_count is not None:
            session.reminder_count = session_in.reminder_count

        if session_in.time_of_day_bucket is not None:
            session.time_of_day_bucket = session_in.time_of_day_bucket

        # Check overrun against intention
        if session.intention_id:
            intention = db.query(Intention).filter(Intention.id == session.intention_id).first()
            if intention and session.actual_duration_minutes > intention.intended_duration_minutes:
                session.exceeded_limit = True
        if session_in.exceeded_limit is not None:
            session.exceeded_limit = session_in.exceeded_limit

        # Record end/limit event
        event_type = "usage_limit_exceeded" if session.exceeded_limit else "usage_session_ended"
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.AWARESCROLL,
            event_type=event_type,
            payload={
                "session_id": str(session.id),
                "actual_duration_minutes": session.actual_duration_minutes,
                "exceeded_limit": session.exceeded_limit,
                "reminder_count": session.reminder_count,
            },
            occurred_at=session.end_time or datetime.now(timezone.utc),
        )
        db.add(event)

        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def get_sessions(db: Session, user_id: uuid.UUID, limit: int = 100) -> List[UsageSession]:
        return db.query(UsageSession).filter(UsageSession.user_id == user_id).order_by(UsageSession.start_time.desc()).limit(limit).all()

    @staticmethod
    def get_session(db: Session, user_id: uuid.UUID, session_id: uuid.UUID) -> UsageSession:
        session = db.query(UsageSession).filter(UsageSession.id == session_id, UsageSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usage session not found.")
        return session
