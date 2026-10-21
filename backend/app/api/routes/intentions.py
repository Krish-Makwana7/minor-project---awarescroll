import uuid
from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.intention import IntentionCreate, IntentionResponse
from app.services.intentions_service import IntentionsService
from app.models.enums import SessionType
from app.models.users import User

router = APIRouter(prefix="/intentions", tags=["Intentions"])


@router.post("", response_model=IntentionResponse, status_code=status.HTTP_201_CREATED)
def create_intention(
    intention_in: IntentionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return IntentionsService.create_intention(db, current_user.id, intention_in)


@router.get("", response_model=List[IntentionResponse])
def get_intentions(
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return IntentionsService.get_intentions(db, current_user.id, limit=limit)


@router.get("/latest", response_model=IntentionResponse)
def get_latest_intention(
    session_type: SessionType,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return IntentionsService.get_latest_intention(db, current_user.id, session_type)
