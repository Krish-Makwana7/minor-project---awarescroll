from datetime import datetime, timezone, timedelta


def test_awarescroll_and_feedback_flow(client, auth_headers):
    headers = {"Authorization": auth_headers["Authorization"]}

    # 1. State an intention: 10 minutes Instagram
    int_res = client.post(
        "/api/v1/intentions",
        headers=headers,
        json={"session_type": "instagram", "intended_duration_minutes": 10, "intended_purpose": "Check stories"},
    )
    intention_id = int_res.json()["id"]

    # 2. Start usage session
    start_time = datetime.now(timezone.utc)
    sess_res = client.post(
        "/api/v1/usage-sessions",
        headers=headers,
        json={
            "intention_id": intention_id,
            "start_time": start_time.isoformat(),
            "actual_duration_minutes": 22.5,
            "reminder_count": 2,
        },
    )
    assert sess_res.status_code == 201
    usage_session = sess_res.json()
    assert usage_session["exceeded_limit"] is True  # 22.5 > 10.0
    session_id = usage_session["id"]

    # 3. Submit reflection feedback survey
    fb_res = client.post(
        "/api/v1/feedback",
        headers=headers,
        json={
            "usage_session_id": session_id,
            "original_intention": "Check stories",
            "continuation_motivation": "got caught up in reels",
            "content_type": "reels",
            "delayed_planned_work": True,
            "mood_after": "guilty",
        },
    )
    assert fb_res.status_code == 201
    fb_data = fb_res.json()
    assert fb_data["delayed_planned_work"] is True
    assert fb_data["content_type"] == "reels"


def test_focuslock_and_interruption_flow(client, auth_headers):
    headers = {"Authorization": auth_headers["Authorization"]}

    # 1. State an intention: 45 min Focus session
    int_res = client.post(
        "/api/v1/intentions",
        headers=headers,
        json={"session_type": "focus", "intended_duration_minutes": 45, "intended_purpose": "Data Structures assignment"},
    )
    intention_id = int_res.json()["id"]

    # 2. Start focus session
    start_time = datetime.now(timezone.utc)
    focus_res = client.post(
        "/api/v1/focus-sessions",
        headers=headers,
        json={
            "intention_id": intention_id,
            "task_category": "Study",
            "task_description": "Algorithms Chapter 4",
            "planned_duration_minutes": 45,
            "start_time": start_time.isoformat(),
        },
    )
    assert focus_res.status_code == 201
    focus_session = focus_res.json()
    focus_id = focus_session["id"]

    # 3. Log an early exit interruption
    inter_time = start_time + timedelta(minutes=20)
    inter_res = client.post(
        f"/api/v1/focus-sessions/{focus_id}/interruptions",
        headers=headers,
        json={
            "interruption_time": inter_time.isoformat(),
            "reason_text": "Wanted to see if friend replied",
            "reason_category": "notification",
        },
    )
    assert inter_res.status_code == 201
    assert inter_res.json()["reason_category"] == "notification"

    # 4. Check focus session reflects interrupted state
    updated_focus = client.get(f"/api/v1/focus-sessions/{focus_id}", headers=headers)
    assert updated_focus.status_code == 200
    assert updated_focus.json()["interrupted"] is True


def test_analytics_and_csv_export(client, auth_headers):
    headers = {"Authorization": auth_headers["Authorization"]}

    # Create one usage session and one focus session
    start_time = datetime.now(timezone.utc)
    client.post(
        "/api/v1/usage-sessions",
        headers=headers,
        json={
            "start_time": start_time.isoformat(),
            "actual_duration_minutes": 35.0,
            "exceeded_limit": True,
            "time_of_day_bucket": "evening",
        },
    )
    client.post(
        "/api/v1/focus-sessions",
        headers=headers,
        json={
            "task_category": "Work",
            "task_description": "Quarterly Report",
            "planned_duration_minutes": 30,
            "start_time": start_time.isoformat(),
            "completed": True,
            "interrupted": False,
        },
    )

    # Summary
    summary_res = client.get("/api/v1/analytics/summary", headers=headers)
    assert summary_res.status_code == 200
    summary = summary_res.json()
    assert summary["total_usage_sessions"] >= 1
    assert summary["total_focus_sessions"] >= 1
    assert summary["usage_overrun_rate"] > 0
    assert "adherence_score" in summary

    # Patterns
    patterns_res = client.get("/api/v1/analytics/patterns", headers=headers)
    assert patterns_res.status_code == 200
    patterns = patterns_res.json()
    assert len(patterns["patterns"]) > 0

    # Predictions
    pred_res = client.post(
        "/api/v1/predict/overrun",
        headers=headers,
        json={"intended_duration_minutes": 30, "intended_purpose": "Watch reels", "time_of_day": "evening"},
    )
    assert pred_res.status_code == 200
    assert "risk_score" in pred_res.json()
    assert "suggested_limit" in pred_res.json()

    # CSV Export
    export_res = client.get("/api/v1/export?format=csv", headers=headers)
    assert export_res.status_code == 200
    assert "text/csv" in export_res.headers["content-type"]
    assert "event_id" in export_res.text
