"""Tests for the LPDP scraper.

Uses the local HTML fixture — does NOT depend on live internet.
"""

from pathlib import Path

import httpx
import pytest

from app.crawler.scrapers.lpdp import LpdpScraper

FIXTURE_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def lpdp_html() -> str:
    """Load the LPDP HTML fixture."""
    return (FIXTURE_DIR / "lpdp.html").read_text(encoding="utf-8")


@pytest.fixture
def scraper() -> LpdpScraper:
    return LpdpScraper()


class TestLpdpParser:
    """Test LpdpScraper.parse_html using the local fixture."""

    def test_returns_one_scholarship(self, scraper: LpdpScraper, lpdp_html: str):
        results = scraper.parse_html(lpdp_html)
        assert len(results) == 1

    def test_title(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert result.title == "Beasiswa LPDP"

    def test_provider_name(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert result.provider_name == "LPDP"

    def test_source_url(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert "lpdp.kemenkeu.go.id" in result.source_url

    def test_application_url(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert "beasiswalpdp-terintegrasi.kemenkeu.go.id" in result.application_url

    def test_description_from_meta(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert "lpdp" in result.description.lower() or "kementerian keuangan" in result.description.lower()

    def test_has_requirements(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert len(result.requirements) >= 2

    def test_gpa_requirement(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        gpa_reqs = [r for r in result.requirements if r.requirement_type == "GPA"]
        assert len(gpa_reqs) == 1
        assert gpa_reqs[0].operator == "GTE"
        assert gpa_reqs[0].value == {"gpa": 3.0}

    def test_degree_requirement(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        deg_reqs = [r for r in result.requirements if r.requirement_type == "DEGREE_LEVEL"]
        assert len(deg_reqs) == 1
        assert "S2" in deg_reqs[0].value["levels"]
        assert "S3" in deg_reqs[0].value["levels"]

    def test_has_benefits(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert len(result.benefits) >= 3

    def test_tuition_benefit(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        tuition = [b for b in result.benefits if b.benefit_type == "TUITION_FEE"]
        assert len(tuition) == 1

    def test_living_allowance_benefit(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        living = [b for b in result.benefits if b.benefit_type == "LIVING_ALLOWANCE"]
        assert len(living) == 1

    def test_deadline_extracted(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert result.deadline is not None
        assert result.deadline.year == 2027
        assert result.deadline.month == 10

    def test_is_active(self, scraper: LpdpScraper, lpdp_html: str):
        result = scraper.parse_html(lpdp_html)[0]
        assert result.is_active is True


class TestLpdpScrapeFallback:
    """scrape() must degrade gracefully to known baseline data instead of
    crashing the whole pipeline when the live page can't be reached
    (LPDP's site actively blocks automated requests)."""

    def test_scrape_falls_back_when_fetch_fails(self, scraper: LpdpScraper, monkeypatch):
        def _raise(*args, **kwargs):
            raise httpx.HTTPError("simulated network failure")

        monkeypatch.setattr(scraper, "fetch", _raise)
        results = scraper.scrape()

        assert len(results) == 1
        assert results[0].title == "Beasiswa LPDP"
        assert len(results[0].requirements) >= 1
        assert results[0].deadline is None