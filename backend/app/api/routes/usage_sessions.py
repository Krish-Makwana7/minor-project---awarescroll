import uuid
from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.usage_session import UsageSessionCreate, UsageSessionUpdate, UsageSessionResponse
from app.services.usage_service import UsageService
from app.models.users import User

router = APIRouter(prefix="/usage-sessions", tags=["Instagram Usage Sessions"])


@router.post("", response_model=UsageSessionResponse, status_code=status.HTTP_201_CREATED)
def start_or_record_usage_session(
    session_in: UsageSessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return UsageService.create_session(db, current_user.id, session_in)


@router.get("", response_model=List[UsageSessionResponse])
def get_usage_sessions(
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return UsageService.get_sessions(db, current_user.id, limit=limit)


@router.get("/{session_id}", response_model=UsageSessionResponse)
def get_usage_session(
    session_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return UsageService.get_session(db, current_user.id, session_id)


@router.put("/{session_id}", response_model=UsageSessionResponse)
def update_usage_session(
    session_id: uuid.UUID,
    session_in: UsageSessionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return UsageService.update_session(db, current_user.id, session_id, session_in)
