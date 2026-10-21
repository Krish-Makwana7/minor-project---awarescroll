import enum


class GoalType(str, enum.Enum):
    INSTAGRAM_TIME_LIMIT = "instagram_time_limit"
    AVOID_HOURS = "avoid_hours"
    FOCUS_SESSION_TARGET = "focus_session_target"
    REDUCE_PRESLEEP_SCROLLING = "reduce_presleep_scrolling"


class SessionType(str, enum.Enum):
    INSTAGRAM = "instagram"
    FOCUS = "focus"


class EventSource(str, enum.Enum):
    AWARESCROLL = "awarescroll"
    FOCUSLOCK = "focuslock"


class InterruptionReasonCategory(str, enum.Enum):
    BOREDOM = "boredom"
    NOTIFICATION = "notification"
    EXTERNAL = "external"
    FATIGUE = "fatigue"
    OTHER = "other"


class WorkEvidenceVerificationStatus(str, enum.Enum):
    UNVERIFIED = "unverified"
    SELF_REPORTED = "self_reported"
    FLAGGED = "flagged"


class ModelType(str, enum.Enum):
    LOGISTIC_REGRESSION = "logistic_regression"
    DECISION_TREE = "decision_tree"
    RANDOM_FOREST = "random_forest"
    HEURISTIC = "heuristic"


class PredictionTarget(str, enum.Enum):
    USAGE_OVERRUN = "usage_overrun"
    FOCUS_INTERRUPTION = "focus_interruption"


class RecommendationType(str, enum.Enum):
    LIMIT_ADJUSTMENT = "limit_adjustment"
    FOCUS_BLOCK_DURATION = "focus_block_duration"
    AVOID_HOURS_ALERT = "avoid_hours_alert"
    ENVIRONMENT_PROMPT = "environment_prompt"
    MINDFUL_CHECKIN = "mindful_checkin"
