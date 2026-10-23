from datetime import datetime
from pathlib import Path

import pytest

from app.crawler.scrapers.teladan import TeladanScraper
from app.scholarships.status import RegistrationStatus, derive_registration_status

FIXTURE = Path(__file__).parent / "fixtures" / "teladan_2027.html"
FIXED_REF = datetime(2026, 10, 20, 3, 0, 0)


@pytest.fixture
def scraper() -> TeladanScraper:
    return TeladanScraper()


@pytest.fixture
def html() -> str:
    return FIXTURE.read_text(encoding="utf-8")


def test_teladan_fixture_has_real_snapshot_metadata(html):
    first_line = html.splitlines()[0]
    assert (
        "Real HTML snapshot fetched from https://www.tanotofoundation.org/initiative/teladan/"
        in first_line
    )
    assert "2026-10-23" in first_line


def test_teladan_extracts_official_program_data(scraper, html):
    result = scraper.parse_html(html, reference_time=FIXED_REF)[0]

    assert result.provider_name == "Tanoto Foundation TELADAN"
    assert result.title == "Program Beasiswa Kepemimpinan TELADAN 2027"
    # Real live snapshot has no Indonesian contextual deadline sentence (only English
    # copy), so parser does not invent a deadline and status becomes UNKNOWN (never OPEN).
    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is False
    assert (
        derive_registration_status(result.deadline, result.is_active)
        == RegistrationStatus.UNKNOWN
    )
    assert result.application_url == "https://www.tanotofoundation.org/teladan-2027"
    assert result.is_live_verified is True


def test_teladan_real_page_with_contextual_deadline_sentence(scraper, html):
    html_with_deadline = html.replace(
        "</body>",
        "<p>Pendaftaran Program Beasiswa TELADAN dibuka sampai 25 Oktober 2026.</p></body>",
    )
    active_result = scraper.parse_html(html_with_deadline, reference_time=FIXED_REF)[0]
    assert active_result.deadline == datetime(2026, 10, 25, 16, 59, 59)
    assert active_result.is_active is True
    assert active_result.has_contextual_dates is True
    assert (
        derive_registration_status(
            active_result.deadline,
            active_result.is_active,
            now=FIXED_REF,
        )
        == RegistrationStatus.OPEN
    )

    expired_result = scraper.parse_html(
        html_with_deadline,
        reference_time=datetime(2026, 10, 26, 3, 0, 0),
    )[0]
    assert expired_result.deadline is None
    assert expired_result.is_active is False
    assert expired_result.has_contextual_dates is True
    assert (
        derive_registration_status(
            expired_result.deadline,
            expired_result.is_active,
        )
        == RegistrationStatus.UNKNOWN
    )


def test_teladan_extracts_objective_requirements(scraper, html):
    result = scraper.parse_html(html, reference_time=FIXED_REF)[0]
    requirements = {
        requirement.requirement_type: requirement for requirement in result.requirements
    }

    assert requirements["NATIONALITY"].value == {"country": "Indonesia"}
    assert requirements["DEGREE_LEVEL"].value == {"level": "S1"}
    assert requirements["SEMESTER"].value == {"semester": 1}
    assert len(requirements["UNIVERSITY"].value["universities"]) == 10


def test_teladan_extracts_benefits(scraper, html):
    result = scraper.parse_html(html, reference_time=FIXED_REF)[0]
    benefit_types = {benefit.benefit_type for benefit in result.benefits}

    assert {"TUITION_FEE", "LIVING_ALLOWANCE", "LEADERSHIP_DEVELOPMENT"} <= benefit_types


def test_teladan_rejects_unrelated_page(scraper):
    with pytest.raises(ValueError, match="TELADAN page marker"):
        scraper.parse_html(
            "<html><body>Unrelated content</body></html>",
            reference_time=FIXED_REF,
        )


def test_teladan_scrape_uses_official_page(scraper, html, monkeypatch):
    response = type("Response", (), {"text": html})()

    def fetch(url):
        return response

    monkeypatch.setattr(scraper, "fetch", fetch)
    monkeypatch.setattr(
        "app.crawler.scrapers.teladan.extract_contextual_deadline",
        lambda text, reference_time=None: None,
    )

    result = scraper.scrape()

    assert len(result) == 1
