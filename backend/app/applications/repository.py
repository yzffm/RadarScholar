import uuid
from typing import Sequence

from sqlalchemy import delete, select
from sqlalchemy.orm import Session, joinedload

from app.applications.models import Application, ApplicationTask, SavedScholarship
from app.applications.schemas import (
    ApplicationCreate,
    ApplicationTaskCreate,
    ApplicationTaskUpdate,
    ApplicationUpdate,
)


class SavedScholarshipRepository:
    """Repository for managing saved scholarships."""

    def __init__(self, session: Session):
        self.session = session

    def get_user_saved_scholarships(self, user_id: str) -> Sequence[SavedScholarship]:
        """Get all saved scholarships for a user, ordered by saved_at desc."""
        stmt = (
            select(SavedScholarship)
            .where(SavedScholarship.user_id == user_id)
            .options(joinedload(SavedScholarship.scholarship))
            .order_by(SavedScholarship.saved_at.desc())
        )
        return self.session.execute(stmt).scalars().all()

    def get_by_user_and_scholarship(self, user_id: str, scholarship_id: uuid.UUID) -> SavedScholarship | None:
        """Find a saved scholarship by user and scholarship."""
        stmt = select(SavedScholarship).where(
            SavedScholarship.user_id == user_id,
            SavedScholarship.scholarship_id == scholarship_id,
        )
        return self.session.execute(stmt).scalar_one_or_none()

    def create(self, user_id: str, scholarship_id: uuid.UUID) -> SavedScholarship:
        """Create a new saved scholarship record."""
        saved = SavedScholarship(user_id=user_id, scholarship_id=scholarship_id)
        self.session.add(saved)
        self.session.commit()
        self.session.refresh(saved)
        return saved

    def delete(self, user_id: str, scholarship_id: uuid.UUID) -> bool:
        """Delete a saved scholarship by user and scholarship. Returns True if deleted."""
        stmt = delete(SavedScholarship).where(
            SavedScholarship.user_id == user_id,
            SavedScholarship.scholarship_id == scholarship_id,
        )
        result = self.session.execute(stmt)
        self.session.commit()
        return result.rowcount > 0


class ApplicationRepository:
    """Repository for managing tracked applications."""

    def __init__(self, session: Session):
        self.session = session

    def get_user_applications(self, user_id: str) -> Sequence[Application]:
        """Get all applications for a user, ordered by updated_at desc."""
        stmt = (
            select(Application)
            .where(Application.user_id == user_id)
            .options(
                joinedload(Application.scholarship),
                joinedload(Application.tasks),
            )
            .order_by(Application.updated_at.desc())
        )
        # Unique is needed because of joinedload on one-to-many (tasks)
        return self.session.execute(stmt).unique().scalars().all()

    def get_by_id_and_user(self, application_id: uuid.UUID, user_id: str) -> Application | None:
        """Get application by ID ensuring ownership."""
        stmt = (
            select(Application)
            .where(
                Application.id == application_id,
                Application.user_id == user_id,
            )
            .options(
                joinedload(Application.scholarship),
                joinedload(Application.tasks),
            )
        )
        return self.session.execute(stmt).unique().scalar_one_or_none()

    def get_by_user_and_scholarship(self, user_id: str, scholarship_id: uuid.UUID) -> Application | None:
        """Get application by user and scholarship ID."""
        stmt = select(Application).where(
            Application.user_id == user_id,
            Application.scholarship_id == scholarship_id,
        )
        return self.session.execute(stmt).scalar_one_or_none()

    def create(self, user_id: str, obj_in: ApplicationCreate) -> Application:
        """Create a new application tracker."""
        db_obj = Application(
            user_id=user_id,
            scholarship_id=obj_in.scholarship_id,
            target_deadline=obj_in.target_deadline,
            notes=obj_in.notes,
        )
        self.session.add(db_obj)
        self.session.commit()
        self.session.refresh(db_obj)
        return db_obj

    def update(self, db_obj: Application, obj_in: ApplicationUpdate) -> Application:
        """Update an application's details."""
        update_data = obj_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        
        self.session.add(db_obj)
        self.session.commit()
        self.session.refresh(db_obj)
        return db_obj

    def delete(self, application_id: uuid.UUID, user_id: str) -> bool:
        """Delete an application tracker (ownership enforced)."""
        stmt = delete(Application).where(
            Application.id == application_id,
            Application.user_id == user_id,
        )
        result = self.session.execute(stmt)
        self.session.commit()
        return result.rowcount > 0


class ApplicationTaskRepository:
    """Repository for managing application tasks."""

    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, task_id: uuid.UUID) -> ApplicationTask | None:
        """Get task by ID."""
        stmt = select(ApplicationTask).where(ApplicationTask.id == task_id)
        return self.session.execute(stmt).scalar_one_or_none()

    def create(self, application_id: uuid.UUID, obj_in: ApplicationTaskCreate) -> ApplicationTask:
        """Create a new task."""
        db_obj = ApplicationTask(
            application_id=application_id,
            title=obj_in.title,
            due_date=obj_in.due_date,
        )
        self.session.add(db_obj)
        self.session.commit()
        self.session.refresh(db_obj)
        return db_obj

    def update(self, db_obj: ApplicationTask, obj_in: ApplicationTaskUpdate) -> ApplicationTask:
        """Update task details."""
        update_data = obj_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        
        self.session.add(db_obj)
        self.session.commit()
        self.session.refresh(db_obj)
        return db_obj

    def delete(self, task_id: uuid.UUID) -> bool:
        """Delete a task by ID."""
        stmt = delete(ApplicationTask).where(ApplicationTask.id == task_id)
        result = self.session.execute(stmt)
        self.session.commit()
        return result.rowcount > 0
