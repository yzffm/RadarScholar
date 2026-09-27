from pathlib import Path

from app.crawler.scrapers.bca import BcaScholarshipScraper
from app.crawler.scrapers.ugm_bulletin import UgmScholarshipBulletinScraper

FIXTURES = Path(__file__).parent / "fixtures"


def test_bca_extracts_program_deadline_requirements_and_benefits():
    result = BcaScholarshipScraper().parse_html(
        (FIXTURES / "bca.html").read_text(encoding="utf-8")
    )[0]

    assert result.title == "Beasiswa BCA PPBP/PPTI"
    assert result.deadline is not None
    assert result.deadline.year == 2026
    assert result.deadline.month == 10
    assert result.deadline.day == 20
    assert {item.requirement_type for item in result.requirements} >= {
        "NATIONALITY",
        "EDUCATION_LEVEL",
        "AGE",
    }
    assert {item.benefit_type for item in result.benefits} >= {
        "TUITION_FEE",
        "LIVING_ALLOWANCE",
    }


def test_ugm_bulletin_extracts_official_program_data():
    result = UgmScholarshipBulletinScraper().parse_html(
        (FIXTURES / "ugm_baznas.html").read_text(encoding="utf-8")
    )[0]

    assert result.title.startswith("Beasiswa Cendekia BAZNAS")
    assert result.deadline is None  # audited 2026 period is expired
    assert result.is_active is False
    assert result.application_url == "https://beasiswa.baznas.go.id"
    assert {item.requirement_type for item in result.requirements} >= {
        "DEGREE_LEVEL",
        "SEMESTER",
        "GPA",
    }
