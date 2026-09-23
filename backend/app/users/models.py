"""User Profile SQLAlchemy model.

Stores user academic profile, experience, and interests data.
The primary key `id` maps to Supabase `auth.users.id` UUID.

All profile fields from Technical Docs §4 are included to
avoid field mismatches in future milestones (M5 Matching, M9 AI Assistant).
"""

import enum

from sqlalchemy import (
    JSON,
    Column,
    DateTime,
    Enum,
    Float,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from datetime import datetime

from app.database.base import Base


class DegreeLevel(str, enum.Enum):
    """Academic degree levels supported by RadarScholar."""

    D3 = "D3"
    D4 = "D4"
    S1 = "S1"
    S2 = "S2"
    S3 = "S3"


class UserProfile(Base):
    """User profile table.

    Maps 1:1 with Supabase auth.users via the `id` column.
    Contains academic data, experience, and interest fields
    used for scholarship matching (M5) and AI assistance (M9).
    """

    __tablename__ = "user_profiles"

    # Primary key matches Supabase auth.users.id
    id = Column(
        UUID(as_uuid=False),
        primary_key=True,
        comment="Supabase auth user UUID",
    )

    # Basic identity
    email = Column(String(320), nullable=False, index=True)
    display_name = Column(String(255), nullable=True)
    avatar_url = Column(Text, nullable=True)

    # === Academic (Technical Docs §4 — Academic) ===
    university = Column(String(255), nullable=True)
    faculty = Column(String(255), nullable=True)
    major = Column(String(255), nullable=True)
    degree_level = Column(
        Enum(DegreeLevel, name="degree_level_enum"),
        nullable=True,
    )
    semester = Column(Integer, nullable=True)
    gpa = Column(Float, nullable=True)

    # === Experience (Technical Docs §4 — Experience) ===
    # Stored as PostgreSQL arrays for MVP simplicity.
    # Can be normalized to separate tables if needed later.
    organizations = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    achievements = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    competitions = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    volunteering = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    internships = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    certifications = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    skills = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)

    # === Interests (Technical Docs §4 — Interests) ===
    career_interests = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    fields_of_interest = Column(JSON().with_variant(ARRAY(Text), 'postgresql'), nullable=True, default=list)
    goals = Column(Text, nullable=True)

    # === Timestamps ===
    created_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
    )
    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    def __repr__(self) -> str:
        return f"<UserProfile id={self.id} email={self.email}>"
