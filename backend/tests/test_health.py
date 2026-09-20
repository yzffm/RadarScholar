"""Tests for the health check endpoint."""

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    return TestClient(app)


def test_health_check_returns_ok(client: TestClient):
    """GET /health should return status ok and version."""
    response = client.get("/health")

    assert response.status_code == 200

    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data
    assert data["version"] == "0.1.0"


def test_health_check_response_structure(client: TestClient):
    """GET /health response should have exactly the expected keys."""
    response = client.get("/health")
    data = response.json()

    expected_keys = {"status", "version"}
    assert set(data.keys()) == expected_keys
