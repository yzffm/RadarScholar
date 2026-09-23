import uuid
from collections.abc import Sequence

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.applications.models import Application, ApplicationTask, SavedScholarship
from app.applications.repository import (
    ApplicationRepository,
    ApplicationTaskRepository,
    SavedScholarshipRepository,
)
from app.applications.schemas import (
    ApplicationCreate,
    ApplicationTaskCreate,
    ApplicationTaskUpdate,
    ApplicationUpdate,
)
from app.scholarships.repository import get_scholarship_by_id


class ApplicationService:
    """Service for handling application and saved scholarship business logic."""

    def __init__(self, session: Session):
        self.session = session
        self.saved_repo = SavedScholarshipRepository(session)
        self.app_repo = ApplicationRepository(session)
        self.task_repo = ApplicationTaskRepository(session)

    # --- Saved Scholarships ---

    def get_user_saved_scholarships(self, user_id: str) -> Sequence[SavedScholarship]:
        return self.saved_repo.get_user_saved_scholarships(user_id)

    def save_scholarship(self, user_id: str, scholarship_id: uuid.UUID) -> SavedScholarship:
        # Validate scholarship exists
        scholarship = get_scholarship_by_id(self.session, scholarship_id)
        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Beasiswa tidak ditemukan."
            )

        # Check duplicate
        existing = self.saved_repo.get_by_user_and_scholarship(user_id, scholarship_id)
        if existing:
            # Idempotent behavior
            return existing

        return self.saved_repo.create(user_id, scholarship_id)

    def unsave_scholarship(self, user_id: str, scholarship_id: uuid.UUID) -> None:
        # Idempotent: returns success even if not found
        self.saved_repo.delete(user_id, scholarship_id)

    # --- Applications ---

    def get_user_applications(self, user_id: str) -> Sequence[Application]:
        return self.app_repo.get_user_applications(user_id)

    def get_application(self, application_id: uuid.UUID, user_id: str) -> Application:
        application = self.app_repo.get_by_id_and_user(application_id, user_id)
        if not application:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Aplikasi tidak ditemukan."
            )
        return application

    def create_application(self, user_id: str, obj_in: ApplicationCreate) -> Application:
        # Validate scholarship exists
        scholarship = get_scholarship_by_id(self.session, obj_in.scholarship_id)
        if not scholarship:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Beasiswa tidak ditemukan."
            )

        # Check duplicate
        existing = self.app_repo.get_by_user_and_scholarship(user_id, obj_in.scholarship_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Anda sudah membuat tracking aplikasi untuk beasiswa ini."
            )

        return self.app_repo.create(user_id, obj_in)

    def update_application(self, application_id: uuid.UUID, user_id: str, obj_in: ApplicationUpdate) -> Application:
        application = self.get_application(application_id, user_id)
        return self.app_repo.update(application, obj_in)

    def delete_application(self, application_id: uuid.UUID, user_id: str) -> None:
        deleted = self.app_repo.delete(application_id, user_id)
        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Aplikasi tidak ditemukan."
            )

    # --- Application Tasks ---

    def _verify_task_ownership(self, task_id: uuid.UUID, application_id: uuid.UUID, user_id: str) -> ApplicationTask:
        # 1. Verify application is owned by user
        application = self.get_application(application_id, user_id)

        # 2. Verify task exists
        task = self.task_repo.get_by_id(task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tugas tidak ditemukan."
            )

        # 3. Verify task belongs to application
        if task.application_id != application.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Tugas ini bukan bagian dari aplikasi yang diminta."
            )

        return task

    def add_task(self, application_id: uuid.UUID, user_id: str, obj_in: ApplicationTaskCreate) -> ApplicationTask:
        # Verify ownership of application
        application = self.get_application(application_id, user_id)
        return self.task_repo.create(application.id, obj_in)

    def update_task(self, application_id: uuid.UUID, task_id: uuid.UUID, user_id: str, obj_in: ApplicationTaskUpdate) -> ApplicationTask:
        task = self._verify_task_ownership(task_id, application_id, user_id)
        return self.task_repo.update(task, obj_in)

    def delete_task(self, application_id: uuid.UUID, task_id: uuid.UUID, user_id: str) -> None:
        self._verify_task_ownership(task_id, application_id, user_id)
        self.task_repo.delete(task_id)
