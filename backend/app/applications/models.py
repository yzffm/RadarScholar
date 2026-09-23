import enum
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.users.models import UserProfile
    from app.scholarships.models import Scholarship

from app.database.base import Base


class ApplicationStatus(str, enum.Enum):
    """Status tracker for scholarship applications."""

    PLANNED = "PLANNED"
    IN_PROGRESS = "IN_PROGRESS"
    SUBMITTED = "SUBMITTED"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    WITHDRAWN = "WITHDRAWN"


class SavedScholarship(Base):
    """Saved Scholarship association model."""

    __tablename__ = "saved_scholarships"
    __table_args__ = (
        UniqueConstraint("user_id", "scholarship_id", name="uix_saved_user_scholarship"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    # user_id maps to auth.users.id, which is string UUID in our models
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("user_profiles.id", ondelete="CASCADE"), index=True)
    scholarship_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("scholarships.id", ondelete="CASCADE"), index=True)
    saved_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user: Mapped["UserProfile"] = relationship()
    scholarship: Mapped["Scholarship"] = relationship()


class Application(Base):
    """Scholarship Application Tracking model."""

    __tablename__ = "applications"
    __table_args__ = (
        UniqueConstraint("user_id", "scholarship_id", name="uix_application_user_scholarship"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[str] = mapped_column(UUID(as_uuid=False), ForeignKey("user_profiles.id", ondelete="CASCADE"), index=True)
    scholarship_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("scholarships.id", ondelete="CASCADE"), index=True)
    status: Mapped[ApplicationStatus] = mapped_column(Enum(ApplicationStatus, name="application_status_enum"), default=ApplicationStatus.PLANNED, index=True)
    target_deadline: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user: Mapped["UserProfile"] = relationship()
    scholarship: Mapped["Scholarship"] = relationship()
    tasks: Mapped[list["ApplicationTask"]] = relationship("ApplicationTask", back_populates="application", cascade="all, delete-orphan")


class ApplicationTask(Base):
    """Tasks checklist for an application."""

    __tablename__ = "application_tasks"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    application_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("applications.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(255))
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    due_date: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    application: Mapped["Application"] = relationship(back_populates="tasks")
