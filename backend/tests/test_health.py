"""Tests for the health check endpoint."""

import pytest
from fastapi.testclient import TestClient

from app.api import health
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


def test_readiness_check_returns_ready(client: TestClient, test_engine):
    original_get_engine = health.get_engine
    health.get_engine = lambda: test_engine
    response = client.get("/health/ready")
    health.get_engine = original_get_engine

    assert response.status_code == 200
    assert response.json()["status"] == "ready"
    assert response.json()["database"] == "sqlite"


def test_readiness_check_returns_503_when_database_is_unavailable(
    client: TestClient,
):
    def unavailable_engine():
        raise RuntimeError("database unavailable")

    original_get_engine = health.get_engine
    health.get_engine = unavailable_engine
    try:
        response = client.get("/health/ready")
    finally:
        health.get_engine = original_get_engine

    assert response.status_code == 503
    assert response.json()["detail"] == "Layanan belum siap."
