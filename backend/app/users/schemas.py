"""User Profile Pydantic schemas.

Request/response schemas for the user profile API endpoints.
Includes all fields from Technical Docs §4 for future milestone
compatibility (M5 Matching, M9 AI Assistant).
"""

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class DegreeLevelSchema(str, Enum):
    """Academic degree levels."""

    D3 = "D3"
    D4 = "D4"
    S1 = "S1"
    S2 = "S2"
    S3 = "S3"


class UserProfileCreate(BaseModel):
    """Schema for creating a user profile.

    All fields are optional because users may fill in
    their profile gradually after registration.
    """

    display_name: str | None = Field(None, max_length=255)

    # Academic
    university: str | None = Field(None, max_length=255)
    faculty: str | None = Field(None, max_length=255)
    major: str | None = Field(None, max_length=255)
    degree_level: DegreeLevelSchema | None = None
    semester: int | None = Field(None, ge=1, le=14)
    gpa: float | None = Field(None, ge=0.0, le=4.0)

    # Experience
    organizations: list[str] | None = None
    achievements: list[str] | None = None
    competitions: list[str] | None = None
    volunteering: list[str] | None = None
    internships: list[str] | None = None
    certifications: list[str] | None = None
    skills: list[str] | None = None

    # Interests
    career_interests: list[str] | None = None
    fields_of_interest: list[str] | None = None
    goals: str | None = None


class UserProfileUpdate(BaseModel):
    """Schema for updating a user profile.

    All fields optional — only provided fields are updated.
    """

    display_name: str | None = Field(None, max_length=255)

    # Academic
    university: str | None = Field(None, max_length=255)
    faculty: str | None = Field(None, max_length=255)
    major: str | None = Field(None, max_length=255)
    degree_level: DegreeLevelSchema | None = None
    semester: int | None = Field(None, ge=1, le=14)
    gpa: float | None = Field(None, ge=0.0, le=4.0)

    # Experience
    organizations: list[str] | None = None
    achievements: list[str] | None = None
    competitions: list[str] | None = None
    volunteering: list[str] | None = None
    internships: list[str] | None = None
    certifications: list[str] | None = None
    skills: list[str] | None = None

    # Interests
    career_interests: list[str] | None = None
    fields_of_interest: list[str] | None = None
    goals: str | None = None


class UserProfileResponse(BaseModel):
    """Schema for user profile API responses."""

    id: str
    email: str
    display_name: str | None = None
    avatar_url: str | None = None

    # Academic
    university: str | None = None
    faculty: str | None = None
    major: str | None = None
    degree_level: DegreeLevelSchema | None = None
    semester: int | None = None
    gpa: float | None = None

    # Experience
    organizations: list[str] = Field(default_factory=list)
    achievements: list[str] = Field(default_factory=list)
    competitions: list[str] = Field(default_factory=list)
    volunteering: list[str] = Field(default_factory=list)
    internships: list[str] = Field(default_factory=list)
    certifications: list[str] = Field(default_factory=list)
    skills: list[str] = Field(default_factory=list)

    # Interests
    career_interests: list[str] = Field(default_factory=list)
    fields_of_interest: list[str] = Field(default_factory=list)
    goals: str | None = None

    # Timestamps
    created_at: datetime
    updated_at: datetime

    # Admin
    is_admin: bool = False

    model_config = {"from_attributes": True}
