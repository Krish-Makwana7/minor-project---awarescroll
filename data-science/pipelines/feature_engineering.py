import random
from datetime import datetime, timedelta, timezone
from typing import Tuple, List, Dict, Any
import numpy as np
import pandas as pd


def extract_time_features(dt: datetime) -> Dict[str, Any]:
    hour = dt.hour
    is_weekend = 1 if dt.weekday() >= 5 else 0
    if 5 <= hour < 12:
        bucket = "morning"
    elif 12 <= hour < 17:
        bucket = "afternoon"
    elif 17 <= hour < 22:
        bucket = "evening"
    else:
        bucket = "night"
    return {
        "hour_of_day": hour,
        "is_weekend": is_weekend,
        "time_of_day_bucket": bucket,
    }


def extract_purpose_flags(purpose: str) -> Dict[str, int]:
    p = (purpose or "").lower()
    return {
        "purpose_reels_flag": 1 if any(w in p for w in ["reel", "shorts", "scroll", "explore", "bored"]) else 0,
        "purpose_social_flag": 1 if any(w in p for w in ["dm", "chat", "message", "friend", "reply"]) else 0,
    }


def generate_synthetic_behavioral_dataset(n_samples: int = 600, random_seed: int = 42) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """Generates synthetic, domain-realistic dataset for bootstrap model training.
    Reflects observed real-world behavior:
    - Evening scrolling on Reels has high overrun rate (~75-80%)
    - Quick morning DM checks have low overrun rate (~15-20%)
    - Focus blocks >45m have ~60% interruption rate vs 25m sprints with ~15% interruption.
    """
    np.random.seed(random_seed)
    random.seed(random_seed)

    # 1. AwareScroll Overrun Dataset
    overrun_rows = []
    purposes = [
        ("Check DMs from study group", "social"),
        ("Watch friend's story", "social"),
        ("Quick reply to message", "social"),
        ("Scroll Reels before sleep", "reels"),
        ("Browse Explore feed", "reels"),
        ("Watch recommended comedy reels", "reels"),
        ("Check notifications", "social"),
        ("Just killing time", "reels"),
    ]
    time_buckets = ["morning", "afternoon", "evening", "night"]

    for i in range(n_samples):
        purpose_text, cat = random.choice(purposes)
        intended_duration = random.choice([5, 10, 15, 20, 30, 45, 60])
        bucket = np.random.choice(time_buckets, p=[0.15, 0.25, 0.40, 0.20])
        is_weekend = np.random.choice([0, 1], p=[0.7, 0.3])

        hour = {
            "morning": random.randint(7, 11),
            "afternoon": random.randint(12, 16),
            "evening": random.randint(17, 21),
            "night": random.choice([22, 23, 0, 1]),
        }[bucket]

        # Prior overrun rate
        prior_overrun = np.clip(np.random.normal(0.40, 0.15), 0.05, 0.95)

        # Calculate true overrun probability
        prob = 0.20
        if bucket in ["evening", "night"]:
            prob += 0.35
        if cat == "reels":
            prob += 0.30
        if intended_duration >= 30:
            prob += 0.15
        prob += (prior_overrun - 0.4) * 0.3
        prob = np.clip(prob, 0.05, 0.95)

        exceeded_limit = 1 if np.random.rand() < prob else 0
        actual_duration = intended_duration * np.random.uniform(1.2, 2.5) if exceeded_limit else intended_duration * np.random.uniform(0.6, 1.0)

        overrun_rows.append({
            "intended_duration_minutes": intended_duration,
            "hour_of_day": hour,
            "is_weekend": is_weekend,
            "time_of_day_bucket": bucket,
            "purpose_reels_flag": 1 if cat == "reels" else 0,
            "purpose_social_flag": 1 if cat == "social" else 0,
            "user_prior_overrun_rate": prior_overrun,
            "actual_duration_minutes": round(actual_duration, 1),
            "exceeded_limit": exceeded_limit,
        })

    overrun_df = pd.DataFrame(overrun_rows)

    # 2. FocusLock Interruption Dataset
    focus_rows = []
    categories = ["Study", "Coding", "Writing", "Work", "Reading"]

    for i in range(n_samples):
        cat = random.choice(categories)
        planned_duration = random.choice([15, 25, 30, 45, 60, 90])
        bucket = np.random.choice(time_buckets, p=[0.25, 0.40, 0.30, 0.05])
        is_weekend = np.random.choice([0, 1], p=[0.75, 0.25])

        hour = {
            "morning": random.randint(8, 11),
            "afternoon": random.randint(12, 16),
            "evening": random.randint(17, 21),
            "night": random.choice([22, 23]),
        }[bucket]

        prior_interruption = np.clip(np.random.normal(0.30, 0.12), 0.05, 0.90)

        prob = 0.15
        if planned_duration >= 60:
            prob += 0.40
        elif planned_duration >= 45:
            prob += 0.25
        elif planned_duration <= 25:
            prob -= 0.10

        if bucket == "evening":
            prob += 0.15
        prob += (prior_interruption - 0.3) * 0.25
        prob = np.clip(prob, 0.05, 0.95)

        interrupted = 1 if np.random.rand() < prob else 0

        focus_rows.append({
            "task_category": cat,
            "planned_duration_minutes": planned_duration,
            "hour_of_day": hour,
            "is_weekend": is_weekend,
            "time_of_day_bucket": bucket,
            "user_prior_interruption_rate": prior_interruption,
            "completed": 1 if not interrupted else 0,
            "interrupted": interrupted,
        })

    focus_df = pd.DataFrame(focus_rows)

    return overrun_df, focus_df
