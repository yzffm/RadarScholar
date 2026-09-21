"""User Profile API router.

All endpoints require authentication via the `get_current_user` dependency.
User identity is always derived from the verified JWT — never from
client-provided IDs (agents.md §12 Security).

Endpoints:
    GET    /api/v1/users/me   — Get current user's profile
    POST   /api/v1/users/me   — Create profile (idempotent)
    PUT    /api/v1/users/me   — Update profile (partial)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.database.session import get_db
from app.users import service
from app.users.schemas import (
    UserProfileCreate,
    UserProfileResponse,
    UserProfileUpdate,
)

router = APIRouter(prefix="/api/v1/users", tags=["Users"])


@router.get("/me", response_model=UserProfileResponse)
def get_my_profile(
    user: AuthUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get the authenticated user's profile.

    Returns 404 if the user hasn't created a profile yet.
    """
    profile = service.get_profile(db, user)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil belum dibuat. Silakan lengkapi profil Anda.",
        )
    return profile


@router.post(
    "/me",
    response_model=UserProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_my_profile(
    data: UserProfileCreate,
    user: AuthUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create the authenticated user's profile.

    Idempotent: if a profile already exists, returns it (200 OK).
    """
    profile = service.create_profile(db, user, data)
    return profile


@router.put("/me", response_model=UserProfileResponse)
def update_my_profile(
    data: UserProfileUpdate,
    user: AuthUser = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update the authenticated user's profile.

    Partial update: only provided fields are changed.
    Returns 404 if no profile exists.
    """
    profile = service.update_profile(db, user, data)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil belum dibuat. Buat profil terlebih dahulu.",
        )
    return profile
