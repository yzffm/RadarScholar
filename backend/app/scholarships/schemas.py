"""Pydantic schemas for Scholarships.

Defines schemas for request and response validation for scholarship
data, sources, requirements, and benefits.
"""

from datetime import date, datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, HttpUrl

# ==============================================================================
# ScholarshipSource Schemas
# ==============================================================================

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
    description: str
    degree_level: str
    status: str
    deadline: Optional[date] = None
    funding_type: str
    target_country: Optional[str] = None
    original_url: HttpUrl

class ScholarshipCreate(ScholarshipBase):
    source_id: UUID
    benefits: Optional[List[ScholarshipBenefitCreate]] = Field(default_factory=list)
    requirements: Optional[List[ScholarshipRequirementCreate]] = Field(default_factory=list)

class ScholarshipResponse(ScholarshipBase):
    id: UUID
    source_id: UUID
    created_at: datetime
    updated_at: datetime
    
    # We can include nested lists of benefits and requirements in the response
    benefits: List[ScholarshipBenefitResponse] = Field(default_factory=list)
    requirements: List[ScholarshipRequirementResponse] = Field(default_factory=list)
    source: Optional[ScholarshipSourceResponse] = None

    model_config = ConfigDict(from_attributes=True)
