"""Health check endpoint.

Provides a simple health check for monitoring and
Flutter frontend connectivity verification.
"""

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import text

from app.core.config import settings
from app.database.session import get_engine

router = APIRouter()


@router.get("/health")
async def health_check() -> dict:
    """Return application health status.

    Used by:
    - Flutter frontend to verify backend connectivity (CPMK 1 evidence)
    - Infrastructure monitoring
    """
    return {
        "status": "ok",
        "version": settings.APP_VERSION,
    }


@router.get("/health/ready")
def readiness_check() -> dict:
    """Check that the process and its database dependency are ready."""
    engine = None
    try:
        engine = get_engine()
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Layanan belum siap.",
        )
    finally:
        if engine is not None:
            engine.dispose()

    return {
        "status": "ready",
        "version": settings.APP_VERSION,
    }
