"""Tests for matched scholarships endpoint."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
import uuid

from app.main import app
from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.users.models import UserProfile, DegreeLevel
from app.database.session import get_db

@pytest.fixture
def client():
    return TestClient(app)

def mock_get_current_user():
    return AuthUser(id="test-user-id", email="test@example.com")

def test_matched_unauthenticated(client: TestClient):
    """Test 401 if unauthenticated."""
    response = client.get("/api/v1/scholarships/matched")
    assert response.status_code == 401

def test_matched_authenticated_no_profile(client: TestClient):
    """Test 400 if user has no profile."""
    app.dependency_overrides[get_current_user] = mock_get_current_user
    
    # User has no profile in DB because mock_get_current_user returns a fake ID
    response = client.get("/api/v1/scholarships/matched")
    assert response.status_code == 400
    assert "Profil pengguna belum dilengkapi" in response.text
    
    app.dependency_overrides.clear()

def test_matched_authenticated_with_profile(client: TestClient, monkeypatch):
    """Test matching endpoint successfully."""
    app.dependency_overrides[get_current_user] = mock_get_current_user
    
    # Mock get_profile
    def mock_get_profile(*args, **kwargs):
        return UserProfile(gpa=3.5, semester=3, degree_level=DegreeLevel.S1, major="Computer Science")
        
    monkeypatch.setattr("app.scholarships.router.get_profile", mock_get_profile)
    
    response = client.get("/api/v1/scholarships/matched")
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "page" in data
    
    app.dependency_overrides.clear()
