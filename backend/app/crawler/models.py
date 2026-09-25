import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text, JSON
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base

class CrawlRun(Base):
    """Stores the execution history of the crawler pipeline."""
    __tablename__ = "crawl_runs"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    started_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    status: Mapped[str] = mapped_column(String, default="RUNNING") # RUNNING, SUCCESS, FAILED
    
    sources_attempted: Mapped[int] = mapped_column(Integer, default=0)
    sources_succeeded: Mapped[int] = mapped_column(Integer, default=0)
    sources_failed: Mapped[int] = mapped_column(Integer, default=0)
    
    scholarships_created: Mapped[int] = mapped_column(Integer, default=0)
    scholarships_updated: Mapped[int] = mapped_column(Integer, default=0)
    scholarships_skipped: Mapped[int] = mapped_column(Integer, default=0)
    
    errors: Mapped[list[str]] = mapped_column(JSON().with_variant(JSONB, 'postgresql'), default=list)
    source_results: Mapped[list[dict[str, Any]]] = mapped_column(JSON().with_variant(JSONB, 'postgresql'), default=list)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
