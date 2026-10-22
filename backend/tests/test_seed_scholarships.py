from datetime import datetime
from pathlib import Path
from unittest.mock import patch

from scripts.seed_scholarships import seed_scholarships
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.crawler.pipeline import CrawlerPipeline
from app.crawler.registry import SourceEntry, get_registry
from app.crawler.scrapers.bca import BcaScholarshipScraper
from app.database.base import Base
from app.scholarships.models import Scholarship, ScholarshipSource


def test_seed_is_idempotent_and_marks_provenance():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()

    try:
        assert seed_scholarships(session) == 2
        assert seed_scholarships(session) == 2

        assert session.query(ScholarshipSource).count() == 2
        assert session.query(Scholarship).count() == 2
        for scholarship in session.query(Scholarship).all():
            assert scholarship.data_origin == "SEED"
            assert scholarship.last_verified_live_at is None
            assert scholarship.deadline is None
            assert len(scholarship.requirements) > 0
            assert len(scholarship.benefits) > 0
    finally:
        session.close()
        engine.dispose()


def test_seed_and_crawler_do_not_duplicate_sources_or_scholarships():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()
    fixtures = Path(__file__).parent / "crawler" / "fixtures"
    bca_html = (fixtures / "bca.html").read_text(encoding="utf-8")

    try:
        seed_scholarships(session)
        assert session.query(Scholarship).count() == 2

        class OfflineBcaScraper(BcaScholarshipScraper):
            def scrape(self):
                return self.parse_html(
                    bca_html,
                    reference_time=datetime(2026, 10, 20, 3, 0, 0),
                )

        bca_entry = get_registry()["bca_scholarship"]
        mock_enabled = {
            "bca_scholarship": SourceEntry(
                provider_name=bca_entry.provider_name,
                source_url=bca_entry.source_url,
                scraper_factory=OfflineBcaScraper,
                enabled=True,
            ),
        }
        with patch("app.crawler.pipeline.get_enabled_sources", return_value=mock_enabled):
            result = CrawlerPipeline(db=session, dry_run=False).run()

        assert result.scholarships_created == 0
        assert result.scholarships_updated == 1
        assert session.query(Scholarship).count() == 2
        bca_rows = (
            session.query(Scholarship)
            .filter(Scholarship.title == "Beasiswa BCA PPBP/PPTI")
            .all()
        )
        assert len(bca_rows) == 1
        assert bca_rows[0].data_origin == "CRAWLER_LIVE"
    finally:
        session.close()
        engine.dispose()


def test_provenance_migration_contract():
    migration = (
        Path(__file__).parents[1]
        / "alembic"
        / "versions"
        / "a8b7c6d5e4f3_add_scholarship_data_origin.py"
    )
    source = migration.read_text(encoding="utf-8")

    assert '"data_origin"' in source
    assert 'server_default="CRAWLER"' in source
    assert 'op.drop_column("scholarships", "data_origin")' in source
