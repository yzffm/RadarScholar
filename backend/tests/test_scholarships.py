"""Tests for scholarship endpoints."""

import uuid

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    return TestClient(app)

def test_get_scholarships_collection(client: TestClient):
    """Test getting paginated collection of scholarships."""
    # This assumes the database is seeded or empty but won't crash
    response = client.get("/api/v1/scholarships")
    assert response.status_code == 200

    data = response.json()
    assert "items" in data
    assert "page" in data
    assert "page_size" in data
    assert "total" in data
    assert "total_pages" in data
    assert data["page"] == 1
    assert data["page_size"] == 20

def test_get_scholarships_pagination(client: TestClient):
    """Test pagination parameters."""
    response = client.get("/api/v1/scholarships?page=2&page_size=5")
    assert response.status_code == 200

    data = response.json()
    assert data["page"] == 2
    assert data["page_size"] == 5

def test_get_scholarships_status_filter(client: TestClient):
    """Test filtering by status."""
    response = client.get("/api/v1/scholarships?status=active")
    assert response.status_code == 200

    response_inactive = client.get("/api/v1/scholarships?status=inactive")
    assert response_inactive.status_code == 200

def test_get_scholarship_not_found(client: TestClient):
    """Test 404 for unknown scholarship."""
    fake_id = str(uuid.uuid4())
    response = client.get(f"/api/v1/scholarships/{fake_id}")
    assert response.status_code == 404
