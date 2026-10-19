from datetime import datetime
from pathlib import Path

import pytest

from app.crawler.scrapers.teladan import TeladanScraper

FIXTURE = Path(__file__).parent / "fixtures" / "teladan_2027.html"
FIXED_REF = datetime(2026, 10, 20, 3, 0, 0)


@pytest.fixture
def scraper() -> TeladanScraper:
    return TeladanScraper()


@pytest.fixture
def html() -> str:
    return FIXTURE.read_text(encoding="utf-8")


def test_teladan_extracts_official_program_data(scraper, html):
    result = scraper.parse_html(html, reference_time=FIXED_REF)[0]

    assert result.provider_name == "Tanoto Foundation TELADAN"
    assert result.title == "Program Beasiswa Kepemimpinan TELADAN 2027"
    # The audited 2026 period is expired at FIXED_REF, so the parser must not
    # expose it as a current deadline.
    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is True
    assert result.application_url == "https://www.tanotofoundation.org/teladan-2027"
    assert result.is_live_verified is True


def test_teladan_extracts_objective_requirements(scraper, html):
    result = scraper.parse_html(html, reference_time=FIXED_REF)[0]
    requirements = {requirement.requirement_type: requirement for requirement in result.requirements}

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
