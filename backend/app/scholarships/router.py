from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.database.session import get_db
from app.matching.schemas import RelevanceTier
from app.matching.service import MatchingService
from app.scholarships import service
from app.scholarships.schemas import (
    MatchedScholarshipListResponse,
    MatchedScholarshipResponse,
    ScholarshipListResponse,
    ScholarshipResponse,
)
from app.users.service import get_profile

router = APIRouter(prefix="/scholarships", tags=["Scholarships"])

@router.get("", response_model=ScholarshipListResponse)
def get_scholarships(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=50, description="Items per page"),
    search: str | None = Query(None, description="Search term for title, description, or provider"),
    status: str | None = Query(None, description="Filter by status (e.g., 'active' or 'inactive')"),
    db: Session = Depends(get_db),
):
    """
    Get a paginated list of scholarships.
    
    Supports filtering by search query and active status.
    Ordered by deadline ascending (nulls last).
    """
    return service.get_scholarships_paginated(
        db=db,
        page=page,
        page_size=page_size,
        search=search,
        status=status,
    )

@router.get("/matched", response_model=MatchedScholarshipListResponse)
def get_matched_scholarships(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=50, description="Items per page"),
    search: str | None = Query(None, description="Search term for title, description, or provider"),
    db: Session = Depends(get_db),
    user: AuthUser = Depends(get_current_user),
):
    """
    Get a paginated list of scholarships matched against the authenticated user's profile.
    
    Ordered deterministically by relevance tier, number of matched/unmatched criteria, etc.
    """
    profile = get_profile(db, user)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profil pengguna belum dilengkapi."
        )

    # We fetch the active scholarships first (can be optimized later)
    # The M4 service already supports getting scholarships paginated, but we want all to rank them,
    # or a sufficient number. Since MVP, let's fetch all active matching the search, evaluate, rank, then paginate.
    # Note: For production with thousands, this requires a DB-level engine or pre-calculation.
    # We will fetch all active matching search (without pagination), rank them, then paginate.

    scholarships_list = service.get_scholarships_paginated(
        db=db,
        page=1,
        page_size=1000, # Fetch up to 1000 for in-memory ranking
        search=search,
        status="active"
    ).items

    matching_service = MatchingService()
    matched_results = []

    for sch in scholarships_list:
        match_res = matching_service.match(profile, sch)
        matched_results.append(
            MatchedScholarshipResponse(
                scholarship=sch,
                match=match_res
            )
        )

    relevance_order = {
        RelevanceTier.SANGAT_RELEVAN: 1,
        RelevanceTier.RELEVAN: 2,
        RelevanceTier.MUNGKIN_RELEVAN: 3,
        RelevanceTier.PERLU_DICEK: 4,
        RelevanceTier.BELUM_CUKUP_INFORMASI: 5,
        RelevanceTier.TIDAK_MEMENUHI: 6,
    }

    def sort_key(item: MatchedScholarshipResponse):
        # 1. relevance tier (lower is better)
        # 2. fewer NOT_MATCH
        # 3. more MATCH (so negative)
        # 4. fewer UNKNOWN + NEEDS_VERIFICATION
        # 5. deadline (earlier is better, fallback to far future if None)
        # 6. title
        dl = item.scholarship.deadline
        dl_ts = dl.timestamp() if dl else float('inf')

        return (
            relevance_order[item.match.relevance],
            item.match.not_matched_count,
            -item.match.matched_count,
            item.match.unknown_count + item.match.needs_verification_count,
            dl_ts,
            item.scholarship.title
        )

    matched_results.sort(key=sort_key)

    # Paginate manually
    total = len(matched_results)
    total_pages = (total + page_size - 1) // page_size
    start = (page - 1) * page_size
    end = start + page_size
    paginated_items = matched_results[start:end]

    return MatchedScholarshipListResponse(
        items=paginated_items,
        page=page,
        page_size=page_size,
        total=total,
        total_pages=total_pages
    )

@router.get("/{scholarship_id}", response_model=ScholarshipResponse)
def get_scholarship(
    scholarship_id: UUID,
    db: Session = Depends(get_db),
):
    """
    Get a single scholarship by its ID.
    
    Includes detailed information like source, benefits, and requirements.
    """
    scholarship = service.get_scholarship(db=db, id=scholarship_id)
    if not scholarship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Scholarship not found",
        )
    return scholarship

@router.get("/{scholarship_id}/match", response_model=MatchedScholarshipResponse)
def get_scholarship_match(
    scholarship_id: UUID,
    db: Session = Depends(get_db),
    user: AuthUser = Depends(get_current_user),
):
    """
    Get match result for a single scholarship.
    """
    profile = get_profile(db, user)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profil pengguna belum dilengkapi."
        )

    scholarship = service.get_scholarship(db=db, id=scholarship_id)
    if not scholarship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Scholarship not found",
        )

    matching_service = MatchingService()
    match_res = matching_service.match(profile, scholarship)

    return MatchedScholarshipResponse(
        scholarship=scholarship,
        match=match_res
    )
