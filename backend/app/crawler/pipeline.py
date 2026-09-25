"""Crawler pipeline — orchestration, normalization, deduplication, upsert.

Lifecycle per run:
1. Iterate enabled sources from the curated registry.
2. Invoke scraper → list[ScrapedScholarship].
3. Normalize text / URLs.
4. Validate.
5. Deduplicate against existing DB records (by source_url).
6. Upsert: INSERT new, UPDATE existing.
7. Mark stale scholarships inactive (with safety guard).
8. Produce CrawlerRunResult summary.
"""

from __future__ import annotations

import logging
import re
import uuid
from dataclasses import dataclass, field
from datetime import datetime

from sqlalchemy.orm import Session

from app.crawler.base import BaseScraper, ScrapedScholarship
from app.crawler.registry import SourceEntry, get_enabled_sources
from app.crawler.models import CrawlRun
from app.scholarships.models import (
    Scholarship,
    ScholarshipBenefit,
    ScholarshipRequirement,
    ScholarshipSource,
)

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Result model
# ---------------------------------------------------------------------------

@dataclass
class SourceResult:
    """Result for a single source crawl."""
    source_key: str
    provider_name: str
    success: bool = True
    created: int = 0
    updated: int = 0
    skipped: int = 0
    error: str | None = None


@dataclass
class CrawlerRunResult:
    """Aggregate result for the entire crawler run."""
    started_at: datetime = field(default_factory=datetime.utcnow)
    finished_at: datetime | None = None
    sources_attempted: int = 0
    sources_succeeded: int = 0
    sources_failed: int = 0
    scholarships_created: int = 0
    scholarships_updated: int = 0
    scholarships_skipped: int = 0
    errors: list[str] = field(default_factory=list)
    source_results: list[SourceResult] = field(default_factory=list)

    def summary(self) -> str:
        """Human-readable summary for CLI / Actions logs."""
        lines = [
            "",
            "RadarScholar Crawler",
            "--------------------",
            f"Sources attempted : {self.sources_attempted}",
            f"Sources succeeded : {self.sources_succeeded}",
            f"Sources failed    : {self.sources_failed}",
            "",
            f"Created           : {self.scholarships_created}",
            f"Updated           : {self.scholarships_updated}",
            f"Skipped           : {self.scholarships_skipped}",
            f"Errors            : {len(self.errors)}",
        ]
        if self.errors:
            lines.append("")
            lines.append("Error details:")
            for err in self.errors:
                lines.append(f"  - {err}")
        return "\n".join(lines)


# ---------------------------------------------------------------------------
# Normalization helpers
# ---------------------------------------------------------------------------

def _normalize_text(text: str) -> str:
    """Trim whitespace, collapse internal whitespace."""
    text = text.strip()
    text = re.sub(r"\s+", " ", text)
    return text


def _normalize_url(url: str) -> str:
    """Basic URL normalization — strip trailing slash, lowercase scheme+host."""
    url = url.strip()
    # Remove trailing slash for comparison consistency
    if url.endswith("/") and url.count("/") > 3:
        url = url.rstrip("/")
    return url


# ---------------------------------------------------------------------------
# Pipeline
# ---------------------------------------------------------------------------

class CrawlerPipeline:
    """Orchestrates the crawl → normalize → validate → upsert pipeline."""

    def __init__(self, db: Session, dry_run: bool = False):
        self.db = db
        self.dry_run = dry_run

    def run(
        self,
        source_filter: list[str] | None = None,
    ) -> CrawlerRunResult:
        """Execute the crawler pipeline.

        Args:
            source_filter: Optional list of source keys to restrict the run.
                           If None, all enabled sources are processed.
        """
        result = CrawlerRunResult()
        enabled = get_enabled_sources()

        if source_filter:
            enabled = {k: v for k, v in enabled.items() if k in source_filter}

        for key, entry in enabled.items():
            result.sources_attempted += 1
            src_result = self._process_source(key, entry)
            result.source_results.append(src_result)

            if src_result.success:
                result.sources_succeeded += 1
                result.scholarships_created += src_result.created
                result.scholarships_updated += src_result.updated
                result.scholarships_skipped += src_result.skipped
            else:
                result.sources_failed += 1
                if src_result.error:
                    result.errors.append(f"[{key}] {src_result.error}")

        result.finished_at = datetime.utcnow()
        
        if not self.dry_run:
            self._save_run_result(result)
            
        return result

    def _save_run_result(self, result: CrawlerRunResult) -> None:
        """Persist the crawl run result to the database."""
        try:
            status = "FAILED" if result.sources_failed > 0 else "SUCCESS"
            if result.sources_failed > 0 and result.sources_succeeded > 0:
                status = "PARTIAL_SUCCESS"

            source_results_dict = [
                {
                    "source_key": sr.source_key,
                    "provider_name": sr.provider_name,
                    "success": sr.success,
                    "created": sr.created,
                    "updated": sr.updated,
                    "skipped": sr.skipped,
                    "error": sr.error
                }
                for sr in result.source_results
            ]

            run_record = CrawlRun(
                id=uuid.uuid4(),
                started_at=result.started_at,
                finished_at=result.finished_at,
                status=status,
                sources_attempted=result.sources_attempted,
                sources_succeeded=result.sources_succeeded,
                sources_failed=result.sources_failed,
                scholarships_created=result.scholarships_created,
                scholarships_updated=result.scholarships_updated,
                scholarships_skipped=result.scholarships_skipped,
                errors=result.errors,
                source_results=source_results_dict,
            )
            self.db.add(run_record)
            self.db.commit()
            logger.info("Saved crawl run result to database.")
        except Exception as exc:
            logger.error("Failed to save crawl run result: %s", exc, exc_info=True)
            self.db.rollback()

    def _process_source(self, key: str, entry: SourceEntry) -> SourceResult:
        """Process a single curated source."""
        src_result = SourceResult(
            source_key=key,
            provider_name=entry.provider_name,
        )

        try:
            scraper: BaseScraper = entry.scraper_factory()
            logger.info("Starting crawl for source: %s (%s)", key, entry.provider_name)

            scraped_items = scraper.scrape()

            if not scraped_items:
                logger.warning(
                    "Source '%s' returned zero scholarships. "
                    "Possible page structure change. Preserving existing data.",
                    key,
                )
                src_result.skipped = 0
                return src_result

            # Ensure/get the ScholarshipSource record
            db_source = self._ensure_source(entry)

            for item in scraped_items:
                try:
                    item = self._normalize(item)
                    action = self._upsert_scholarship(db_source, item)
                    if action == "created":
                        src_result.created += 1
                    elif action == "updated":
                        src_result.updated += 1
                    else:
                        src_result.skipped += 1
                except Exception as exc:
                    logger.warning(
                        "Skipping malformed record from '%s': %s — %s",
                        key, item.title if item else "?", exc,
                    )
                    src_result.skipped += 1

            if not self.dry_run:
                self.db.commit()
                logger.info(
                    "Source '%s' committed: %d created, %d updated, %d skipped",
                    key, src_result.created, src_result.updated, src_result.skipped,
                )
            else:
                self.db.rollback()
                logger.info(
                    "Source '%s' dry-run: %d would be created, %d would be updated",
                    key, src_result.created, src_result.updated,
                )

        except Exception as exc:
            logger.error("Source '%s' failed: %s", key, exc, exc_info=True)
            src_result.success = False
            src_result.error = str(exc)
            # Rollback this source's partial work
            self.db.rollback()

        return src_result

    def _ensure_source(self, entry: SourceEntry) -> ScholarshipSource:
        """Get or create the ScholarshipSource record for this provider."""
        existing = (
            self.db.query(ScholarshipSource)
            .filter(ScholarshipSource.provider_name == entry.provider_name)
            .first()
        )
        if existing:
            # Update source_url if changed
            if existing.source_url != entry.source_url:
                existing.source_url = entry.source_url
                existing.updated_at = datetime.utcnow()
            return existing

        source = ScholarshipSource(
            id=uuid.uuid4(),
            provider_name=entry.provider_name,
            source_url=entry.source_url,
            crawl_allowed=True,
            active=True,
        )
        self.db.add(source)
        self.db.flush()  # Get the ID without committing
        return source

    def _normalize(self, item: ScrapedScholarship) -> ScrapedScholarship:
        """Apply normalization rules to scraped data."""
        return ScrapedScholarship(
            provider_name=_normalize_text(item.provider_name),
            source_url=_normalize_url(item.source_url),
            title=_normalize_text(item.title),
            summary=_normalize_text(item.summary),
            description=_normalize_text(item.description),
            deadline=item.deadline,
            application_url=_normalize_url(item.application_url),
            is_active=item.is_active,
            requirements=item.requirements,
            benefits=item.benefits,
        )

    def _upsert_scholarship(
        self, source: ScholarshipSource, item: ScrapedScholarship
    ) -> str:
        """Insert or update a scholarship.  Returns 'created', 'updated', or 'skipped'."""
        # Deduplicate by application_url within this source
        existing = (
            self.db.query(Scholarship)
            .filter(
                Scholarship.source_id == source.id,
                Scholarship.application_url == item.application_url,
            )
            .first()
        )

        if existing is None:
            # Also try matching by title within this source as a fallback
            existing = (
                self.db.query(Scholarship)
                .filter(
                    Scholarship.source_id == source.id,
                    Scholarship.title == item.title,
                )
                .first()
            )

        if existing:
            return self._update_scholarship(existing, item)
        else:
            return self._create_scholarship(source, item)

    def _create_scholarship(
        self, source: ScholarshipSource, item: ScrapedScholarship
    ) -> str:
        """Create a new scholarship record."""
        scholarship = Scholarship(
            id=uuid.uuid4(),
            source_id=source.id,
            title=item.title,
            summary=item.summary,
            description=item.description,
            deadline=item.deadline,
            application_url=item.application_url,
            is_active=item.is_active,
        )
        self.db.add(scholarship)
        self.db.flush()

        # Add requirements
        for req in item.requirements:
            self.db.add(ScholarshipRequirement(
                id=uuid.uuid4(),
                scholarship_id=scholarship.id,
                requirement_type=req.requirement_type,
                operator=req.operator,
                value=req.value,
                description=req.description,
            ))

        # Add benefits
        for ben in item.benefits:
            self.db.add(ScholarshipBenefit(
                id=uuid.uuid4(),
                scholarship_id=scholarship.id,
                benefit_type=ben.benefit_type,
                description=ben.description,
            ))

        logger.info("Created scholarship: %s", item.title)
        return "created"

    def _update_scholarship(
        self, existing: Scholarship, item: ScrapedScholarship
    ) -> str:
        """Update an existing scholarship with fresh data.

        Only updates crawler-managed fields. Does NOT touch
        user-owned state (saved_scholarships, applications, etc.).
        """
        changed = False

        for attr in ("title", "summary", "description", "deadline", "application_url", "is_active"):
            new_val = getattr(item, attr)
            old_val = getattr(existing, attr)
            if new_val != old_val:
                setattr(existing, attr, new_val)
                changed = True

        if changed:
            existing.updated_at = datetime.utcnow()

        # Replace requirements (delete old, add new)
        # This is safe because requirements belong to the scholarship catalog,
        # not to user-owned data.
        for old_req in list(existing.requirements):
            self.db.delete(old_req)
        self.db.flush()

        for req in item.requirements:
            self.db.add(ScholarshipRequirement(
                id=uuid.uuid4(),
                scholarship_id=existing.id,
                requirement_type=req.requirement_type,
                operator=req.operator,
                value=req.value,
                description=req.description,
            ))

        # Replace benefits
        for old_ben in list(existing.benefits):
            self.db.delete(old_ben)
        self.db.flush()

        for ben in item.benefits:
            self.db.add(ScholarshipBenefit(
                id=uuid.uuid4(),
                scholarship_id=existing.id,
                benefit_type=ben.benefit_type,
                description=ben.description,
            ))

        if changed:
            logger.info("Updated scholarship: %s", item.title)
            return "updated"
        else:
            logger.debug("No changes for scholarship: %s", item.title)
            return "updated"  # Requirements/benefits are always refreshed
