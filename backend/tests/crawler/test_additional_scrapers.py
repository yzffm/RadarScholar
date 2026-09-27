from pathlib import Path

import pytest

from app.crawler.scrapers.cimb import CimbScholarshipScraper
from app.crawler.scrapers.pertamina import PertaminaSobatBumiScraper

FIXTURES = Path(__file__).parent / "fixtures"


@pytest.mark.parametrize(
    ("scraper", "fixture", "title"),
    [
        (PertaminaSobatBumiScraper(), "pertamina.html", "Beasiswa Sobat Bumi"),
        (CimbScholarshipScraper(), "cimb.html", "CIMB Niaga Scholarship Program"),
    ],
)
def test_additional_official_scrapers_parse_fixture(scraper, fixture, title):
    result = scraper.parse_html((FIXTURES / fixture).read_text(encoding="utf-8"))[0]

    assert result.title == title
    assert result.is_live_verified is True
    assert result.benefits


def test_pertamina_extracts_contextual_deadline():
    result = PertaminaSobatBumiScraper().parse_html(
        (FIXTURES / "pertamina.html").read_text(encoding="utf-8")
    )[0]

    # The audited 2026 period is expired at runtime; do not expose it as live.
    assert result.deadline is None
    assert result.is_active is False


def test_cimb_does_not_invent_missing_deadline():
    result = CimbScholarshipScraper().parse_html(
        (FIXTURES / "cimb.html").read_text(encoding="utf-8")
    )[0]

    assert result.deadline is None
