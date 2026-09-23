import uuid
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.main import app
from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.database.session import get_db
from app.scholarships.models import Scholarship, ScholarshipSource
from app.applications.models import SavedScholarship, Application, ApplicationTask


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def db_session():
    # Use the same generator FastAPI uses
    db = next(get_db())
    yield db
    db.close()


@pytest.fixture
def test_scholarship(db_session: Session):
    # Create source
    source = ScholarshipSource(provider_name="Test Provider", source_url="http://test.com")
    db_session.add(source)
    db_session.commit()
    
    # Create scholarship
    scholarship = Scholarship(
        source_id=source.id,
        title="Test Scholarship",
        summary="Test Summary",
        description="Test Desc",
        application_url="http://test.com/apply"
    )
    db_session.add(scholarship)
    db_session.commit()
    db_session.refresh(scholarship)
    
    yield scholarship
    
    # Cleanup
    db_session.delete(scholarship)
    db_session.delete(source)
    db_session.commit()


@pytest.fixture
def mock_auth():
    user_id = str(uuid.uuid4())
    def _mock_get_current_user():
        return AuthUser(id=user_id, email="test@example.com")
    
    app.dependency_overrides[get_current_user] = _mock_get_current_user
    yield user_id
    app.dependency_overrides.clear()


def test_save_scholarship(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test saving a scholarship."""
    response = client.post(f"/api/v1/scholarships/{test_scholarship.id}/save")
    assert response.status_code == 200
    data = response.json()
    assert data["scholarship_id"] == str(test_scholarship.id)

    # Check DB
    saved = db_session.query(SavedScholarship).filter_by(scholarship_id=test_scholarship.id).first()
    assert saved is not None

    # Duplicate save should be idempotent
    response = client.post(f"/api/v1/scholarships/{test_scholarship.id}/save")
    assert response.status_code == 200


def test_get_saved_scholarships(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test listing saved scholarships."""
    client.post(f"/api/v1/scholarships/{test_scholarship.id}/save")
    
    response = client.get("/api/v1/saved-scholarships")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["scholarship"]["id"] == str(test_scholarship.id)


def test_unsave_scholarship(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test unsaving a scholarship."""
    client.post(f"/api/v1/scholarships/{test_scholarship.id}/save")

    response = client.delete(f"/api/v1/scholarships/{test_scholarship.id}/save")
    assert response.status_code == 204

    # DB should be empty
    saved = db_session.query(SavedScholarship).filter_by(scholarship_id=test_scholarship.id).first()
    assert saved is None


def test_create_application(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test tracking a new application."""
    response = client.post(
        "/api/v1/applications",
        json={
            "scholarship_id": str(test_scholarship.id),
            "notes": "My notes"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["scholarship_id"] == str(test_scholarship.id)
    assert data["status"] == "PLANNED"
    assert data["notes"] == "My notes"

    # Duplicate should fail with 409
    response2 = client.post(
        "/api/v1/applications",
        json={"scholarship_id": str(test_scholarship.id)}
    )
    assert response2.status_code == 409


def test_update_application(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test updating application status."""
    create_resp = client.post(
        "/api/v1/applications",
        json={"scholarship_id": str(test_scholarship.id)}
    )
    app_id = create_resp.json()["id"]

    response = client.patch(
        f"/api/v1/applications/{app_id}",
        json={
            "status": "IN_PROGRESS",
            "notes": "Updated notes"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "IN_PROGRESS"
    assert data["notes"] == "Updated notes"


def test_application_tasks(client: TestClient, db_session: Session, test_scholarship: Scholarship, mock_auth: str):
    """Test adding and completing tasks."""
    create_resp = client.post(
        "/api/v1/applications",
        json={"scholarship_id": str(test_scholarship.id)}
    )
    app_id = create_resp.json()["id"]

    # Add task
    task_resp = client.post(
        f"/api/v1/applications/{app_id}/tasks",
        json={"title": "Submit transcript"}
    )
    assert task_resp.status_code == 201
    task_id = task_resp.json()["id"]

    # Mark completed
    complete_resp = client.patch(
        f"/api/v1/applications/{app_id}/tasks/{task_id}",
        json={"is_completed": True}
    )
    assert complete_resp.status_code == 200
    assert complete_resp.json()["is_completed"] is True

    # Delete task
    del_resp = client.delete(f"/api/v1/applications/{app_id}/tasks/{task_id}")
    assert del_resp.status_code == 204
