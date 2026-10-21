from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.users import User
from app.schemas.user import UserCreate, UserLogin, Token, UserResponse
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token, decode_token


class AuthService:
    @staticmethod
    def register_user(db: Session, user_in: UserCreate) -> Token:
        existing_user = db.query(User).filter(User.email == user_in.email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email already exists.",
            )
        user = User(
            email=user_in.email,
            password_hash=get_password_hash(user_in.password),
            timezone=user_in.timezone,
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        access_token = create_access_token(user.id)
        refresh_token = create_refresh_token(user.id)
        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user),
        )

    @staticmethod
    def authenticate_user(db: Session, login_in: UserLogin) -> Token:
        user = db.query(User).filter(User.email == login_in.email).first()
        if not user or not verify_password(login_in.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password.",
            )

        access_token = create_access_token(user.id)
        refresh_token = create_refresh_token(user.id)
        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            user=UserResponse.model_validate(user),
        )

    @staticmethod
    def refresh_access_token(db: Session, refresh_token: str) -> Token:
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token.",
            )
        user_id = payload.get("sub")
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User no longer exists.",
            )

        new_access = create_access_token(user.id)
        new_refresh = create_refresh_token(user.id)
        return Token(
            access_token=new_access,
            refresh_token=new_refresh,
            user=UserResponse.model_validate(user),
        )
