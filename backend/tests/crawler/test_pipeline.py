"""Integration tests for the crawler pipeline.

Tests the full pipeline with a mocked scraper (no internet).
Uses an in-memory SQLite database for isolation.
"""

from datetime import datetime
from unittest.mock import patch

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.crawler.base import (
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
    SourceUnavailableError,
)
from app.crawler.models import CrawlRun
from app.crawler.pipeline import CrawlerPipeline, _normalize_text, _normalize_url
from app.crawler.registry import SourceEntry, get_registry
from app.database.base import Base
from app.scholarships.models import (
    Scholarship,
    ScholarshipBenefit,
    ScholarshipRequirement,
    ScholarshipSource,
)

# ---------------------------------------------------------------------------
# Test fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def db_session():
    """Create an in-memory SQLite database session for testing."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session_factory = sessionmaker(bind=engine)
    session = session_factory()
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
        is_live_verified=True,
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


class EmptyScraper:
    """A scraper that succeeds but returns no records."""

    def scrape(self):
        return []


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

    def test_normalize_url_lowercases_authority_and_preserves_query(self):
        url = _normalize_url(" HTTPS://Example.COM/Path/?year=2027#details ")
        assert url == "https://example.com/Path?year=2027#details"


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
        assert scholarships[0].data_origin == "CRAWLER_LIVE"

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

    def test_baseline_fallback_is_not_marked_live_verified(self, db_session: Session):
        baseline = _make_scraped()
        baseline.is_live_verified = False
        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([baseline]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.data_origin == "CRAWLER_BASELINE"
        assert scholarship.last_verified_live_at is None

    def test_baseline_does_not_erase_previous_live_verification(self, db_session: Session):
        live = _make_scraped()
        live.is_live_verified = True
        baseline = _make_scraped(title="Baseline Refresh")
        baseline.is_live_verified = False
        live_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([live]),
                enabled=True,
            ),
        }
        baseline_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([baseline]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=live_registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        live_verified_at = scholarship.last_verified_live_at
        assert scholarship.data_origin == "CRAWLER_LIVE"
        assert live_verified_at is not None

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=baseline_registry):
            CrawlerPipeline(db_session).run()

        db_session.refresh(scholarship)
        assert scholarship.title == "Baseline Refresh"
        assert scholarship.data_origin == "CRAWLER_LIVE"
        assert scholarship.last_verified_live_at == live_verified_at

    def test_live_refresh_promotes_baseline_and_sets_verification(self, db_session: Session):
        baseline = _make_scraped()
        baseline.is_live_verified = False
        live = _make_scraped(title="Live Refresh")
        live.is_live_verified = True
        baseline_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([baseline]),
                enabled=True,
            ),
        }
        live_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([live]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=baseline_registry):
            CrawlerPipeline(db_session).run()
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=live_registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.title == "Live Refresh"
        assert scholarship.data_origin == "CRAWLER_LIVE"
        assert scholarship.last_verified_live_at is not None


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
        assert scholarship.data_origin == "CRAWLER_LIVE"


class TestSourcePolicy:
    def test_disabled_source_is_not_scraped(self, db_session: Session):
        source = ScholarshipSource(
            provider_name="Test Provider",
            source_url="https://example.com/scholarship",
            active=False,
            crawl_allowed=False,
        )
        db_session.add(source)
        db_session.commit()

        mock_registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([_make_scraped()]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_registry):
            with patch.object(FakeScraper, "scrape") as scrape:
                result = CrawlerPipeline(db_session).run()

        assert result.sources_succeeded == 1
        assert result.sources_failed == 0
        assert result.source_results[0].skipped_by_policy is True
        assert scrape.call_count == 0
        assert db_session.query(Scholarship).count() == 0


class TestStaleHandling:
    def test_successful_crawl_marks_missing_scholarship_inactive(
        self, db_session: Session
    ):
        old_item = _make_scraped(
            title="Old Scholarship",
            application_url="https://example.com/old",
        )
        current_item = _make_scraped(
            title="Current Scholarship",
            application_url="https://example.com/current",
        )
        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([old_item]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = lambda: FakeScraper([current_item])
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            result = CrawlerPipeline(db_session).run()

        scholarships = (
            db_session.query(Scholarship)
            .order_by(Scholarship.title)
            .all()
        )
        assert result.sources_succeeded == 1
        assert len(scholarships) == 2
        assert scholarships[0].title == "Current Scholarship"
        assert scholarships[0].is_active is True
        assert scholarships[1].title == "Old Scholarship"
        assert scholarships[1].is_active is False

    def test_empty_crawl_preserves_existing_scholarship(self, db_session: Session):
        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([_make_scraped()]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = EmptyScraper
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            result = CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert result.sources_succeeded == 1
        assert scholarship.is_active is True

    def test_partial_parse_preserves_existing_scholarship(self, db_session: Session):
        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([_make_scraped()]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = lambda: FakeScraper(
            [_make_scraped(), None]
        )
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.is_active is True


class TestFailClosedActiveStatus:
    """Verify A3 fail-closed active status rules in the crawler pipeline."""

    def test_new_record_without_dates_is_inactive(self, db_session: Session):
        dateless = _make_scraped()
        dateless.deadline = None
        dateless.is_active = False
        dateless.has_contextual_dates = False
        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([dateless]),
                enabled=True,
            ),
        }

        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.deadline is None
        assert scholarship.is_active is False

    def test_existing_active_record_without_dates_preserves_active_status(
        self, db_session: Session
    ):
        active_item = _make_scraped(deadline=datetime(2026, 10, 20, 16, 59, 59))
        active_item.is_active = True
        active_item.has_contextual_dates = True

        dateless_refresh = _make_scraped(deadline=None)
        dateless_refresh.is_active = False
        dateless_refresh.has_contextual_dates = False

        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([active_item]),
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = lambda: FakeScraper([dateless_refresh])
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.is_active is True

    def test_existing_inactive_record_without_dates_preserves_inactive_status(
        self, db_session: Session
    ):
        inactive_item = _make_scraped(deadline=None)
        inactive_item.is_active = False
        inactive_item.has_contextual_dates = True

        dateless_refresh = _make_scraped(deadline=None)
        dateless_refresh.is_active = False
        dateless_refresh.has_contextual_dates = False

        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([inactive_item]),
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = lambda: FakeScraper([dateless_refresh])
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.is_active is False

    def test_existing_active_record_with_expired_dates_becomes_inactive(
        self, db_session: Session
    ):
        active_item = _make_scraped(deadline=datetime(2026, 10, 20, 16, 59, 59))
        active_item.is_active = True
        active_item.has_contextual_dates = True

        expired_refresh = _make_scraped(deadline=None)
        expired_refresh.is_active = False
        expired_refresh.has_contextual_dates = True

        registry = {
            "test": SourceEntry(
                provider_name="Test Provider",
                source_url="https://example.com/scholarship",
                scraper_factory=lambda: FakeScraper([active_item]),
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        registry["test"].scraper_factory = lambda: FakeScraper([expired_refresh])
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=registry):
            CrawlerPipeline(db_session).run()

        scholarship = db_session.query(Scholarship).one()
        assert scholarship.is_active is False


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
        assert "Sources unavailable" in summary
        assert "Created" in summary


class UnavailableScraper:
    """A scraper that raises SourceUnavailableError."""

    provider_name = "Unavailable Provider"
    source_url = "https://unavailable.example.com/scholarship"

    def scrape(self):
        raise SourceUnavailableError(
            "HTTP 403 — source is blocking access",
            url=self.source_url,
        )


class TestSourceUnavailableHandling:
    """Verify B2 and B6: SourceUnavailableError handling and registry sync."""

    def test_unavailable_source_preserves_old_data_and_is_not_counted_failed(
        self, db_session: Session
    ):
        # First crawl succeeds and stores a scholarship
        initial_registry = {
            "unavail_src": SourceEntry(
                provider_name="Unavailable Provider",
                source_url="https://unavailable.example.com/scholarship",
                scraper_factory=lambda: FakeScraper(
                    [
                        _make_scraped(
                            title="Existing Scholarship",
                            provider="Unavailable Provider",
                            source_url="https://unavailable.example.com/scholarship",
                            application_url="https://unavailable.example.com/apply",
                        )
                    ]
                ),
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=initial_registry):
            CrawlerPipeline(db=db_session).run()

        # Second crawl has 1 good source and 1 unavailable source
        second_registry = {
            "good_src": SourceEntry(
                provider_name="Good Provider",
                source_url="https://good.example.com/scholarship",
                scraper_factory=lambda: FakeScraper(
                    [
                        _make_scraped(
                            title="Good Scholarship",
                            provider="Good Provider",
                            source_url="https://good.example.com/scholarship",
                            application_url="https://good.example.com/apply",
                        )
                    ]
                ),
                enabled=True,
            ),
            "unavail_src": SourceEntry(
                provider_name="Unavailable Provider",
                source_url="https://unavailable.example.com/scholarship",
                scraper_factory=UnavailableScraper,
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=second_registry):
            result = CrawlerPipeline(db=db_session).run()

        assert result.sources_attempted == 2
        assert result.sources_succeeded == 1
        assert result.sources_unavailable == 1
        assert result.sources_failed == 0
        assert result.errors == []

        unavail_res = next(
            sr for sr in result.source_results if sr.source_key == "unavail_src"
        )
        assert unavail_res.unavailable is True
        assert unavail_res.success is False

        # Old data from unavail_src is preserved alongside good_src
        titles = {s.title for s in db_session.query(Scholarship).all()}
        assert titles == {"Existing Scholarship", "Good Scholarship"}

        # CrawlRun JSON stores unavailable=True and status=SUCCESS
        latest_run = (
            db_session.query(CrawlRun).order_by(CrawlRun.started_at.desc()).first()
        )
        assert latest_run is not None
        assert latest_run.status == "SUCCESS"
        unavail_json = next(
            sr for sr in latest_run.source_results if sr["source_key"] == "unavail_src"
        )
        assert unavail_json["unavailable"] is True

    def test_registry_is_synced_to_scholarship_sources_at_run_start(
        self, db_session: Session
    ):
        with patch("app.crawler.pipeline.get_enabled_sources", return_value={}):
            CrawlerPipeline(db=db_session, dry_run=False).run()

        persisted_urls = {
            row.source_url for row in db_session.query(ScholarshipSource).all()
        }
        expected_urls = {
            _normalize_url(entry.source_url) for entry in get_registry().values()
        }
        assert expected_urls <= persisted_urls
