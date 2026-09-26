from enum import Enum
from typing import Annotated

from pydantic import BaseModel, Field

AIListItem = Annotated[str, Field(max_length=1000)]


class MatchExplanation(BaseModel):
    summary: str = Field(..., max_length=4000, description="A short paragraph explaining the overall match in Indonesian.")
    strengths: list[AIListItem] = Field(..., max_length=20, description="List of reasons why the profile matches well.")
    weaknesses: list[AIListItem] = Field(..., max_length=20, description="List of reasons why the profile does not match or falls short.")
    unknowns: list[AIListItem] = Field(..., max_length=20, description="List of criteria that cannot be evaluated due to missing information or requiring verification.")

class AssistantTaskType(str, Enum):
    CV = "cv"
    MOTIVATION_LETTER = "motivation_letter"
    ESSAY = "essay"
    INTERVIEW = "interview"

class AssistantRequest(BaseModel):
    task_type: AssistantTaskType
    draft_text: str | None = Field(
        default=None,
        max_length=20000,
    )

class AssistantResponse(BaseModel):
    feedback: str = Field(..., description="Readable Indonesian text providing feedback or advice.")
    actionable_tips: list[AIListItem] = Field(default_factory=list, max_length=20, description="Concrete next steps or tips for the user.")
