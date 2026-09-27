from pathlib import Path

import pytest

from app.crawler.scrapers.teladan import TeladanScraper

FIXTURE = Path(__file__).parent / "fixtures" / "teladan_2027.html"


@pytest.fixture
def scraper() -> TeladanScraper:
    return TeladanScraper()


@pytest.fixture
def html() -> str:
    return FIXTURE.read_text(encoding="utf-8")


def test_teladan_extracts_official_program_data(scraper, html):
    result = scraper.parse_html(html)[0]

    assert result.provider_name == "Tanoto Foundation TELADAN"
    assert result.title == "Program Beasiswa Kepemimpinan TELADAN 2027"
    assert result.deadline.year == 2027
    assert result.deadline.month == 9
    assert result.deadline.day == 7
    assert result.application_url == "https://www.tanotofoundation.org/teladan-2027"
    assert result.is_live_verified is True


def test_teladan_extracts_objective_requirements(scraper, html):
    result = scraper.parse_html(html)[0]
    requirements = {requirement.requirement_type: requirement for requirement in result.requirements}

    assert requirements["NATIONALITY"].value == {"country": "Indonesia"}
    assert requirements["DEGREE_LEVEL"].value == {"level": "S1"}
    assert requirements["SEMESTER"].value == {"semester": 1}
    assert len(requirements["UNIVERSITY"].value["universities"]) == 10


def test_teladan_extracts_benefits(scraper, html):
    result = scraper.parse_html(html)[0]
    benefit_types = {benefit.benefit_type for benefit in result.benefits}

    assert {"TUITION_FEE", "LIVING_ALLOWANCE", "LEADERSHIP_DEVELOPMENT"} <= benefit_types


def test_teladan_rejects_unrelated_page(scraper):
    with pytest.raises(ValueError, match="TELADAN page marker"):
        scraper.parse_html("<html><body>Unrelated content</body></html>")


def test_teladan_scrape_uses_official_page(scraper, html, monkeypatch):
    response = type("Response", (), {"text": html})()
    def fetch(url):
        return response

    monkeypatch.setattr(scraper, "fetch", fetch)

    result = scraper.scrape()

    assert len(result) == 1
