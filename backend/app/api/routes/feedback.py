import uuid
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.feedback import FeedbackCreate, FeedbackResponse
from app.services.feedback_service import FeedbackService
from app.models.users import User

router = APIRouter(prefix="/feedback", tags=["Behavioral Feedback Survey"])


@router.post("", response_model=FeedbackResponse, status_code=status.HTTP_201_CREATED)
def submit_reflection_feedback(
    feedback_in: FeedbackCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FeedbackService.create_feedback(db, current_user.id, feedback_in)


@router.get("/session/{session_id}", response_model=FeedbackResponse)
def get_feedback_for_session(
    session_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return FeedbackService.get_feedback_for_session(db, current_user.id, session_id)
