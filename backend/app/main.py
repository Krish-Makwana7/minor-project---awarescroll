from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import Base, engine
from app.core.logging import logger
from app.api.routes import (
    auth,
    goals,
    intentions,
    usage_sessions,
    focus_sessions,
    feedback,
    insights,
    predictions,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing database schemas...")
    Base.metadata.create_all(bind=engine)
    logger.info("AwareScroll AI + FocusLock API backend ready.")
    yield
    logger.info("Shutting down backend...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Dual-feature digital self-regulation system (AwareScroll AI + FocusLock) with shared Behavioral Intelligence Engine.",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers under /api/v1
api_v1_prefix = settings.API_V1_STR
app.include_router(auth.router, prefix=api_v1_prefix)
app.include_router(goals.router, prefix=api_v1_prefix)
app.include_router(intentions.router, prefix=api_v1_prefix)
app.include_router(usage_sessions.router, prefix=api_v1_prefix)
app.include_router(focus_sessions.router, prefix=api_v1_prefix)
app.include_router(feedback.router, prefix=api_v1_prefix)
app.include_router(insights.router, prefix=api_v1_prefix)
app.include_router(predictions.router, prefix=api_v1_prefix)


@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/", tags=["Root"])
def root():
    return {
        "message": "Welcome to AwareScroll AI + FocusLock API",
        "documentation": "/docs",
        "health": "/health",
    }
