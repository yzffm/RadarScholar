"""Registration-status derivation for scholarships.

Single source of truth for whether a scholarship's registration is open, closed
or unknown.  The status is derived **at query/serialization time** from the
stored ``deadline`` / ``is_active`` columns and the current clock, so a source
that stops being reachable can never leave an expired scholarship looking open.

Rules (``now`` is naive UTC, like every datetime column in the database):

* ``deadline IS NULL``                       -> ``UNKNOWN``
  The crawler sets ``is_active = False`` for *every* record that has no
  source-stated deadline, so ``is_active`` carries no information when the
  deadline is missing.  We never claim "open" or "closed" without a date.
* ``is_active`` is false (deadline known)    -> ``CLOSED``
  (e.g. the record disappeared from its source and was marked stale)
* ``deadline < now``                         -> ``CLOSED``
* otherwise (``is_active`` and ``deadline >= now``) -> ``OPEN``
"""

from __future__ import annotations

from datetime import datetime
from enum import Enum

from sqlalchemy import and_, or_
from sqlalchemy.sql.elements import ColumnElement

from app.core.time import utc_now


class RegistrationStatus(str, Enum):
    OPEN = "OPEN"
    CLOSED = "CLOSED"
    UNKNOWN = "UNKNOWN"


def derive_registration_status(
    deadline: datetime | None,
    is_active: bool,
    now: datetime | None = None,
) -> RegistrationStatus:
    """Return the registration status for the given stored values."""
    if deadline is None:
        return RegistrationStatus.UNKNOWN
    reference = now if now is not None else utc_now()
    if not is_active or deadline < reference:
        return RegistrationStatus.CLOSED
    return RegistrationStatus.OPEN


def open_clause(model, now: datetime) -> ColumnElement[bool]:
    """SQL expression equivalent of ``RegistrationStatus.OPEN``."""
    return and_(
        model.is_active.is_(True),
        model.deadline.is_not(None),
        model.deadline >= now,
    )


def closed_clause(model, now: datetime) -> ColumnElement[bool]:
    """SQL expression equivalent of ``RegistrationStatus.CLOSED``."""
    return and_(
        model.deadline.is_not(None),
        or_(model.is_active.is_(False), model.deadline < now),
    )


def unknown_clause(model) -> ColumnElement[bool]:
    """SQL expression equivalent of ``RegistrationStatus.UNKNOWN``."""
    return model.deadline.is_(None)

