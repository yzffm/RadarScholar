import pytest
from uuid import uuid4
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock

from app.main import app
from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.users.schemas import UserProfileResponse, DegreeLevelSchema
from app.scholarships.schemas import ScholarshipResponse
from app.matching.schemas import MatchResult, RelevanceTier
from app.ai.router import get_ai_service
from app.ai.service import AIUnavailableError
from app.ai.schemas import MatchExplanation

from datetime import datetime

client = TestClient(app)

@pytest.fixture
def override_auth():
    async def mock_get_current_user():
        return AuthUser(id=str(uuid4()), email="test@test.com", role="authenticated")
    app.dependency_overrides[get_current_user] = mock_get_current_user
    yield
    app.dependency_overrides.pop(get_current_user, None)

@pytest.fixture
def mock_db():
    with patch("app.ai.router.get_profile") as mock_profile, \
         patch("app.ai.router.scholarship_service.get_scholarship") as mock_scholarship, \
         patch("app.ai.router.MatchingService") as mock_matching:
        
        mock_profile.return_value = UserProfileResponse(
            id=str(uuid4()),
            email="test@test.com",
            display_name="Test User",
            degree_level=DegreeLevelSchema.S1,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        mock_scholarship.return_value = ScholarshipResponse(
            id=uuid4(),
            source_id=uuid4(),
            title="Test Scholarship",
            summary="A test scholarship",
            description="Desc",
            application_url="http://test.com",
            created_at=datetime.now(),
            updated_at=datetime.now(),
            is_active=True
        )
        
        mock_matching.return_value.match.return_value = MatchResult(
            relevance=RelevanceTier.SANGAT_RELEVAN,
            criterion_evaluations=[],
            matched_count=0,
            not_matched_count=0,
            unknown_count=0,
            needs_verification_count=0,
            explanation="Test match"
        )
        yield

@pytest.fixture
def mock_ai():
    mock_service = AsyncMock()
    app.dependency_overrides[get_ai_service] = lambda: mock_service
    yield mock_service
    app.dependency_overrides.pop(get_ai_service, None)


def test_ai_explanation_endpoint_success(override_auth, mock_db, mock_ai):
    mock_ai.generate_structured.return_value = MatchExplanation(
        summary="Test summary",
        strengths=["Strengths"],
        weaknesses=["Weakness"],
        unknowns=[]
    )
    
    response = client.get(f"/api/v1/scholarships/{uuid4()}/ai-explanation")
    
    assert response.status_code == 200
    data = response.json()
    assert data["summary"] == "Test summary"
    assert data["strengths"] == ["Strengths"]
    assert mock_ai.generate_structured.call_count == 1

def test_ai_explanation_endpoint_unavailable(override_auth, mock_db, mock_ai):
    mock_ai.generate_structured.side_effect = AIUnavailableError("Unavailable")
    
    response = client.get(f"/api/v1/scholarships/{uuid4()}/ai-explanation")
    
    assert response.status_code == 503
    assert "Unavailable" in response.json()["detail"]
