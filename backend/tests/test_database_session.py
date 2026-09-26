from sqlalchemy.engine import Engine

from app.core.config import settings
from app.database.session import get_engine


def test_sqlite_engine_does_not_use_postgres_pool_options(monkeypatch):
    monkeypatch.setattr(settings, "DATABASE_URL", "sqlite:///:memory:")

    engine = get_engine()

    try:
        assert isinstance(engine, Engine)
        assert engine.url.get_backend_name() == "sqlite"
    finally:
        engine.dispose()
