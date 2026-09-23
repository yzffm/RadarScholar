"""Database session management for RadarScholar.

Provides async SQLAlchemy session factory connected to PostgreSQL
via the DATABASE_URL environment variable.
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings


def get_engine():
    """Create SQLAlchemy engine from DATABASE_URL."""
    if not settings.DATABASE_URL:
        raise RuntimeError(
            "DATABASE_URL is not configured. "
            "Set it in .env or environment variables."
        )
    return create_engine(
        settings.DATABASE_URL,
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
    )


# Lazy engine — only created when DATABASE_URL is available.
_engine = None
_SessionLocal = None


def _init_session():
    """Initialize engine and session factory on first use."""
    global _engine, _SessionLocal
    if _engine is None:
        _engine = get_engine()
        _SessionLocal = sessionmaker(
            bind=_engine,
            autocommit=False,
            autoflush=False,
        )


def get_db() -> Session:
    """FastAPI dependency: yields a database session per request.

    Usage:
        @router.get("/example")
        def example(db: Session = Depends(get_db)):
            ...
    """
    _init_session()
    db = _SessionLocal()
    try:
        yield db
    finally:
        db.close()
