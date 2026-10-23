"""Pydantic schemas for Scholarships.

Defines schemas for request and response validation for scholarship
data, sources, requirements, and benefits.
"""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, HttpUrl, computed_field

# ==============================================================================
# ScholarshipSource Schemas
# ==============================================================================
from app.matching.schemas import MatchResult
from app.scholarships.status import RegistrationStatus, derive_registration_status


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
    data_origin: str = "CRAWLER"

class ScholarshipCreate(ScholarshipBase):
    source_id: UUID
    benefits: list[ScholarshipBenefitCreate] | None = Field(default_factory=list)
    requirements: list[ScholarshipRequirementCreate] | None = Field(default_factory=list)

class ScholarshipResponse(ScholarshipBase):
    id: UUID
    source_id: UUID
    created_at: datetime
    updated_at: datetime
    # NULL if this scholarship has never been confirmed against its live
    # source page (curated baseline only). See app/crawler/base.py's
    # is_live_verified for how this gets set.
    last_verified_live_at: datetime | None = None

    benefits: list[ScholarshipBenefitResponse] = Field(default_factory=list)
    requirements: list[ScholarshipRequirementResponse] = Field(default_factory=list)
    source: ScholarshipSourceResponse | None = None

    model_config = ConfigDict(from_attributes=True)

    @computed_field  # type: ignore[prop-decorator]
    @property
    def registration_status(self) -> RegistrationStatus:
        """OPEN / CLOSED / UNKNOWN, derived from deadline and the current time."""
        return derive_registration_status(self.deadline, self.is_active)

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
