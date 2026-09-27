"""Timezone-safe UTC helpers for database timestamps."""

from datetime import UTC, datetime


def utc_now() -> datetime:
    """Return a naive UTC datetime compatible with existing DB columns."""
    return datetime.now(UTC).replace(tzinfo=None)
