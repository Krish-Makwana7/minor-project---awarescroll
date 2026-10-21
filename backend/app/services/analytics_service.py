import uuid
import io
import os
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Any, Tuple
import pandas as pd
from sqlalchemy.orm import Session
from app.models.usage_sessions import UsageSession
from app.models.focus_sessions import FocusSession
from app.models.feedback import Feedback
from app.models.interruptions import Interruption
from app.models.behavioral_events import BehavioralEvent
from app.schemas.analytics import AnalyticsSummaryResponse, PatternItem, PatternResponse, ExportResponse


class AnalyticsService:
    @staticmethod
    def get_summary(db: Session, user_id: uuid.UUID, range_days: int = 30) -> AnalyticsSummaryResponse:
        start_filter = datetime.now(timezone.utc) - timedelta(days=range_days)

        usage_sessions = (
            db.query(UsageSession)
            .filter(UsageSession.user_id == user_id, UsageSession.start_time >= start_filter)
            .all()
        )
        focus_sessions = (
            db.query(FocusSession)
            .filter(FocusSession.user_id == user_id, FocusSession.start_time >= start_filter)
            .all()
        )

        total_usage_count = len(usage_sessions)
        total_focus_count = len(focus_sessions)

        total_usage_minutes = sum(s.actual_duration_minutes for s in usage_sessions)
        avg_usage_duration = (total_usage_minutes / total_usage_count) if total_usage_count > 0 else 0.0

        overrun_count = sum(1 for s in usage_sessions if s.exceeded_limit)
        overrun_rate = (overrun_count / total_usage_count) if total_usage_count > 0 else 0.0

        # Continuation rate: feedback where delayed_planned_work is True or user continued past limit
        feedback_records = (
            db.query(Feedback)
            .join(UsageSession, Feedback.usage_session_id == UsageSession.id)
            .filter(UsageSession.user_id == user_id, UsageSession.start_time >= start_filter)
            .all()
        )
        continuation_count = sum(1 for f in feedback_records if f.delayed_planned_work or f.continuation_motivation != "closed")
        continuation_rate = (continuation_count / overrun_count) if overrun_count > 0 else 0.0

        completed_focus_count = sum(1 for f in focus_sessions if f.completed and not f.interrupted)
        focus_completion_rate = (completed_focus_count / total_focus_count) if total_focus_count > 0 else 0.0

        interrupted_focus_count = sum(1 for f in focus_sessions if f.interrupted)
        focus_interruption_rate = (interrupted_focus_count / total_focus_count) if total_focus_count > 0 else 0.0

        total_focus_minutes = sum(f.planned_duration_minutes for f in focus_sessions)

        # Composite adherence score (0-100)
        # Higher limit adherence (1 - overrun_rate) and higher focus completion boost the score
        adherence_component = (1.0 - overrun_rate) * 50.0
        focus_component = focus_completion_rate * 50.0
        adherence_score = round(max(0.0, min(100.0, adherence_component + focus_component)), 1)
        if total_usage_count == 0 and total_focus_count == 0:
            adherence_score = 100.0

        return AnalyticsSummaryResponse(
            uid=user_id,
            range_days=range_days,
            average_usage_duration_minutes=round(avg_usage_duration, 1),
            usage_overrun_rate=round(overrun_rate, 3),
            usage_continuation_rate=round(continuation_rate, 3),
            focus_completion_rate=round(focus_completion_rate, 3),
            focus_interruption_rate=round(focus_interruption_rate, 3),
            total_usage_sessions=total_usage_count,
            total_focus_sessions=total_focus_count,
            total_usage_minutes=round(total_usage_minutes, 1),
            total_focus_minutes=round(total_focus_minutes, 1),
            adherence_score=adherence_score,
        )

    @staticmethod
    def get_patterns(db: Session, user_id: uuid.UUID) -> PatternResponse:
        patterns: List[PatternItem] = []

        usage_sessions = db.query(UsageSession).filter(UsageSession.user_id == user_id).all()
        focus_sessions = db.query(FocusSession).filter(FocusSession.user_id == user_id).all()
        feedbacks = (
            db.query(Feedback)
            .join(UsageSession, Feedback.usage_session_id == UsageSession.id)
            .filter(UsageSession.user_id == user_id)
            .all()
        )
        interruptions = (
            db.query(Interruption)
            .join(FocusSession, Interruption.focus_session_id == FocusSession.id)
            .filter(FocusSession.user_id == user_id)
            .all()
        )

        # Pattern 1: Evening Usage Drift
        evening_sessions = [s for s in usage_sessions if s.time_of_day_bucket == "evening" or (s.start_time and s.start_time.hour >= 18)]
        if len(evening_sessions) >= 3:
            evening_overruns = sum(1 for s in evening_sessions if s.exceeded_limit)
            conf = evening_overruns / len(evening_sessions)
            if conf >= 0.5:
                patterns.append(
                    PatternItem(
                        pattern=f"Evening scrolling (after 6 PM) overruns your stated limit in {int(conf * 100)}% of sessions.",
                        confidence=round(conf, 2),
                        evidence_count=len(evening_sessions),
                        category="timing",
                    )
                )

        # Pattern 2: Content Type Drift (Reels vs others)
        reels_feedbacks = [f for f in feedbacks if "reel" in f.content_type.lower()]
        if len(reels_feedbacks) >= 2:
            reels_delays = sum(1 for f in reels_feedbacks if f.delayed_planned_work)
            conf = reels_delays / len(reels_feedbacks)
            patterns.append(
                PatternItem(
                    pattern=f"Opening Instagram for Reels is tied to delaying planned work in {int(conf * 100)}% of survey responses.",
                    confidence=round(max(0.6, conf), 2),
                    evidence_count=len(reels_feedbacks),
                    category="content",
                )
            )

        # Pattern 3: Focus Duration Drop-off (> 45 min)
        long_focus = [f for f in focus_sessions if f.planned_duration_minutes > 45]
        if len(long_focus) >= 2:
            long_interrupted = sum(1 for f in long_focus if f.interrupted)
            conf = long_interrupted / len(long_focus)
            patterns.append(
                PatternItem(
                    pattern=f"Focus blocks over 45 minutes have an interruption rate of {int(conf * 100)}%.",
                    confidence=round(conf, 2),
                    evidence_count=len(long_focus),
                    category="focus",
                )
            )

        # Pattern 4: Boredom / Notification Triggers
        boredom_count = sum(1 for i in interruptions if i.reason_category.value == "boredom")
        notif_count = sum(1 for i in interruptions if i.reason_category.value == "notification")
        if len(interruptions) >= 2:
            dominant = "boredom" if boredom_count >= notif_count else "notifications"
            count = max(boredom_count, notif_count)
            patterns.append(
                PatternItem(
                    pattern=f"{dominant.capitalize()} accounts for {int((count / len(interruptions)) * 100)}% of your recorded focus interruptions.",
                    confidence=round(count / len(interruptions), 2),
                    evidence_count=len(interruptions),
                    category="interruption",
                )
            )

        # Default fallback patterns if not enough user data yet
        if not patterns:
            patterns.append(
                PatternItem(
                    pattern="Initial data logging active. Complete 3 sessions to unlock personalized behavioral pattern detection.",
                    confidence=1.0,
                    evidence_count=len(usage_sessions) + len(focus_sessions),
                    category="onboarding",
                )
            )

        # Sort by confidence desc
        patterns.sort(key=lambda p: p.confidence, reverse=True)
        return PatternResponse(uid=user_id, patterns=patterns)

    @staticmethod
    def generate_csv_export(db: Session, user_id: uuid.UUID) -> Tuple[str, int]:
        """Flattens behavioral events, sessions and feedback into a clean dataset CSV via pandas.
        Applies security sanitization: excludes sensitive free-text fields.
        """
        events = (
            db.query(BehavioralEvent)
            .filter(BehavioralEvent.user_id == user_id)
            .order_by(BehavioralEvent.occurred_at.asc())
            .all()
        )

        rows = []
        for e in events:
            payload = e.payload if isinstance(e.payload, dict) else {}
            # Exclude raw free text from external exports
            sanitized_payload = {k: v for k, v in payload.items() if k not in ["reason_text", "intended_purpose"]}
            rows.append({
                "event_id": str(e.id),
                "user_id": str(e.user_id),
                "event_source": e.event_source.value,
                "event_type": e.event_type,
                "occurred_at": e.occurred_at.isoformat(),
                "created_at": e.created_at.isoformat(),
                "payload_json": str(sanitized_payload),
            })

        df = pd.DataFrame(rows)
        if df.empty:
            df = pd.DataFrame(columns=["event_id", "user_id", "event_source", "event_type", "occurred_at", "created_at", "payload_json"])

        csv_buffer = io.StringIO()
        df.to_csv(csv_buffer, index=False)
        return csv_buffer.getvalue(), len(rows)
