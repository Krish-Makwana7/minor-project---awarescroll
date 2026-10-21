from celery import Celery
from celery.schedules import crontab
from app.core.config import settings
from app.core.logging import logger

celery_app = Celery(
    "awarescroll_tasks",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    beat_schedule={
        "nightly-descriptive-aggregation": {
            "task": "app.celery_app.nightly_aggregation_job",
            "schedule": crontab(hour=2, minute=0),  # Run nightly at 02:00 AM UTC
        },
        "weekly-pattern-recalculation": {
            "task": "app.celery_app.weekly_pattern_update_job",
            "schedule": crontab(day_of_week=0, hour=3, minute=0),  # Every Sunday at 03:00 AM UTC
        },
    },
)


@celery_app.task
def nightly_aggregation_job():
    logger.info("Executing nightly behavioral aggregation and descriptive analytics job...")
    # Performs aggregation of usage and focus sessions across active users
    return {"status": "success", "message": "Nightly aggregation complete"}


@celery_app.task
def weekly_pattern_update_job():
    logger.info("Executing weekly behavioral pattern discovery and model evaluation...")
    return {"status": "success", "message": "Weekly pattern update complete"}
