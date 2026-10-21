from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "AwareScroll AI + FocusLock API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # Database
    DATABASE_URL: str = "sqlite:///./awarescroll.db"
    
    # Redis / Celery
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # JWT Auth
    JWT_SECRET_KEY: str = "supersecretjwtkey_awarescroll_focuslock_2026_at_least_32_chars"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours for dev convenience
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # Object Storage (S3 / R2) for Work Evidence
    S3_BUCKET_NAME: str = "awarescroll-evidence"
    S3_REGION: str = "us-east-1"
    S3_ACCESS_KEY_ID: Optional[str] = "test_key"
    S3_SECRET_ACCESS_KEY: Optional[str] = "test_secret"
    
    # Monitoring & ML
    SENTRY_DSN: Optional[str] = None
    ML_MODEL_REGISTRY_PATH: str = "models"
    MLFLOW_TRACKING_URI: Optional[str] = None
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


settings = Settings()
