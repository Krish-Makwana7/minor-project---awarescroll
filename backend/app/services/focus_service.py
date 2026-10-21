import uuid
from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.focus_sessions import FocusSession
from app.models.interruptions import Interruption
from app.models.work_evidence import WorkEvidence
from app.models.behavioral_events import BehavioralEvent
from app.models.enums import EventSource
from app.schemas.focus_session import FocusSessionCreate, FocusSessionUpdate
from app.schemas.interruption import InterruptionCreate
from app.schemas.work_evidence import WorkEvidenceCreate


class FocusService:
    @staticmethod
    def create_session(db: Session, user_id: uuid.UUID, session_in: FocusSessionCreate) -> FocusSession:
        session = FocusSession(
            user_id=user_id,
            intention_id=session_in.intention_id,
            task_category=session_in.task_category,
            task_description=session_in.task_description,
            planned_duration_minutes=session_in.planned_duration_minutes,
            start_time=session_in.start_time,
            end_time=session_in.end_time,
            completed=session_in.completed,
            interrupted=session_in.interrupted,
        )
        db.add(session)

        # Mirror event
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.FOCUSLOCK,
            event_type="focus_session_started",
            payload={
                "task_category": session_in.task_category,
                "planned_duration_minutes": session_in.planned_duration_minutes,
                "start_time": session_in.start_time.isoformat(),
            },
            occurred_at=session_in.start_time,
        )
        db.add(event)

        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def update_session(db: Session, user_id: uuid.UUID, session_id: uuid.UUID, session_in: FocusSessionUpdate) -> FocusSession:
        session = db.query(FocusSession).filter(FocusSession.id == session_id, FocusSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Focus session not found.")

        if session_in.end_time is not None:
            session.end_time = session_in.end_time
        if session_in.completed is not None:
            session.completed = session_in.completed
        if session_in.interrupted is not None:
            session.interrupted = session_in.interrupted

        event_type = "focus_session_completed" if session.completed else "focus_session_ended"
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.FOCUSLOCK,
            event_type=event_type,
            payload={
                "session_id": str(session.id),
                "completed": session.completed,
                "interrupted": session.interrupted,
                "task_category": session.task_category,
            },
            occurred_at=session.end_time or datetime.now(timezone.utc),
        )
        db.add(event)

        db.commit()
        db.refresh(session)
        return session

    @staticmethod
    def log_interruption(db: Session, user_id: uuid.UUID, session_id: uuid.UUID, inter_in: InterruptionCreate) -> Interruption:
        session = db.query(FocusSession).filter(FocusSession.id == session_id, FocusSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Focus session not found.")

        session.interrupted = True
        session.completed = False
        session.end_time = inter_in.interruption_time

        interruption = Interruption(
            focus_session_id=session.id,
            interruption_time=inter_in.interruption_time,
            reason_text=inter_in.reason_text,
            reason_category=inter_in.reason_category,
        )
        db.add(interruption)

        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.FOCUSLOCK,
            event_type="focus_session_interrupted",
            payload={
                "session_id": str(session.id),
                "reason_category": inter_in.reason_category.value,
                "reason_text": inter_in.reason_text,
            },
            occurred_at=inter_in.interruption_time,
        )
        db.add(event)

        db.commit()
        db.refresh(interruption)
        return interruption

    @staticmethod
    def add_work_evidence(db: Session, user_id: uuid.UUID, session_id: uuid.UUID, evidence_in: WorkEvidenceCreate) -> WorkEvidence:
        session = db.query(FocusSession).filter(FocusSession.id == session_id, FocusSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Focus session not found.")

        evidence = WorkEvidence(
            focus_session_id=session.id,
            image_url=evidence_in.image_url,
            verification_status=evidence_in.verification_status,
        )
        db.add(evidence)

        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.FOCUSLOCK,
            event_type="work_evidence_uploaded",
            payload={
                "session_id": str(session.id),
                "image_url": evidence_in.image_url,
                "verification_status": evidence_in.verification_status.value,
            },
            occurred_at=evidence.uploaded_at,
        )
        db.add(event)

        db.commit()
        db.refresh(evidence)
        return evidence

    @staticmethod
    def get_sessions(db: Session, user_id: uuid.UUID, limit: int = 100) -> List[FocusSession]:
        return db.query(FocusSession).filter(FocusSession.user_id == user_id).order_by(FocusSession.start_time.desc()).limit(limit).all()

    @staticmethod
    def get_session(db: Session, user_id: uuid.UUID, session_id: uuid.UUID) -> FocusSession:
        session = db.query(FocusSession).filter(FocusSession.id == session_id, FocusSession.user_id == user_id).first()
        if not session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Focus session not found.")
        return session
