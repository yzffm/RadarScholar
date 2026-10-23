import re
from datetime import datetime
from pathlib import Path

import pytest

from app.crawler.scrapers.cimb import CimbScholarshipScraper
from app.crawler.scrapers.pertamina import PertaminaSobatBumiScraper
from app.scholarships.status import RegistrationStatus, derive_registration_status

FIXTURES = Path(__file__).parent / "fixtures"
FIXED_REF = datetime(2026, 10, 20, 3, 0, 0)


def test_pertamina_fixture_has_real_snapshot_metadata():
    first_line = (FIXTURES / "pertamina.html").read_text(encoding="utf-8").splitlines()[0]
    assert "Real HTML snapshot fetched from https://www.pertaminafoundation.org/" in first_line
    assert "2026-10-23" in first_line


@pytest.mark.parametrize(
    ("scraper", "fixture", "title"),
    [
        (PertaminaSobatBumiScraper(), "pertamina.html", "Beasiswa Sobat Bumi"),
        (CimbScholarshipScraper(), "cimb.html", "CIMB Niaga Scholarship Program"),
    ],
)
def test_additional_official_scrapers_parse_fixture(scraper, fixture, title):
    result = scraper.parse_html(
        (FIXTURES / fixture).read_text(encoding="utf-8"),
        reference_time=FIXED_REF,
    )[0]

    assert result.title == title
    assert result.is_live_verified is True
    assert result.benefits


def test_pertamina_extracts_contextual_deadline_and_unknown_when_deadline_removed():
    html = (FIXTURES / "pertamina.html").read_text(encoding="utf-8")
    result = PertaminaSobatBumiScraper().parse_html(
        html,
        reference_time=FIXED_REF,
    )[0]

    # The audited 2026 period is expired at FIXED_REF; do not expose it as live.
    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is True

    # When deadline sentences are absent on the real Pertamina page, status is UNKNOWN (never OPEN).
    html_without_dates = re.sub(
        r"\b\d{1,2}\s+(?:Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember)\s+\d{4}\b",
        "",
        html,
        flags=re.IGNORECASE,
    )
    no_date_result = PertaminaSobatBumiScraper().parse_html(
        html_without_dates,
        reference_time=FIXED_REF,
    )[0]
    assert no_date_result.deadline is None
    assert no_date_result.is_active is False
    assert no_date_result.has_contextual_dates is False
    assert (
        derive_registration_status(no_date_result.deadline, no_date_result.is_active)
        == RegistrationStatus.UNKNOWN
    )


def test_cimb_does_not_invent_missing_deadline():
    result = CimbScholarshipScraper().parse_html(
        (FIXTURES / "cimb.html").read_text(encoding="utf-8"),
        reference_time=FIXED_REF,
    )[0]

    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is False
    assert (
        derive_registration_status(result.deadline, result.is_active)
        == RegistrationStatus.UNKNOWN
    )
