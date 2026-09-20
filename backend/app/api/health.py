"""Health check endpoint.

Provides a simple health check for monitoring and
Flutter frontend connectivity verification.
"""

from fastapi import APIRouter

from app.core.config import settings

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
