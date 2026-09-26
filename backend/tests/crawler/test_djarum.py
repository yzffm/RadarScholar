"""Tests for the Djarum Beasiswa Plus scraper.

Uses the local HTML fixture — does NOT depend on live internet.
"""

from pathlib import Path

import httpx
import pytest

from app.crawler.scrapers.djarum import DjarumScraper

FIXTURE_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def djarum_html() -> str:
    """Load the Djarum HTML fixture."""
    return (FIXTURE_DIR / "djarum.html").read_text(encoding="utf-8")


@pytest.fixture
def scraper() -> DjarumScraper:
    return DjarumScraper()


class TestDjarumParser:
    """Test DjarumScraper.parse_html using the local fixture."""

    def test_returns_one_scholarship(self, scraper: DjarumScraper, djarum_html: str):
        results = scraper.parse_html(djarum_html)
        assert len(results) == 1

    def test_title(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert result.title == "Djarum Beasiswa Plus"

    def test_provider_name(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert result.provider_name == "Djarum Beasiswa Plus"

    def test_source_url(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert "djarumbeasiswaplus.org" in result.source_url

    def test_application_url(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert "register.djarumbeasiswaplus.org" in result.application_url

    def test_description_from_meta(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert "beasiswa prestasi" in result.description.lower()

    def test_has_requirements(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert len(result.requirements) >= 3

    def test_gpa_requirement(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        gpa_reqs = [r for r in result.requirements if r.requirement_type == "GPA"]
        assert len(gpa_reqs) == 1
        assert gpa_reqs[0].operator == "GTE"
        assert gpa_reqs[0].value == {"gpa": 3.0}

    def test_semester_requirement(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        sem_reqs = [r for r in result.requirements if r.requirement_type == "SEMESTER"]
        assert len(sem_reqs) == 1
        assert sem_reqs[0].operator == "EQ"
        assert sem_reqs[0].value == {"semester": 4}

    def test_degree_requirement(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        deg_reqs = [r for r in result.requirements if r.requirement_type == "DEGREE_LEVEL"]
        assert len(deg_reqs) == 1
        assert "S1" in deg_reqs[0].value["levels"]
        assert "D4" in deg_reqs[0].value["levels"]

    def test_organization_requirement(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        org_reqs = [r for r in result.requirements if r.requirement_type == "ORGANIZATION"]
        assert len(org_reqs) == 1

    def test_has_benefits(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert len(result.benefits) >= 3

    def test_tuition_benefit(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        tuition = [b for b in result.benefits if b.benefit_type == "TUITION_FEE"]
        assert len(tuition) == 1

    def test_deadline_extracted(self, scraper: DjarumScraper, djarum_html: str):
        """The fixture contains '30 September 2027' so a deadline should be found."""
        result = scraper.parse_html(djarum_html)[0]
        assert result.deadline is not None
        assert result.deadline.year == 2027
        assert result.deadline.month == 9

    def test_is_active(self, scraper: DjarumScraper, djarum_html: str):
        result = scraper.parse_html(djarum_html)[0]
        assert result.is_active is True


class TestDjarumParserEdgeCases:
    """Edge case tests for robustness."""

    def test_empty_html(self, scraper: DjarumScraper):
        """Even with empty HTML, known data should be returned."""
        results = scraper.parse_html("<html><head></head><body></body></html>")
        assert len(results) == 1
        assert results[0].title == "Djarum Beasiswa Plus"
        assert len(results[0].requirements) >= 3

    def test_no_deadline_in_html(self, scraper: DjarumScraper):
        """If no date is in the HTML, deadline should be None."""
        results = scraper.parse_html("<html><head></head><body><p>No dates here</p></body></html>")
        assert results[0].deadline is None


class TestDjarumScrapeFallback:
    """scrape() must degrade gracefully to known baseline data instead of
    crashing the whole pipeline when the live page can't be reached
    (this source is known to block automated requests)."""

    def test_scrape_falls_back_when_fetch_fails(self, scraper: DjarumScraper, monkeypatch):
        def _raise(*args, **kwargs):
            raise httpx.HTTPError("simulated network failure")

        monkeypatch.setattr(scraper, "fetch", _raise)
        results = scraper.scrape()

        assert len(results) == 1
        assert results[0].title == "Djarum Beasiswa Plus"
        assert len(results[0].requirements) >= 3
        assert results[0].deadline is None