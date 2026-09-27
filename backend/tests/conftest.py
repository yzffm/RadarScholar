"""Shared isolated database and dependency fixtures for backend tests."""

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

# Import every model module before create_all so the complete test schema is
# registered without consulting the application's persistent local database.
import app.applications.models  # noqa: F401, E402
import app.crawler.models  # noqa: F401, E402
import app.scholarships.models  # noqa: F401, E402
import app.users.models  # noqa: F401, E402
from app.database.base import Base
from app.database.session import get_db
from app.main import app as fastapi_app


@pytest.fixture
def test_engine():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    try:
        yield engine
    finally:
        engine.dispose()


@pytest.fixture
def db_session(test_engine):
    session = sessionmaker(bind=test_engine, class_=Session)()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture(autouse=True)
def isolate_database_and_overrides(test_engine):
    """Route FastAPI DB dependencies to an isolated in-memory database."""
    previous_overrides = fastapi_app.dependency_overrides.copy()

    def override_get_db():
        session = sessionmaker(bind=test_engine, class_=Session)()
        try:
            yield session
        finally:
            session.close()

    fastapi_app.dependency_overrides[get_db] = override_get_db
    try:
        yield
    finally:
        fastapi_app.dependency_overrides.clear()
        fastapi_app.dependency_overrides.update(previous_overrides)
