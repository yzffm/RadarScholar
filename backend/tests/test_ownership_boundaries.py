import uuid

import pytest
from fastapi import HTTPException

from app.applications.models import Application, ApplicationTask, SavedScholarship
from app.applications.schemas import (
    ApplicationCreate,
    ApplicationTaskCreate,
    ApplicationTaskUpdate,
    ApplicationUpdate,
)
from app.applications.service import ApplicationService
from app.scholarships.models import Scholarship, ScholarshipSource


def make_scholarship(db_session):
    source = ScholarshipSource(
        provider_name="Ownership Test Provider",
        source_url=f"https://example.com/{uuid.uuid4()}",
    )
    db_session.add(source)
    db_session.flush()
    scholarship = Scholarship(
        source_id=source.id,
        title="Ownership Test Scholarship",
        summary="Test",
        description="Test",
        application_url=f"https://example.com/apply/{uuid.uuid4()}",
    )
    db_session.add(scholarship)
    db_session.commit()
    return scholarship


def test_application_read_update_delete_are_user_scoped(db_session):
    scholarship = make_scholarship(db_session)
    owner = str(uuid.uuid4())
    other_user = str(uuid.uuid4())
    service = ApplicationService(db_session)
    application = service.create_application(
        owner,
        ApplicationCreate(scholarship_id=scholarship.id, notes="private"),
    )

    with pytest.raises(HTTPException) as read_error:
        service.get_application(application.id, other_user)
    assert read_error.value.status_code == 404

    with pytest.raises(HTTPException) as update_error:
        service.update_application(
            application.id,
            other_user,
            ApplicationUpdate(notes="tampered"),
        )
    assert update_error.value.status_code == 404

    with pytest.raises(HTTPException) as delete_error:
        service.delete_application(application.id, other_user)
    assert delete_error.value.status_code == 404
    assert db_session.query(Application).filter_by(id=application.id).one().notes == "private"


def test_task_update_and_delete_are_user_and_application_scoped(db_session):
    scholarship = make_scholarship(db_session)
    owner = str(uuid.uuid4())
    other_user = str(uuid.uuid4())
    service = ApplicationService(db_session)
    application = service.create_application(
        owner,
        ApplicationCreate(scholarship_id=scholarship.id),
    )
    task = service.add_task(
        application.id,
        owner,
        ApplicationTaskCreate(title="Private task"),
    )

    with pytest.raises(HTTPException) as update_error:
        service.update_task(
            application.id,
            task.id,
            other_user,
            ApplicationTaskUpdate(is_completed=True),
        )
    assert update_error.value.status_code == 404

    with pytest.raises(HTTPException) as delete_error:
        service.delete_task(application.id, task.id, other_user)
    assert delete_error.value.status_code == 404
    assert db_session.query(ApplicationTask).filter_by(id=task.id).one().title == "Private task"


def test_saved_scholarships_are_user_scoped(db_session):
    scholarship = make_scholarship(db_session)
    service = ApplicationService(db_session)
    owner = str(uuid.uuid4())
    other_user = str(uuid.uuid4())
    service.save_scholarship(owner, scholarship.id)

    assert len(service.get_user_saved_scholarships(owner)) == 1
    assert service.get_user_saved_scholarships(other_user) == []

    service.unsave_scholarship(other_user, scholarship.id)
    assert db_session.query(SavedScholarship).count() == 1
