"""Pydantic schemas for Scholarships.

Defines schemas for request and response validation for scholarship
data, sources, requirements, and benefits.
"""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, HttpUrl

# ==============================================================================
# ScholarshipSource Schemas
# ==============================================================================
from app.matching.schemas import MatchResult


class ScholarshipSourceBase(BaseModel):
    provider_name: str
    source_url: HttpUrl
    crawl_allowed: bool = True
    active: bool = True

class ScholarshipSourceCreate(ScholarshipSourceBase):
    pass

class ScholarshipSourceResponse(ScholarshipSourceBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# ==============================================================================
# ScholarshipBenefit Schemas
# ==============================================================================

class ScholarshipBenefitBase(BaseModel):
    benefit_type: str
    description: str

class ScholarshipBenefitCreate(ScholarshipBenefitBase):
    pass

class ScholarshipBenefitResponse(ScholarshipBenefitBase):
    id: UUID
    scholarship_id: UUID

    model_config = ConfigDict(from_attributes=True)

# ==============================================================================
# ScholarshipRequirement Schemas
# ==============================================================================

class ScholarshipRequirementBase(BaseModel):
    requirement_type: str
    operator: str
    value: Any
    description: str

class ScholarshipRequirementCreate(ScholarshipRequirementBase):
    pass

class ScholarshipRequirementResponse(ScholarshipRequirementBase):
    id: UUID
    scholarship_id: UUID

    model_config = ConfigDict(from_attributes=True)

# ==============================================================================
# Scholarship Schemas
# ==============================================================================

class ScholarshipBase(BaseModel):
    title: str
    summary: str
    description: str
    deadline: datetime | None = None
    application_url: str
    is_active: bool = True

class ScholarshipCreate(ScholarshipBase):
    source_id: UUID
    benefits: list[ScholarshipBenefitCreate] | None = Field(default_factory=list)
    requirements: list[ScholarshipRequirementCreate] | None = Field(default_factory=list)

class ScholarshipResponse(ScholarshipBase):
    id: UUID
    source_id: UUID
    created_at: datetime
    updated_at: datetime

    benefits: list[ScholarshipBenefitResponse] = Field(default_factory=list)
    requirements: list[ScholarshipRequirementResponse] = Field(default_factory=list)
    source: ScholarshipSourceResponse | None = None

    model_config = ConfigDict(from_attributes=True)

class ScholarshipListResponse(BaseModel):
    items: list[ScholarshipResponse]
    page: int
    page_size: int
    total: int
    total_pages: int

class MatchedScholarshipResponse(BaseModel):
    scholarship: ScholarshipResponse
    match: MatchResult

class MatchedScholarshipListResponse(BaseModel):
    items: list[MatchedScholarshipResponse]
    page: int
    page_size: int
    total: int
    total_pages: int
