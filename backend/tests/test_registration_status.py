"""Registration-status derivation, status filters, and API exposure (Fase E)."""

import uuid
from datetime import datetime, timedelta

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.core.time import utc_now
from app.database.base import Base
from app.database.session import get_db
from app.main import app
from app.scholarships import repository
from app.scholarships.models import Scholarship, ScholarshipSource
from app.scholarships.schemas import ScholarshipResponse
from app.scholarships.status import RegistrationStatus, derive_registration_status
from app.users.models import DegreeLevel, UserProfile

NOW = datetime(2026, 10, 23, 12, 0, 0)


# ---------------------------------------------------------------------------
# Pure derivation
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("deadline", "is_active", "expected"),
    [
        # No deadline -> UNKNOWN regardless of the (uninformative) is_active flag.
        (None, True, RegistrationStatus.UNKNOWN),
        (None, False, RegistrationStatus.UNKNOWN),
        # Future deadline.
        (NOW + timedelta(days=3), True, RegistrationStatus.OPEN),
        (NOW + timedelta(days=3), False, RegistrationStatus.CLOSED),
        # Boundary: deadline == now is still open (deadline >= now).
        (NOW, True, RegistrationStatus.OPEN),
        # Deadline passed, even though the crawler could not refresh the row.
        (NOW - timedelta(seconds=1), True, RegistrationStatus.CLOSED),
        (NOW - timedelta(days=30), True, RegistrationStatus.CLOSED),
        (NOW - timedelta(days=30), False, RegistrationStatus.CLOSED),
    ],
)
def test_derive_registration_status(deadline, is_active, expected):
    assert derive_registration_status(deadline, is_active, now=NOW) == expected


def test_derive_registration_status_defaults_to_current_clock():
    assert derive_registration_status(utc_now() + timedelta(hours=1), True) == (
        RegistrationStatus.OPEN
    )
    assert derive_registration_status(utc_now() - timedelta(hours=1), True) == (
        RegistrationStatus.CLOSED
    )


# ---------------------------------------------------------------------------
# Repository filters against an in-memory database
# ---------------------------------------------------------------------------


@pytest.fixture
def db_session():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()
    try:
        yield session
    finally:
        session.close()
        engine.dispose()


def _add(
    session: Session,
    source: ScholarshipSource,
    title: str,
    deadline: datetime | None,
    is_active: bool,
) -> Scholarship:
    row = Scholarship(
        id=uuid.uuid4(),
        source_id=source.id,
        title=title,
        summary=f"Ringkasan {title}",
        description=f"Deskripsi {title}",
        deadline=deadline,
        application_url=f"https://example.org/{title.replace(' ', '-').lower()}",
        is_active=is_active,
        data_origin="CRAWLER_LIVE",
        last_verified_live_at=NOW,
    )
    session.add(row)
    session.flush()
    return row


@pytest.fixture
def seeded(db_session: Session):
    source = ScholarshipSource(
        id=uuid.uuid4(),
        provider_name="Provider Uji",
        source_url="https://example.org/",
    )
    db_session.add(source)
    db_session.flush()
    rows = {
        "open": _add(db_session, source, "Open", NOW + timedelta(days=5), True),
        "open_today": _add(db_session, source, "Open Today", NOW, True),
        "expired_but_flag_true": _add(
            db_session, source, "Expired Flag True", NOW - timedelta(days=2), True
        ),
        "future_but_marked_inactive": _add(
            db_session, source, "Future Marked Inactive", NOW + timedelta(days=5), False
        ),
        "unknown_active_flag": _add(db_session, source, "Unknown Flag True", None, True),
        "unknown_inactive_flag": _add(db_session, source, "Unknown Flag False", None, False),
    }
    db_session.commit()
    return rows


def _ids(items) -> set[uuid.UUID]:
    return {item.id for item in items}


def test_active_filter_requires_known_future_deadline(db_session, seeded):
    items, total = repository.get_scholarships(db_session, status="active", now=NOW)

    assert _ids(items) == {seeded["open"].id, seeded["open_today"].id}
    assert total == 2


def test_inactive_filter_is_deadline_passed_or_marked_inactive(db_session, seeded):
    items, total = repository.get_scholarships(db_session, status="inactive", now=NOW)

    assert _ids(items) == {
        seeded["expired_but_flag_true"].id,
        seeded["future_but_marked_inactive"].id,
    }
    assert total == 2


def test_unknown_deadline_rows_only_appear_in_unfiltered_list(db_session, seeded):
    unknown_ids = {
        seeded["unknown_active_flag"].id,
        seeded["unknown_inactive_flag"].id,
    }

    active, _ = repository.get_scholarships(db_session, status="active", now=NOW)
    inactive, _ = repository.get_scholarships(db_session, status="inactive", now=NOW)
    everything, total = repository.get_scholarships(db_session, now=NOW)

    assert not (_ids(active) & unknown_ids)
    assert not (_ids(inactive) & unknown_ids)
    assert unknown_ids <= _ids(everything)
    assert total == len(seeded)


def test_active_and_inactive_filters_are_disjoint_and_exclude_unknown(db_session, seeded):
    active, _ = repository.get_scholarships(db_session, status="active", now=NOW)
    inactive, _ = repository.get_scholarships(db_session, status="inactive", now=NOW)

    assert not (_ids(active) & _ids(inactive))
    assert len(active) + len(inactive) == len(seeded) - 2  # minus the two unknowns


def test_not_closed_filter_keeps_open_and_unknown_only(db_session, seeded):
    items, _ = repository.get_scholarships(db_session, status="not_closed", now=NOW)

    assert _ids(items) == {
        seeded["open"].id,
        seeded["open_today"].id,
        seeded["unknown_active_flag"].id,
        seeded["unknown_inactive_flag"].id,
    }


def test_expired_scholarship_never_appears_active_even_if_crawler_never_refreshed(
    db_session, seeded
):
    """E2: is_active stays True in the DB, but the query-time clock closes it."""
    row = seeded["expired_but_flag_true"]
    assert row.is_active is True  # stored flag untouched (stale crawler)

    active, _ = repository.get_scholarships(db_session, status="active", now=NOW)
    inactive, _ = repository.get_scholarships(db_session, status="inactive", now=NOW)

    assert row.id not in _ids(active)
    assert row.id in _ids(inactive)
    # And one day earlier it *was* open.
    earlier, _ = repository.get_scholarships(
        db_session, status="active", now=NOW - timedelta(days=3)
    )
    assert row.id in _ids(earlier)


def test_response_schema_exposes_registration_status(db_session, seeded):
    unknown = ScholarshipResponse.model_validate(seeded["unknown_active_flag"])
    expired = ScholarshipResponse.model_validate(seeded["expired_but_flag_true"])
    future = ScholarshipResponse.model_validate(
        _add(
            db_session,
            seeded["open"].source,
            "Far Future",
            utc_now() + timedelta(days=10),
            True,
        )
    )

    assert unknown.registration_status == RegistrationStatus.UNKNOWN
    assert expired.registration_status == RegistrationStatus.CLOSED
    assert future.registration_status == RegistrationStatus.OPEN
    assert unknown.model_dump(mode="json")["registration_status"] == "UNKNOWN"


# ---------------------------------------------------------------------------
# HTTP API
# ---------------------------------------------------------------------------


@pytest.fixture
def api_client(db_session):
    def _override():
        yield db_session

    app.dependency_overrides[get_db] = _override
    try:
        yield TestClient(app)
    finally:
        app.dependency_overrides.pop(get_db, None)


def test_api_list_returns_registration_status_and_filters(api_client, db_session):
    source = ScholarshipSource(
        id=uuid.uuid4(), provider_name="API Provider", source_url="https://api.example.org/"
    )
    db_session.add(source)
    db_session.flush()
    live = _add(db_session, source, "Api Open", utc_now() + timedelta(days=4), True)
    expired = _add(db_session, source, "Api Expired", utc_now() - timedelta(days=4), True)
    unknown = _add(db_session, source, "Api Unknown", None, False)
    db_session.commit()

    everything = api_client.get("/api/v1/scholarships").json()["items"]
    statuses = {item["id"]: item["registration_status"] for item in everything}
    assert statuses == {
        str(live.id): "OPEN",
        str(expired.id): "CLOSED",
        str(unknown.id): "UNKNOWN",
    }

    active = api_client.get("/api/v1/scholarships?status=active").json()["items"]
    inactive = api_client.get("/api/v1/scholarships?status=inactive").json()["items"]
    assert {item["id"] for item in active} == {str(live.id)}
    assert {item["id"] for item in inactive} == {str(expired.id)}

    detail = api_client.get(f"/api/v1/scholarships/{unknown.id}").json()
    assert detail["registration_status"] == "UNKNOWN"
    assert detail["deadline"] is None


def test_matched_endpoint_excludes_closed_but_keeps_open_and_unknown(
    api_client, db_session, monkeypatch
):
    source = ScholarshipSource(
        id=uuid.uuid4(), provider_name="Match Provider", source_url="https://m.example.org/"
    )
    db_session.add(source)
    db_session.flush()
    live = _add(db_session, source, "Match Open", utc_now() + timedelta(days=4), True)
    expired = _add(db_session, source, "Match Expired", utc_now() - timedelta(days=4), True)
    unknown = _add(db_session, source, "Match Unknown", None, False)
    db_session.commit()

    app.dependency_overrides[get_current_user] = lambda: AuthUser(
        id="test-user-id", email="test@example.com"
    )
    monkeypatch.setattr(
        "app.scholarships.router.get_profile",
        lambda *a, **k: UserProfile(gpa=3.5, semester=3, degree_level=DegreeLevel.S1),
    )
    try:
        items = api_client.get("/api/v1/scholarships/matched").json()["items"]
    finally:
        app.dependency_overrides.pop(get_current_user, None)

    returned = {item["scholarship"]["id"] for item in items}
    assert str(live.id) in returned
    assert str(unknown.id) in returned
    assert str(expired.id) not in returned

