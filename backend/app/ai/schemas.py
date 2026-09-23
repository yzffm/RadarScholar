from pydantic import BaseModel, Field

class MatchExplanation(BaseModel):
    summary: str = Field(..., description="A short paragraph explaining the overall match in Indonesian.")
    strengths: list[str] = Field(..., description="List of reasons why the profile matches well.")
    weaknesses: list[str] = Field(..., description="List of reasons why the profile does not match or falls short.")
    unknowns: list[str] = Field(..., description="List of criteria that cannot be evaluated due to missing information or requiring verification.")
