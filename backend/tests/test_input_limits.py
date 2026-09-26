import pytest
from pydantic import ValidationError

from app.ai.schemas import AssistantRequest, AssistantTaskType, MatchExplanation
from app.applications.schemas import ApplicationCreate, ApplicationUpdate


def test_application_notes_are_bounded():
    with pytest.raises(ValidationError):
        ApplicationCreate(
            scholarship_id="00000000-0000-0000-0000-000000000001",
            notes="N" * 5001,
        )

    with pytest.raises(ValidationError):
        ApplicationUpdate(notes="N" * 5001)


def test_ai_draft_and_response_collections_are_bounded():
    with pytest.raises(ValidationError):
        AssistantRequest(
            task_type=AssistantTaskType.ESSAY,
            draft_text="D" * 20001,
        )

    with pytest.raises(ValidationError):
        MatchExplanation(
            summary="summary",
            strengths=["reason"] * 21,
            weaknesses=[],
            unknowns=[],
        )

    with pytest.raises(ValidationError):
        MatchExplanation(
            summary="summary",
            strengths=["R" * 1001],
            weaknesses=[],
            unknowns=[],
        )
