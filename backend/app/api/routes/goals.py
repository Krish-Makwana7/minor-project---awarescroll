import uuid
from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.schemas.goal import GoalCreate, GoalUpdate, GoalResponse
from app.services.goals_service import GoalsService
from app.models.users import User

router = APIRouter(prefix="/goals", tags=["Goals"])


@router.post("", response_model=GoalResponse, status_code=status.HTTP_201_CREATED)
def create_goal(goal_in: GoalCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return GoalsService.create_goal(db, current_user.id, goal_in)


@router.get("", response_model=List[GoalResponse])
def get_goals(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return GoalsService.get_goals(db, current_user.id)


@router.get("/{goal_id}", response_model=GoalResponse)
def get_goal(goal_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return GoalsService.get_goal(db, current_user.id, goal_id)


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(goal_id: uuid.UUID, goal_in: GoalUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return GoalsService.update_goal(db, current_user.id, goal_id, goal_in)


@router.delete("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_goal(goal_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    GoalsService.delete_goal(db, current_user.id, goal_id)
