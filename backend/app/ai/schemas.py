from enum import Enum
from pydantic import BaseModel, Field

class MatchExplanation(BaseModel):
    summary: str = Field(..., description="A short paragraph explaining the overall match in Indonesian.")
    strengths: list[str] = Field(..., description="List of reasons why the profile matches well.")
    weaknesses: list[str] = Field(..., description="List of reasons why the profile does not match or falls short.")
    unknowns: list[str] = Field(..., description="List of criteria that cannot be evaluated due to missing information or requiring verification.")

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
    actionable_tips: list[str] = Field(default_factory=list, description="Concrete next steps or tips for the user.")
