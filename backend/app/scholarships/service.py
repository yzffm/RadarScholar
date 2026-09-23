import math
from uuid import UUID

from sqlalchemy.orm import Session

from app.scholarships import repository
from app.scholarships.models import Scholarship
from app.scholarships.schemas import ScholarshipListResponse


def get_scholarships_paginated(
    db: Session,
    page: int = 1,
    page_size: int = 20,
    search: str | None = None,
    status: str | None = None,
) -> ScholarshipListResponse:
    """Get paginated list of scholarships."""
    # Ensure sane pagination
    page = max(1, page)
    page_size = max(1, min(page_size, 50))
    skip = (page - 1) * page_size

    items, total = repository.get_scholarships(
        db=db,
        skip=skip,
        limit=page_size,
        search=search,
        status=status,
    )

    total_pages = math.ceil(total / page_size) if total > 0 else 0

    return ScholarshipListResponse(
        items=items,
        page=page,
        page_size=page_size,
        total=total,
        total_pages=total_pages
    )

def get_scholarship(db: Session, id: UUID) -> Scholarship | None:
    """Get a single scholarship by ID."""
    return repository.get_scholarship_by_id(db, id)
