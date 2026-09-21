"""User Profile service — business logic layer.

Handles profile CRUD operations separated from the API router
to maintain clean MVC architecture.
"""

from sqlalchemy.orm import Session

from app.auth.models import AuthUser
from app.users.models import UserProfile
from app.users.schemas import UserProfileCreate, UserProfileUpdate


def get_profile(db: Session, user: AuthUser) -> UserProfile | None:
    """Get user profile by authenticated user ID."""
    return db.query(UserProfile).filter(UserProfile.id == user.id).first()


def create_profile(
    db: Session,
    user: AuthUser,
    data: UserProfileCreate,
) -> UserProfile:
    """Create a new user profile.

    If a profile already exists for this user, returns the existing one.
    This makes the endpoint idempotent.
    """
    existing = get_profile(db, user)
    if existing is not None:
        return existing

    profile = UserProfile(
        id=user.id,
        email=user.email,
        **data.model_dump(exclude_none=True),
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


def update_profile(
    db: Session,
    user: AuthUser,
    data: UserProfileUpdate,
) -> UserProfile | None:
    """Update an existing user profile.

    Only updates fields that are explicitly provided (not None).
    Returns None if no profile exists.
    """
    profile = get_profile(db, user)
    if profile is None:
        return None

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)

    db.commit()
    db.refresh(profile)
    return profile
