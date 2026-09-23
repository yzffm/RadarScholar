import uuid
from collections.abc import Sequence

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.applications.schemas import (
    ApplicationCreate,
    ApplicationResponse,
    ApplicationTaskCreate,
    ApplicationTaskResponse,
    ApplicationTaskUpdate,
    ApplicationUpdate,
    SavedScholarshipResponse,
)
from app.applications.service import ApplicationService
from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.database.session import get_db

router = APIRouter()

def get_application_service(session: Session = Depends(get_db)) -> ApplicationService:
    return ApplicationService(session)

# --- Saved Scholarships ---

@router.get(
    "/saved-scholarships",
    response_model=list[SavedScholarshipResponse],
    summary="Get saved scholarships",
)
def get_saved_scholarships(
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> Sequence[SavedScholarshipResponse]:
    """Retrieve all saved scholarships for the authenticated user."""
    return service.get_user_saved_scholarships(current_user.id)

@router.post(
    "/scholarships/{scholarship_id}/save",
    response_model=SavedScholarshipResponse,
    summary="Save a scholarship",
)
def save_scholarship(
    scholarship_id: uuid.UUID,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> SavedScholarshipResponse:
    """Save a scholarship for later viewing."""
    return service.save_scholarship(current_user.id, scholarship_id)

@router.delete(
    "/scholarships/{scholarship_id}/save",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Unsave a scholarship",
)
def unsave_scholarship(
    scholarship_id: uuid.UUID,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> None:
    """Remove a scholarship from the saved list."""
    service.unsave_scholarship(current_user.id, scholarship_id)

# --- Applications ---

@router.get(
    "/applications",
    response_model=list[ApplicationResponse],
    summary="Get applications",
)
def get_applications(
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> Sequence[ApplicationResponse]:
    """Get all scholarship applications tracked by the user."""
    return service.get_user_applications(current_user.id)

@router.post(
    "/applications",
    response_model=ApplicationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create application tracker",
)
def create_application(
    obj_in: ApplicationCreate,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationResponse:
    """Start tracking a new scholarship application."""
    return service.create_application(current_user.id, obj_in)

@router.get(
    "/applications/{application_id}",
    response_model=ApplicationResponse,
    summary="Get application details",
)
def get_application(
    application_id: uuid.UUID,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationResponse:
    """Get details of a specific application tracker."""
    return service.get_application(application_id, current_user.id)

@router.patch(
    "/applications/{application_id}",
    response_model=ApplicationResponse,
    summary="Update application",
)
def update_application(
    application_id: uuid.UUID,
    obj_in: ApplicationUpdate,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationResponse:
    """Update application tracker status, deadline, or notes."""
    return service.update_application(application_id, current_user.id, obj_in)

@router.delete(
    "/applications/{application_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete application tracker",
)
def delete_application(
    application_id: uuid.UUID,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> None:
    """Delete an application tracker and all associated tasks."""
    service.delete_application(application_id, current_user.id)

# --- Application Tasks ---

@router.post(
    "/applications/{application_id}/tasks",
    response_model=ApplicationTaskResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add application task",
)
def add_application_task(
    application_id: uuid.UUID,
    obj_in: ApplicationTaskCreate,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationTaskResponse:
    """Add a new checklist task to an application."""
    return service.add_task(application_id, current_user.id, obj_in)

@router.patch(
    "/applications/{application_id}/tasks/{task_id}",
    response_model=ApplicationTaskResponse,
    summary="Update application task",
)
def update_application_task(
    application_id: uuid.UUID,
    task_id: uuid.UUID,
    obj_in: ApplicationTaskUpdate,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationTaskResponse:
    """Update a checklist task (e.g., mark as completed)."""
    return service.update_task(application_id, task_id, current_user.id, obj_in)

@router.delete(
    "/applications/{application_id}/tasks/{task_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete application task",
)
def delete_application_task(
    application_id: uuid.UUID,
    task_id: uuid.UUID,
    current_user: AuthUser = Depends(get_current_user),
    service: ApplicationService = Depends(get_application_service),
) -> None:
    """Remove a checklist task."""
    service.delete_task(application_id, task_id, current_user.id)
