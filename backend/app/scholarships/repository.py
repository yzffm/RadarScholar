from uuid import UUID

from sqlalchemy import nulls_last, or_
from sqlalchemy.orm import Session, joinedload

from app.scholarships.models import Scholarship, ScholarshipSource


def get_scholarships(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    search: str = None,
    status: str = None
) -> tuple[list[Scholarship], int]:
    """Retrieve scholarships with optional filtering, search, and pagination."""
    query = db.query(Scholarship).options(joinedload(Scholarship.source))

    if status is not None:
        if status.lower() == "active":
            query = query.filter(Scholarship.is_active.is_(True))
        elif status.lower() == "inactive":
            query = query.filter(Scholarship.is_active.is_(False))

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
