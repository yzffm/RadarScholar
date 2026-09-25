"""Admin and Source Monitoring router.

Endpoints:
    GET  /api/v1/admin/sources         - List all scholarship sources with status
    POST /api/v1/admin/sources/{id}    - Enable/disable a source
    GET  /api/v1/admin/crawls          - List recent crawl runs
    GET  /api/v1/admin/crawls/{id}     - Get details of a specific crawl run
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.auth.dependencies import get_admin_user
from app.auth.models import AuthUser
from app.database.session import get_db
from app.crawler.models import CrawlRun
from app.scholarships.models import ScholarshipSource

router = APIRouter(prefix="/api/v1/admin", tags=["Admin"], dependencies=[Depends(get_admin_user)])

@router.get("/sources")
def list_sources(db: Session = Depends(get_db)):
    """List all scholarship sources."""
    sources = db.query(ScholarshipSource).order_by(ScholarshipSource.provider_name).all()
    return sources

@router.post("/sources/{source_id}/toggle")
def toggle_source(source_id: str, db: Session = Depends(get_db)):
    """Toggle the active status of a source."""
    source = db.query(ScholarshipSource).filter(ScholarshipSource.id == source_id).first()
    if not source:
        raise HTTPException(status_code=404, detail="Source not found")
    
    source.active = not source.active
    source.crawl_allowed = source.active
    db.commit()
    db.refresh(source)
    return source

@router.get("/crawls")
def list_crawl_runs(limit: int = 10, offset: int = 0, db: Session = Depends(get_db)):
    """List recent crawler runs."""
    runs = db.query(CrawlRun).order_by(desc(CrawlRun.started_at)).limit(limit).offset(offset).all()
    total = db.query(CrawlRun).count()
    return {
        "items": runs,
        "total": total,
        "limit": limit,
        "offset": offset,
    }

@router.get("/crawls/{run_id}")
def get_crawl_run(run_id: str, db: Session = Depends(get_db)):
    """Get details of a specific crawl run."""
    run = db.query(CrawlRun).filter(CrawlRun.id == run_id).first()
    if not run:
        raise HTTPException(status_code=404, detail="Crawl run not found")
    return run
