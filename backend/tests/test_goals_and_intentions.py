def test_goals_crud(client, auth_headers):
    headers = {"Authorization": auth_headers["Authorization"]}

    # Create goal: 30 min daily Instagram limit
    res = client.post(
        "/api/v1/goals",
        headers=headers,
        json={
            "goal_type": "instagram_time_limit",
            "target_value": 30.0,
            "unit": "minutes",
            "active": True,
        },
    )
    assert res.status_code == 201
    goal = res.json()
    assert goal["target_value"] == 30.0
    goal_id = goal["id"]

    # List goals
    list_res = client.get("/api/v1/goals", headers=headers)
    assert list_res.status_code == 200
    assert len(list_res.json()) == 1

    # Update goal
    up_res = client.put(
        f"/api/v1/goals/{goal_id}",
        headers=headers,
        json={"target_value": 25.0},
    )
    assert up_res.status_code == 200
    assert up_res.json()["target_value"] == 25.0

    # Delete goal
    del_res = client.delete(f"/api/v1/goals/{goal_id}", headers=headers)
    assert del_res.status_code == 204


def test_intentions_flow(client, auth_headers):
    headers = {"Authorization": auth_headers["Authorization"]}

    # Create intention before opening Instagram
    res = client.post(
        "/api/v1/intentions",
        headers=headers,
        json={
            "session_type": "instagram",
            "intended_duration_minutes": 15,
            "intended_purpose": "Reply to messages from group project",
        },
    )
    assert res.status_code == 201
    intention = res.json()
    assert intention["intended_duration_minutes"] == 15
    assert intention["session_type"] == "instagram"

    # Fetch latest intention
    latest = client.get("/api/v1/intentions/latest?session_type=instagram", headers=headers)
    assert latest.status_code == 200
    assert latest.json()["intended_duration_minutes"] == 15
