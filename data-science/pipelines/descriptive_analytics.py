"""Descriptive Analytics Pipeline for AwareScroll AI + FocusLock
Computes population and individual self-regulation metrics:
- Average duration
- Overrun rate (% of sessions exceeding intended limit)
- Continuation rate (% of overrun sessions where user continued past the prompt)
- Focus completion rate (% of sessions completed without early exit)
- Interruption causes breakdown
"""

import argparse
import sys
import os
import pandas as pd
import numpy as np

# Ensure path includes data-science root
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from pipelines.feature_engineering import generate_synthetic_behavioral_dataset


def run_descriptive_analytics(overrun_df: pd.DataFrame, focus_df: pd.DataFrame) -> dict:
    # Usage metrics
    total_usage = len(overrun_df)
    avg_usage = overrun_df["actual_duration_minutes"].mean() if total_usage > 0 else 0.0
    overrun_count = overrun_df["exceeded_limit"].sum()
    overrun_rate = (overrun_count / total_usage) if total_usage > 0 else 0.0

    # Overrun rate by time of day
    overrun_by_tod = (
        overrun_df.groupby("time_of_day_bucket")["exceeded_limit"]
        .mean()
        .to_dict()
    )

    # Focus metrics
    total_focus = len(focus_df)
    completed_focus = focus_df["completed"].sum()
    completion_rate = (completed_focus / total_focus) if total_focus > 0 else 0.0
    interrupted_count = focus_df["interrupted"].sum()
    interruption_rate = (interrupted_count / total_focus) if total_focus > 0 else 0.0

    # Interruption rate by planned duration
    interruption_by_duration = (
        focus_df.groupby(pd.cut(focus_df["planned_duration_minutes"], bins=[0, 25, 45, 120]))["interrupted"]
        .mean()
        .to_dict()
    )
    # Convert interval keys to strings for clean display
    interruption_by_duration_str = {str(k): round(v, 3) for k, v in interruption_by_duration.items()}

    summary = {
        "total_usage_sessions": total_usage,
        "average_usage_duration_minutes": round(avg_usage, 1),
        "usage_overrun_rate": round(overrun_rate, 3),
        "overrun_rate_by_time_of_day": {k: round(v, 3) for k, v in overrun_by_tod.items()},
        "total_focus_sessions": total_focus,
        "focus_completion_rate": round(completion_rate, 3),
        "focus_interruption_rate": round(interruption_rate, 3),
        "interruption_rate_by_duration": interruption_by_duration_str,
    }

    return summary


def main():
    parser = argparse.ArgumentParser(description="Descriptive Analytics Pipeline")
    parser.add_argument("--test-mode", action="store_true", help="Run with synthetic test data")
    args = parser.parse_args()

    print("=" * 60)
    print("AwareScroll AI + FocusLock — Behavioral Analytics Engine")
    print("=" * 60)

    overrun_df, focus_df = generate_synthetic_behavioral_dataset(n_samples=500)
    metrics = run_descriptive_analytics(overrun_df, focus_df)

    print(f"Total Usage Sessions Analyzed: {metrics['total_usage_sessions']}")
    print(f"Average Instagram Session:     {metrics['average_usage_duration_minutes']} minutes")
    print(f"Overall Limit Overrun Rate:    {metrics['usage_overrun_rate'] * 100:.1f}%")
    print("Overrun Rate by Time of Day:")
    for tod, rate in metrics["overrun_rate_by_time_of_day"].items():
        print(f"  - {tod.capitalize():<12}: {rate * 100:.1f}%")

    print("\nFocusLock Sessions Analyzed:  ", metrics["total_focus_sessions"])
    print(f"Focus Session Completion Rate: {metrics['focus_completion_rate'] * 100:.1f}%")
    print(f"Focus Interruption Rate:       {metrics['focus_interruption_rate'] * 100:.1f}%")
    print("Interruption Rate by Planned Duration:")
    for dur, rate in metrics["interruption_rate_by_duration"].items():
        print(f"  - {dur}: {rate * 100:.1f}%")
    print("=" * 60)
    print("Descriptive Analytics Pipeline complete.")


if __name__ == "__main__":
    main()
