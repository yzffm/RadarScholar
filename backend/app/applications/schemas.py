from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.applications.models import ApplicationStatus
from app.scholarships.schemas import ScholarshipResponse


class SavedScholarshipResponse(BaseModel):
    """Response schema for a saved scholarship."""

    id: UUID
    user_id: str
    scholarship_id: UUID
    saved_at: datetime
    # The scholarship summary
    scholarship: ScholarshipResponse

    model_config = ConfigDict(from_attributes=True)


class ApplicationTaskCreate(BaseModel):
    """Schema for creating a new application task."""

    title: str = Field(..., min_length=1, max_length=255)
    due_date: datetime | None = None


class ApplicationTaskUpdate(BaseModel):
    """Schema for updating an application task."""

    title: str | None = Field(None, min_length=1, max_length=255)
    is_completed: bool | None = None
    due_date: datetime | None = None


class ApplicationTaskResponse(BaseModel):
    """Response schema for an application task."""

    id: UUID
    application_id: UUID
    title: str
    is_completed: bool
    due_date: datetime | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ApplicationCreate(BaseModel):
    """Schema for starting to track a new scholarship application."""

    scholarship_id: UUID
    target_deadline: datetime | None = None
    notes: str | None = None


class ApplicationUpdate(BaseModel):
    """Schema for updating an existing application tracking."""

    status: ApplicationStatus | None = None
    target_deadline: datetime | None = None
    notes: str | None = None


class ApplicationResponse(BaseModel):
    """Response schema for an application with its tasks and scholarship."""

    id: UUID
    user_id: str
    scholarship_id: UUID
    status: ApplicationStatus
    target_deadline: datetime | None
    notes: str | None
    created_at: datetime
    updated_at: datetime

    scholarship: ScholarshipResponse
    tasks: list[ApplicationTaskResponse] = Field(default_factory=list)

    @property
    def tasks_total(self) -> int:
        return len(self.tasks)

    @property
    def tasks_completed(self) -> int:
        return sum(1 for task in self.tasks if task.is_completed)

    model_config = ConfigDict(from_attributes=True)
