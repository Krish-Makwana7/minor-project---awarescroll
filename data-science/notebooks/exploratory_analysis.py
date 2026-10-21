"""Exploratory Behavioral Analysis Script (Notebook-equivalent)
Analyzes correlation between stated intentions, content types, time-of-day, and actual adherence.
"""

import sys
import os
import pandas as pd
import numpy as np

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from pipelines.feature_engineering import generate_synthetic_behavioral_dataset
from pipelines.descriptive_analytics import run_descriptive_analytics
from pipelines.generate_recommendations import generate_recommendations_from_data


def run_exploration():
    print("Generating representative behavioral dataset (N=1,000)...")
    overrun_df, focus_df = generate_synthetic_behavioral_dataset(n_samples=1000)

    print("\n--- Summary Statistics ---")
    summary = run_descriptive_analytics(overrun_df, focus_df)
    for k, v in summary.items():
        print(f"{k}: {v}")

    print("\n--- Overrun Probability by Time of Day & Content Purpose ---")
    ct = pd.crosstab(
        overrun_df["time_of_day_bucket"],
        overrun_df["purpose_reels_flag"],
        values=overrun_df["exceeded_limit"],
        aggfunc="mean",
    )
    ct.columns = ["Other/DM Purpose", "Reels/Scroll Purpose"]
    print(ct.round(3))

    print("\n--- Focus Session Interruption Rate by Planned Duration ---")
    f_agg = focus_df.groupby("planned_duration_minutes")["interrupted"].agg(["count", "mean"])
    f_agg.columns = ["Session Count", "Interruption Rate"]
    print(f_agg.round(3))

    print("\n--- Recommendations Generated ---")
    recs = generate_recommendations_from_data(overrun_df, focus_df)
    for r in recs:
        print(f"[{r['type']}] {r['title']} -> {r['based_on_pattern']}")


if __name__ == "__main__":
    run_exploration()
