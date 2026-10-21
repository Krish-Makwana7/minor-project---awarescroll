import uuid


def test_register_and_login(client):
    unique_email = f"alex_{uuid.uuid4().hex[:8]}@startup.io"

    # Register
    res = client.post(
        "/api/v1/auth/register",
        json={"email": unique_email, "password": "Password123!", "timezone": "UTC"},
    )
    assert res.status_code == 201, res.text
    data = res.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["email"] == unique_email

    # Duplicate registration should fail
    dup = client.post(
        "/api/v1/auth/register",
        json={"email": unique_email, "password": "Password123!"},
    )
    assert dup.status_code == 400

    # Login
    login_res = client.post(
        "/api/v1/auth/login",
        json={"email": unique_email, "password": "Password123!"},
    )
    assert login_res.status_code == 200
    assert "access_token" in login_res.json()

    # Me endpoint
    me_res = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {login_res.json()['access_token']}"},
    )
    assert me_res.status_code == 200
    assert me_res.json()["email"] == unique_email
