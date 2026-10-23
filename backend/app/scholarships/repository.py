from datetime import datetime
from uuid import UUID

from sqlalchemy import nulls_last, or_
from sqlalchemy.orm import Session, joinedload

from app.core.time import utc_now
from app.scholarships.models import Scholarship, ScholarshipSource
from app.scholarships.status import closed_clause, open_clause

# Public filter values (see ``ScholarshipStatus`` in router.py) plus one
# internal value used by the matcher: everything that is *not* known to be
# closed (i.e. OPEN or UNKNOWN registration status).
STATUS_ACTIVE = "active"
STATUS_INACTIVE = "inactive"
STATUS_NOT_CLOSED = "not_closed"


def get_scholarships(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    search: str = None,
    status: str = None,
    now: datetime | None = None,
) -> tuple[list[Scholarship], int]:
    """Retrieve scholarships with optional filtering, search, and pagination.

    ``status`` is evaluated against the current clock (``now``), not just the
    stored ``is_active`` flag:

    * ``active``     -> deadline known, not past, and ``is_active``
    * ``inactive``   -> deadline known and (past or ``is_active`` false)
    * ``not_closed`` -> everything except ``inactive`` (open + unknown)
    * ``None``       -> no filter; scholarships without a deadline only appear here
    """
    reference = now if now is not None else utc_now()
    query = db.query(Scholarship).options(joinedload(Scholarship.source))

    if status is not None:
        normalized = status.lower()
        if normalized == STATUS_ACTIVE:
            query = query.filter(open_clause(Scholarship, reference))
        elif normalized == STATUS_INACTIVE:
            query = query.filter(closed_clause(Scholarship, reference))
        elif normalized == STATUS_NOT_CLOSED:
            query = query.filter(~closed_clause(Scholarship, reference))

    if search:
        search_term = f"%{search}%"
        # We need to outerjoin if we want to search on source safely without dropping rows lacking a source
        query = query.outerjoin(Scholarship.source).filter(
            or_(
                Scholarship.title.ilike(search_term),
                Scholarship.summary.ilike(search_term),
                Scholarship.description.ilike(search_term),
                ScholarshipSource.provider_name.ilike(search_term)
            )
        )

    # Ordering: deadline ascending (nulls last), then ID
    query = query.order_by(
        nulls_last(Scholarship.deadline.asc()),
        Scholarship.id.asc()
    )

    total = query.count()
    items = query.offset(skip).limit(limit).all()

    return items, total

def get_scholarship_by_id(db: Session, id: UUID) -> Scholarship | None:
    """Retrieve a single scholarship by ID, eager loading related data."""
    return db.query(Scholarship).options(
        joinedload(Scholarship.source),
        joinedload(Scholarship.benefits),
        joinedload(Scholarship.requirements)
    ).filter(Scholarship.id == id).first()
