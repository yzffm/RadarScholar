from uuid import uuid4
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.ai.schemas import AssistantRequest, AssistantTaskType
from app.ai.tasks.assistant import ApplicationAssistantTask

@pytest.fixture
def client():
    return TestClient(app)

@pytest.mark.asyncio
async def test_assistant_task_prompt_generation():
    # We will just test the prompt generation to make sure it includes the right context
    from app.users.schemas import UserProfileResponse
    from app.scholarships.schemas import ScholarshipResponse, ScholarshipBenefitResponse, ScholarshipRequirementResponse
    from app.applications.schemas import ApplicationResponse
    from app.applications.models import ApplicationStatus
    from datetime import datetime

    profile = UserProfileResponse(
        id=str(uuid4()),
        email="test@example.com",
        display_name="Budi",
        university="Universitas Indonesia",
        degree_level="S1",
        gpa=3.8,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        profile_completed=True,
    )

    scholarship = ScholarshipResponse(
        id=uuid4(),
        title="Beasiswa Unggulan",
        summary="Beasiswa penuh untuk mahasiswa berprestasi",
        description="Beasiswa penuh untuk mahasiswa berprestasi",
        application_url="http://example.com",
        benefits=[],
        requirements=[],
        deadline=None,
        is_active=True,
        source_id=uuid4(),
        source=None,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

    app_id = uuid4()
    application = ApplicationResponse(
        id=app_id,
        scholarship_id=scholarship.id,
        user_id=profile.id,
        status=ApplicationStatus.IN_PROGRESS,
        notes="Target essay minggu depan",
        target_deadline=None,
        tasks=[],
        scholarship=scholarship,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

    # Mock AIService just for passing into Task
    class MockAIService:
        pass
        
    task = ApplicationAssistantTask(ai_service=MockAIService())

    # 1. Test CV Mode without draft
    prompt_cv = task._build_prompt(profile, scholarship, application, AssistantTaskType.CV, None)
    assert "Budi" in prompt_cv
    assert "Beasiswa Unggulan" in prompt_cv
    assert "Target essay minggu depan" in prompt_cv
    assert "CV" in prompt_cv
    assert "No draft provided" in prompt_cv

    # 2. Test Essay Mode with draft
    prompt_essay = task._build_prompt(profile, scholarship, application, AssistantTaskType.ESSAY, "Ini adalah draft saya")
    assert "Ini adalah draft saya" in prompt_essay
    assert "ESSAY" in prompt_essay

@pytest.mark.asyncio
async def test_assistant_endpoint_unauthorized(client):
    app_id = uuid4()
    res = client.post(f"/api/v1/applications/{app_id}/ai-assistant", json={
        "task_type": "cv"
    })
    # Since it's unauthorized
    assert res.status_code == 401
