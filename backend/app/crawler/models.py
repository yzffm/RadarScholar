"""SQLAlchemy models for crawler execution history."""

import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import JSON, DateTime, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.core.time import utc_now
from app.database.base import Base


class CrawlRun(Base):
    """Summary and diagnostics for one curated crawler execution."""

    __tablename__ = "crawl_runs"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    started_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    status: Mapped[str] = mapped_column(String, nullable=False)
    sources_attempted: Mapped[int] = mapped_column(Integer, nullable=False)
    sources_succeeded: Mapped[int] = mapped_column(Integer, nullable=False)
    sources_failed: Mapped[int] = mapped_column(Integer, nullable=False)
    scholarships_created: Mapped[int] = mapped_column(Integer, nullable=False)
    scholarships_updated: Mapped[int] = mapped_column(Integer, nullable=False)
    scholarships_skipped: Mapped[int] = mapped_column(Integer, nullable=False)
    errors: Mapped[list[str]] = mapped_column(
        JSON().with_variant(JSONB, "postgresql"), nullable=False
    )
    source_results: Mapped[list[dict[str, Any]]] = mapped_column(
        JSON().with_variant(JSONB, "postgresql"), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=utc_now, nullable=False
    )
