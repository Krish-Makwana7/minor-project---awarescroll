import uuid
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.goals import Goal
from app.models.behavioral_events import BehavioralEvent
from app.models.enums import EventSource
from app.schemas.goal import GoalCreate, GoalUpdate


class GoalsService:
    @staticmethod
    def create_goal(db: Session, user_id: uuid.UUID, goal_in: GoalCreate) -> Goal:
        goal = Goal(
            user_id=user_id,
            goal_type=goal_in.goal_type,
            target_value=goal_in.target_value,
            unit=goal_in.unit,
            active=goal_in.active,
        )
        db.add(goal)

        # Mirror event into behavioral_events
        event = BehavioralEvent(
            user_id=user_id,
            event_source=EventSource.AWARESCROLL if "instagram" in goal_in.goal_type.value else EventSource.FOCUSLOCK,
            event_type="goal_set",
            payload={
                "goal_type": goal_in.goal_type.value,
                "target_value": goal_in.target_value,
                "unit": goal_in.unit,
            },
            occurred_at=goal.created_at,
        )
        db.add(event)

        db.commit()
        db.refresh(goal)
        return goal

    @staticmethod
    def get_goals(db: Session, user_id: uuid.UUID) -> List[Goal]:
        return db.query(Goal).filter(Goal.user_id == user_id).all()

    @staticmethod
    def get_goal(db: Session, user_id: uuid.UUID, goal_id: uuid.UUID) -> Goal:
        goal = db.query(Goal).filter(Goal.id == goal_id, Goal.user_id == user_id).first()
        if not goal:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Goal not found.")
        return goal

    @staticmethod
    def update_goal(db: Session, user_id: uuid.UUID, goal_id: uuid.UUID, goal_in: GoalUpdate) -> Goal:
        goal = GoalsService.get_goal(db, user_id, goal_id)
        if goal_in.target_value is not None:
            goal.target_value = goal_in.target_value
        if goal_in.unit is not None:
            goal.unit = goal_in.unit
        if goal_in.active is not None:
            goal.active = goal_in.active
        db.commit()
        db.refresh(goal)
        return goal

    @staticmethod
    def delete_goal(db: Session, user_id: uuid.UUID, goal_id: uuid.UUID) -> None:
        goal = GoalsService.get_goal(db, user_id, goal_id)
        db.delete(goal)
        db.commit()
