import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import JSON, Boolean, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class ScholarshipSource(Base):
    __tablename__ = "scholarship_sources"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    provider_name: Mapped[str] = mapped_column(String, index=True)
    source_url: Mapped[str] = mapped_column(String)
    crawl_allowed: Mapped[bool] = mapped_column(Boolean, default=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    scholarships: Mapped[list["Scholarship"]] = relationship(back_populates="source", cascade="all, delete-orphan")


class Scholarship(Base):
    __tablename__ = "scholarships"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    source_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("scholarship_sources.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String, index=True)
    summary: Mapped[str] = mapped_column(Text)
    description: Mapped[str] = mapped_column(Text)
    deadline: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    application_url: Mapped[str] = mapped_column(String)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    source: Mapped["ScholarshipSource"] = relationship(back_populates="scholarships")
    benefits: Mapped[list["ScholarshipBenefit"]] = relationship(back_populates="scholarship", cascade="all, delete-orphan")
    requirements: Mapped[list["ScholarshipRequirement"]] = relationship(back_populates="scholarship", cascade="all, delete-orphan")


class ScholarshipBenefit(Base):
    __tablename__ = "scholarship_benefits"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    scholarship_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("scholarships.id", ondelete="CASCADE"))
    benefit_type: Mapped[str] = mapped_column(String) # e.g., LIVING_ALLOWANCE, TUITION_FEE
    description: Mapped[str] = mapped_column(Text)

    # Relationships
    scholarship: Mapped["Scholarship"] = relationship(back_populates="benefits")


class ScholarshipRequirement(Base):
    __tablename__ = "scholarship_requirements"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    scholarship_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("scholarships.id", ondelete="CASCADE"))
    requirement_type: Mapped[str] = mapped_column(String) # e.g., GPA, MAJOR, SEMESTER
    operator: Mapped[str] = mapped_column(String) # e.g., GTE, EQ, IN, CONTAINS
    value: Mapped[Any] = mapped_column(JSON().with_variant(JSONB, 'postgresql')) # Structured requirement data
    description: Mapped[str] = mapped_column(Text) # Original human-readable text

    # Relationships
    scholarship: Mapped["Scholarship"] = relationship(back_populates="requirements")
