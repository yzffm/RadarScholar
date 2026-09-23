"""Tests for the auth dependency (JWT verification).

Verifies that:
- Valid JWT tokens return the correct AuthUser
- Missing tokens raise 401
- Invalid tokens raise 401
- Expired tokens raise 401
"""

from datetime import UTC, datetime, timedelta
from unittest.mock import patch

import jwt
from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser

# Test secret for JWT signing
TEST_JWT_SECRET = "test-jwt-secret-for-unit-tests"

# Create a minimal FastAPI app for testing the auth dependency
_test_app = FastAPI()


@_test_app.get("/test-auth")
async def _protected_route(user: AuthUser = Depends(get_current_user)):
    return {"user_id": user.id, "email": user.email}


client = TestClient(_test_app)


def _make_token(
    user_id: str = "test-user-123",
    email: str = "test@university.ac.id",
    secret: str = TEST_JWT_SECRET,
    expired: bool = False,
) -> str:
    """Helper to create a JWT token for testing."""
    now = datetime.now(UTC)
    payload = {
        "sub": user_id,
        "email": email,
        "aud": "authenticated",
        "iat": now,
        "exp": now + (timedelta(seconds=-10) if expired else timedelta(hours=1)),
    }
    return jwt.encode(payload, secret, algorithm="HS256")


@patch("app.auth.dependencies.settings")
def test_valid_token_returns_user(mock_settings):
    """Valid JWT should return AuthUser with correct id and email."""
    mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET
    token = _make_token()

    response = client.get(
        "/test-auth",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["user_id"] == "test-user-123"
    assert data["email"] == "test@university.ac.id"


def test_missing_token_returns_401():
    """Request without Authorization header should return 401."""
    response = client.get("/test-auth")
    assert response.status_code == 401


@patch("app.auth.dependencies.settings")
def test_invalid_token_returns_401(mock_settings):
    """Invalid JWT should return 401."""
    mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET

    response = client.get(
        "/test-auth",
        headers={"Authorization": "Bearer invalid-token-garbage"},
    )
    assert response.status_code == 401


@patch("app.auth.dependencies.settings")
def test_expired_token_returns_401(mock_settings):
    """Expired JWT should return 401."""
    mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET
    token = _make_token(expired=True)

    response = client.get(
        "/test-auth",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


@patch("app.auth.dependencies.settings")
def test_wrong_secret_returns_401(mock_settings):
    """Token signed with wrong secret should return 401."""
    mock_settings.SUPABASE_JWT_SECRET = TEST_JWT_SECRET
    token = _make_token(secret="wrong-secret")

    response = client.get(
        "/test-auth",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


@patch("app.auth.dependencies.settings")
def test_missing_jwt_secret_returns_503(mock_settings):
    """If SUPABASE_JWT_SECRET is not configured, return 503."""
    mock_settings.SUPABASE_JWT_SECRET = ""
    token = _make_token()

    response = client.get(
        "/test-auth",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 503
