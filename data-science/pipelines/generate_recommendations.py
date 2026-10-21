"""Behavioral Intelligence Engine: Recommendation Generator
Generates actionable, personalized, evidence-based recommendations based on identified patterns.
"""

from typing import List, Dict, Any
import pandas as pd


def generate_recommendations_from_data(overrun_df: pd.DataFrame, focus_df: pd.DataFrame) -> List[Dict[str, Any]]:
    recommendations = []

    # 1. Evening Scrolling check
    evening_overruns = overrun_df[overrun_df["time_of_day_bucket"] == "evening"]
    if len(evening_overruns) > 0:
        rate = evening_overruns["exceeded_limit"].mean()
        if rate >= 0.5:
            recommendations.append({
                "type": "limit_adjustment",
                "title": "Shorten Evening Limit to 15m",
                "body": f"Your Instagram sessions after 6:00 PM overrun your stated target {int(rate * 100)}% of the time. Setting a tighter 15-minute limit with reflection prompts helps prevent bedtime scrolling drift.",
                "based_on_pattern": f"Evening overrun rate: {int(rate * 100)}%",
            })

    # 2. Focus session duration check
    long_focus = focus_df[focus_df["planned_duration_minutes"] > 45]
    if len(long_focus) > 0:
        int_rate = long_focus["interrupted"].mean()
        if int_rate >= 0.4:
            recommendations.append({
                "type": "focus_block_duration",
                "title": "Switch to 25-Minute Pomodoro Blocks",
                "body": f"Focus blocks planned for >45 minutes experience an interruption rate of {int(int_rate * 100)}%. Breaking deep work into 25-minute intervals reduces distraction impulses.",
                "based_on_pattern": f"Long focus session interruption rate: {int(int_rate * 100)}%",
            })

    # 3. Reels vs Social Purpose check
    reels_sessions = overrun_df[overrun_df["purpose_reels_flag"] == 1]
    social_sessions = overrun_df[overrun_df["purpose_social_flag"] == 1]
    if len(reels_sessions) > 0 and len(social_sessions) > 0:
        reels_rate = reels_sessions["exceeded_limit"].mean()
        social_rate = social_sessions["exceeded_limit"].mean()
        if reels_rate > social_rate + 0.2:
            recommendations.append({
                "type": "mindful_checkin",
                "title": "Pre-Reels Intention Check",
                "body": f"Opening Instagram for Reels is {reels_rate / max(0.01, social_rate):.1f}x more likely to exceed your time limit than checking DMs. Take a breath and confirm your exit time before opening Reels.",
                "based_on_pattern": f"Reels overrun ({int(reels_rate * 100)}%) vs DM overrun ({int(social_rate * 100)}%)",
            })

    return recommendations


if __name__ == "__main__":
    from feature_engineering import generate_synthetic_behavioral_dataset
    o_df, f_df = generate_synthetic_behavioral_dataset(n_samples=500)
    recs = generate_recommendations_from_data(o_df, f_df)
    print("\n--- Generated Behavioral Recommendations ---")
    for idx, r in enumerate(recs, 1):
        print(f"\n{idx}. [{r['type'].upper()}] {r['title']}")
        print(f"   {r['body']}")
        print(f"   Rationale: {r['based_on_pattern']}")
