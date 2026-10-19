from datetime import datetime
from pathlib import Path

from app.crawler.scrapers.bca import BcaScholarshipScraper
from app.crawler.scrapers.ugm_bulletin import UgmScholarshipBulletinScraper

FIXTURES = Path(__file__).parent / "fixtures"


def test_bca_extracts_program_deadline_requirements_and_benefits_on_deadline_day():
    result = BcaScholarshipScraper().parse_html(
        (FIXTURES / "bca.html").read_text(encoding="utf-8"),
        reference_time=datetime(2026, 10, 20, 3, 0),
    )[0]

    assert result.title == "Beasiswa BCA PPBP/PPTI"
    assert result.deadline == datetime(2026, 10, 20, 16, 59, 59)
    assert result.is_active is True
    assert result.has_contextual_dates is True
    assert {item.requirement_type for item in result.requirements} >= {
        "NATIONALITY",
        "EDUCATION_LEVEL",
        "AGE",
    }
    assert {item.benefit_type for item in result.benefits} >= {
        "TUITION_FEE",
        "LIVING_ALLOWANCE",
    }


def test_bca_marks_expired_day_after_deadline():
    result = BcaScholarshipScraper().parse_html(
        (FIXTURES / "bca.html").read_text(encoding="utf-8"),
        reference_time=datetime(2026, 10, 21, 3, 0),
    )[0]

    assert result.title == "Beasiswa BCA PPBP/PPTI"
    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is True


def test_ugm_bulletin_extracts_official_program_data():
    html = (FIXTURES / "ugm_baznas.html").read_text(encoding="utf-8")
    result = UgmScholarshipBulletinScraper().parse_html(
        html,
        reference_time=datetime(2026, 10, 20, 3, 0),
    )[0]

    assert result.title.startswith("Beasiswa Cendekia BAZNAS")
    assert result.deadline is None  # audited 2026 period is expired at 2026-10-20
    assert result.is_active is False
    assert result.has_contextual_dates is True
    assert result.application_url == "https://beasiswa.baznas.go.id"
    assert {item.requirement_type for item in result.requirements} >= {
        "DEGREE_LEVEL",
        "SEMESTER",
        "GPA",
    }

    active_result = UgmScholarshipBulletinScraper().parse_html(
        html,
        reference_time=datetime(2026, 9, 27, 3, 0),
    )[0]
    assert active_result.deadline == datetime(2026, 9, 27, 16, 59, 59)
    assert active_result.is_active is True
