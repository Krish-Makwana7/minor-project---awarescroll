import uuid
from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.focus_session import FocusSessionCreate, FocusSessionUpdate, FocusSessionResponse
from app.schemas.interruption import InterruptionCreate, InterruptionResponse
from app.schemas.work_evidence import WorkEvidenceCreate, WorkEvidenceResponse
from app.services.focus_service import FocusService
from app.models.users import User

router = APIRouter(prefix="/focus-sessions", tags=["FocusLock Sessions"])


@router.post("", response_model=FocusSessionResponse, status_code=status.HTTP_201_CREATED)
def start_focus_session(
    session_in: FocusSessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.create_session(db, current_user.id, session_in)


@router.get("", response_model=List[FocusSessionResponse])
def get_focus_sessions(
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.get_sessions(db, current_user.id, limit=limit)


@router.get("/{session_id}", response_model=FocusSessionResponse)
def get_focus_session(
    session_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.get_session(db, current_user.id, session_id)


@router.put("/{session_id}", response_model=FocusSessionResponse)
def update_focus_session(
    session_id: uuid.UUID,
    session_in: FocusSessionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.update_session(db, current_user.id, session_id, session_in)


@router.post("/{session_id}/interruptions", response_model=InterruptionResponse, status_code=status.HTTP_201_CREATED)
def log_session_interruption(
    session_id: uuid.UUID,
    interruption_in: InterruptionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.log_interruption(db, current_user.id, session_id, interruption_in)


@router.post("/{session_id}/evidence", response_model=WorkEvidenceResponse, status_code=status.HTTP_201_CREATED)
def add_work_evidence(
    session_id: uuid.UUID,
    evidence_in: WorkEvidenceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FocusService.add_work_evidence(db, current_user.id, session_id, evidence_in)
