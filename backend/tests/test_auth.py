"""Tests for the auth dependency (Supabase API verification).

Verifies that:
- Valid JWT tokens return the correct AuthUser
- Missing tokens raise 401
- Invalid tokens raise 401
- Missing configuration raises 503
"""

from unittest.mock import AsyncMock, MagicMock, patch

from fastapi import Depends, FastAPI
from fastapi.testclient import TestClient

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser

# Create a minimal FastAPI app for testing the auth dependency
_test_app = FastAPI()

@_test_app.get("/test-auth")
async def _protected_route(user: AuthUser = Depends(get_current_user)):
    return {"user_id": user.id, "email": user.email}

client = TestClient(_test_app)

@patch("app.auth.dependencies.httpx.AsyncClient.get", new_callable=AsyncMock)
@patch("app.auth.dependencies.settings")
def test_valid_token_returns_user(mock_settings, mock_get):
    """Valid JWT verified by Supabase should return AuthUser."""
    mock_settings.SUPABASE_URL = "http://test-supabase.com"
    mock_settings.SUPABASE_ANON_KEY = "test-anon-key"

    # Mock successful Supabase response
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"id": "test-user-123", "email": "test@university.ac.id"}
    mock_get.return_value = mock_response

    response = client.get(
        "/test-auth",
        headers={"Authorization": "Bearer test-valid-token"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["user_id"] == "test-user-123"
    assert data["email"] == "test@university.ac.id"


def test_missing_token_returns_401():
    """Request without Authorization header should return 401."""
    response = client.get("/test-auth")
    assert response.status_code == 401


@patch("app.auth.dependencies.httpx.AsyncClient.get", new_callable=AsyncMock)
@patch("app.auth.dependencies.settings")
def test_invalid_token_returns_401(mock_settings, mock_get):
    """Invalid JWT rejected by Supabase should return 401."""
    mock_settings.SUPABASE_URL = "http://test-supabase.com"
    mock_settings.SUPABASE_ANON_KEY = "test-anon-key"

    # Mock failed Supabase response
    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_get.return_value = mock_response

    response = client.get(
        "/test-auth",
        headers={"Authorization": "Bearer invalid-token-garbage"},
    )
    assert response.status_code == 401


@patch("app.auth.dependencies.settings")
def test_missing_supabase_url_returns_503(mock_settings):
    """If SUPABASE_URL is not configured, return 503."""
    mock_settings.SUPABASE_URL = ""
    mock_settings.SUPABASE_ANON_KEY = "test-key"

    response = client.get(
        "/test-auth",
        headers={"Authorization": "Bearer some-token"},
    )
    assert response.status_code == 503
