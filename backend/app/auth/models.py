"""Authentication data models.

Pydantic models representing verified user identity
extracted from Supabase JWT tokens.
"""

from pydantic import BaseModel, Field


class AuthUser(BaseModel):
    """Verified user identity from JWT token.

    This is the authenticated context available to all
    protected endpoints via the `get_current_user` dependency.

    The `id` field maps to Supabase `auth.users.id` (UUID string).
    """

    id: str = Field(..., description="Supabase auth user UUID")
    email: str = Field(..., description="User email from JWT")
