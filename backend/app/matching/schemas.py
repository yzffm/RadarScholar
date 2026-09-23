import enum
from typing import Any, List
from pydantic import BaseModel, ConfigDict


class CriterionState(str, enum.Enum):
    MATCH = "MATCH"
    NOT_MATCH = "NOT_MATCH"
    UNKNOWN = "UNKNOWN"
    NOT_APPLICABLE = "NOT_APPLICABLE"
    NEEDS_VERIFICATION = "NEEDS_VERIFICATION"


class RelevanceTier(str, enum.Enum):
    SANGAT_RELEVAN = "SANGAT_RELEVAN"
    RELEVAN = "RELEVAN"
    MUNGKIN_RELEVAN = "MUNGKIN_RELEVAN"
    PERLU_DICEK = "PERLU_DICEK"
    BELUM_CUKUP_INFORMASI = "BELUM_CUKUP_INFORMASI"
    TIDAK_MEMENUHI = "TIDAK_MEMENUHI"


class CriterionEvaluation(BaseModel):
    requirement_type: str
    operator: str
    required_value: Any
    actual_value: Any | None
    state: CriterionState
    explanation: str
    
    model_config = ConfigDict(from_attributes=True)


class MatchResult(BaseModel):
    relevance: RelevanceTier
    criterion_evaluations: List[CriterionEvaluation]
    matched_count: int
    not_matched_count: int
    unknown_count: int
    needs_verification_count: int
    explanation: str

    model_config = ConfigDict(from_attributes=True)
