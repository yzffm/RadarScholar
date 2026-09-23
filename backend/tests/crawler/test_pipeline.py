"""Integration tests for the crawler pipeline.

Tests the full pipeline with a mocked scraper (no internet).
Uses an in-memory SQLite database for isolation.
"""

from datetime import datetime
from unittest.mock import patch

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.crawler.base import ScrapedBenefit, ScrapedRequirement, ScrapedScholarship
from app.crawler.pipeline import CrawlerPipeline, _normalize_text, _normalize_url
from app.crawler.registry import SourceEntry
from app.database.base import Base
from app.scholarships.models import (
    Scholarship,
    ScholarshipBenefit,
    ScholarshipRequirement,
)

# ---------------------------------------------------------------------------
# Test fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def db_session():
    """Create an in-memory SQLite database session for testing."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
        engine.dispose()


def _make_scraped(
    title: str = "Test Scholarship",
    provider: str = "Test Provider",
    source_url: str = "https://example.com/scholarship",
    application_url: str = "https://example.com/apply",
    deadline: datetime | None = None,
) -> ScrapedScholarship:
    """Create a ScrapedScholarship for testing."""
    return ScrapedScholarship(
        provider_name=provider,
        source_url=source_url,
        title=title,
        summary="A test scholarship summary.",
        description="A test scholarship description.",
        deadline=deadline,
        application_url=application_url,
        is_active=True,
        requirements=[
            ScrapedRequirement(
                requirement_type="GPA",
                operator="GTE",
                value={"gpa": 3.0},
                description="IPK minimal 3.00",
            ),
        ],
        benefits=[
            ScrapedBenefit(
                benefit_type="TUITION_FEE",
                description="Biaya kuliah penuh",
            ),
        ],
    )


class FakeScraper:
    """A fake scraper for pipeline testing."""

    provider_name = "Test Provider"
    source_url = "https://example.com/scholarship"

    def __init__(self, items: list[ScrapedScholarship] | None = None):
        self._items = items or [_make_scraped()]

    def scrape(self) -> list[ScrapedScholarship]:
        return self._items


class FailingScraper:
    """A scraper that always raises an error."""

    provider_name = "Failing Provider"
    source_url = "https://fail.example.com"

    def scrape(self):
        raise RuntimeError("Source unavailable")


# ---------------------------------------------------------------------------
# Normalization tests
# ---------------------------------------------------------------------------

class TestNormalization:

    def test_normalize_text_trims(self):
        assert _normalize_text("  hello  ") == "hello"

    def test_normalize_text_collapses_whitespace(self):
        assert _normalize_text("hello   world") == "hello world"

    def test_normalize_url_strips_trailing_slash(self):
        assert _normalize_url("https://example.com/path/") == "https://example.com/path"

    def test_normalize_url_preserves_root(self):
        # Root URL with only scheme+host should keep its trailing slash if minimal
        url = _normalize_url("https://example.com/")
        # It has exactly 3 slashes so trailing slash is kept
        assert url == "https://example.com/"


# ---------------------------------------------------------------------------
# Pipeline integration tests
# ---------------------------------------------------------------------------

class TestPipelineNewRecord:
    """Test: source record → empty DB → one scholarship created."""

    def test_creates_scholarship(self, db_session: Session):
        fake_items = [_make_scraped()]
        mock_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper(fake_items),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            pipeline = CrawlerPipeline(db=db_session, dry_run=False)
            result = pipeline.run()

        assert result.sources_attempted == 1
        assert result.sources_succeeded == 1
        assert result.scholarships_created == 1
        assert result.scholarships_updated == 0

        # Verify DB
        scholarships = db_session.query(Scholarship).all()
        assert len(scholarships) == 1
        assert scholarships[0].title == "Test Scholarship"

        # Verify requirements
        reqs = db_session.query(ScholarshipRequirement).all()
        assert len(reqs) == 1
        assert reqs[0].requirement_type == "GPA"

        # Verify benefits
        bens = db_session.query(ScholarshipBenefit).all()
        assert len(bens) == 1


class TestPipelineNoduplicates:
    """Test: same source URL → crawler again → no duplicate."""

    def test_second_run_updates_not_duplicates(self, db_session: Session):
        fake_items = [_make_scraped()]
        mock_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper(fake_items),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            pipeline = CrawlerPipeline(db=db_session, dry_run=False)
            result1 = pipeline.run()
            result2 = pipeline.run()

        assert result1.scholarships_created == 1
        assert result2.scholarships_created == 0
        assert result2.scholarships_updated == 1

        # Only one scholarship in DB
        scholarships = db_session.query(Scholarship).all()
        assert len(scholarships) == 1


class TestPipelinePartialFailure:
    """Test: one source succeeds, another fails."""

    def test_partial_failure_preserves_good_source(self, db_session: Session):
        mock_registry = {
            "good": SourceEntry(
                provider_name="Good Provider",
                source_url="https://good.example.com",
                scraper_factory=lambda: FakeScraper([
                    _make_scraped(
                        title="Good Scholarship",
                        provider="Good Provider",
                        application_url="https://good.example.com/apply",
                    )
                ]),
                enabled=True,
            ),
            "bad": SourceEntry(
                provider_name="Bad Provider",
                source_url="https://bad.example.com",
                scraper_factory=FailingScraper,
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            pipeline = CrawlerPipeline(db=db_session, dry_run=False)
            result = pipeline.run()

        assert result.sources_succeeded == 1
        assert result.sources_failed == 1
        assert result.scholarships_created == 1
        assert len(result.errors) == 1

        # Good scholarship is persisted
        scholarships = db_session.query(Scholarship).all()
        assert len(scholarships) == 1
        assert scholarships[0].title == "Good Scholarship"


class TestPipelineDryRun:
    """Test: dry-run mode does not write to DB."""

    def test_dry_run_no_persist(self, db_session: Session):
        mock_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([_make_scraped()]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            pipeline = CrawlerPipeline(db=db_session, dry_run=True)
            result = pipeline.run()

        # Pipeline reports what would happen
        assert result.scholarships_created == 1

        # But DB is empty (dry run rolled back)
        scholarships = db_session.query(Scholarship).all()
        assert len(scholarships) == 0


class TestPipelineUpdate:
    """Test: scholarship data changes → update reflects."""

    def test_update_changes_title(self, db_session: Session):
        # First run
        original = _make_scraped(title="Original Title")
        mock_registry_v1 = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([original]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry_v1):
            pipeline = CrawlerPipeline(db=db_session, dry_run=False)
            pipeline.run()

        # Second run with updated title
        updated = _make_scraped(title="Updated Title")
        mock_registry_v2 = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([updated]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry_v2):
            pipeline2 = CrawlerPipeline(db=db_session, dry_run=False)
            result = pipeline2.run()

        assert result.scholarships_updated == 1

        scholarship = db_session.query(Scholarship).first()
        assert scholarship.title == "Updated Title"


class TestResultSummary:
    """Test the human-readable summary output."""

    def test_summary_format(self, db_session: Session):
        mock_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([_make_scraped()]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            pipeline = CrawlerPipeline(db=db_session, dry_run=False)
            result = pipeline.run()

        summary = result.summary()
        assert "RadarScholar Crawler" in summary
        assert "Sources attempted" in summary
        assert "Created" in summary
