import re
from datetime import datetime
from pathlib import Path

from app.crawler.scrapers.bca import BcaScholarshipScraper
from app.crawler.scrapers.ugm_bulletin import UgmScholarshipBulletinScraper
from app.scholarships.status import RegistrationStatus, derive_registration_status

FIXTURES = Path(__file__).parent / "fixtures"


def test_bca_and_ugm_fixtures_have_real_snapshot_metadata():
    bca_first = (FIXTURES / "bca.html").read_text(encoding="utf-8").splitlines()[0]
    ugm_first = (FIXTURES / "ugm_baznas.html").read_text(encoding="utf-8").splitlines()[0]

    assert "Real HTML snapshot fetched from https://karir.bca.co.id/beasiswa-bca" in bca_first
    assert "2026-10-23" in bca_first
    assert "Real HTML snapshot fetched from https://ditmawa.ugm.ac.id/2026/09/" in ugm_first
    assert "2026-10-23" in ugm_first


def test_bca_real_snapshot_without_deadline_sentence_yields_unknown_status():
    """On the real karir.bca.co.id snapshot (fetched 2026-10-23), no deadline date
    is present on the page, so the parser returns deadline=None, is_active=False,
    and registration status is UNKNOWN (never OPEN/active).
    """
    html = (FIXTURES / "bca.html").read_text(encoding="utf-8")
    result = BcaScholarshipScraper().parse_html(
        html,
        reference_time=datetime(2026, 10, 20, 3, 0),
    )[0]

    assert result.title == "Beasiswa BCA PPBP/PPTI"
    assert result.deadline is None
    assert result.is_active is False
    assert result.has_contextual_dates is False
    assert (
        derive_registration_status(result.deadline, result.is_active)
        == RegistrationStatus.UNKNOWN
    )
    assert {item.requirement_type for item in result.requirements} >= {
        "NATIONALITY",
        "EDUCATION_LEVEL",
        "AGE",
    }
    assert {item.benefit_type for item in result.benefits} >= {
        "TUITION_FEE",
        "LIVING_ALLOWANCE",
    }


def test_bca_extracts_program_deadline_on_deadline_day_and_expires_day_after():
    base_html = (FIXTURES / "bca.html").read_text(encoding="utf-8")
    html_with_deadline = base_html.replace(
        "</body>",
        "<p>Pendaftaran Beasiswa BCA dibuka sampai 20 Oktober 2026.</p></body>",
    )

    on_deadline_day = BcaScholarshipScraper().parse_html(
        html_with_deadline,
        reference_time=datetime(2026, 10, 20, 3, 0),
    )[0]
    assert on_deadline_day.title == "Beasiswa BCA PPBP/PPTI"
    assert on_deadline_day.deadline == datetime(2026, 10, 20, 16, 59, 59)
    assert on_deadline_day.is_active is True
    assert on_deadline_day.has_contextual_dates is True
    assert (
        derive_registration_status(
            on_deadline_day.deadline,
            on_deadline_day.is_active,
            now=datetime(2026, 10, 20, 3, 0),
        )
        == RegistrationStatus.OPEN
    )

    day_after = BcaScholarshipScraper().parse_html(
        html_with_deadline,
        reference_time=datetime(2026, 10, 21, 3, 0),
    )[0]
    assert day_after.title == "Beasiswa BCA PPBP/PPTI"
    assert day_after.deadline is None
    assert day_after.is_active is False
    assert day_after.has_contextual_dates is True
    assert (
        derive_registration_status(day_after.deadline, day_after.is_active)
        == RegistrationStatus.UNKNOWN
    )


def test_ugm_bulletin_extracts_official_program_data_and_unknown_when_deadline_removed():
    html = (FIXTURES / "ugm_baznas.html").read_text(encoding="utf-8")
    result = UgmScholarshipBulletinScraper().parse_html(
        html,
        reference_time=datetime(2026, 10, 20, 3, 0),
    )[0]

    assert result.title.startswith("Beasiswa Cendekia BAZNAS")
    assert result.deadline == datetime(2026, 9, 27, 16, 59, 59)
    assert result.is_active is False
    assert result.has_contextual_dates is True
    assert (
        derive_registration_status(
            result.deadline,
            result.is_active,
            now=datetime(2026, 10, 20, 3, 0),
        )
        == RegistrationStatus.CLOSED
    )
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
    assert (
        derive_registration_status(
            active_result.deadline,
            active_result.is_active,
            now=datetime(2026, 9, 27, 3, 0),
        )
        == RegistrationStatus.OPEN
    )

    # When deadline sentences are absent on the real UGM page, status is UNKNOWN (not active).
    html_without_dates = re.sub(
        r"\b\d{1,2}\s+(?:Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember)\s+\d{4}\b",
        "",
        html,
        flags=re.IGNORECASE,
    )
    no_date_result = UgmScholarshipBulletinScraper().parse_html(
        html_without_dates,
        reference_time=datetime(2026, 9, 20, 3, 0),
    )[0]
    assert no_date_result.deadline is None
    assert no_date_result.is_active is False
    assert no_date_result.has_contextual_dates is False
    assert (
        derive_registration_status(no_date_result.deadline, no_date_result.is_active)
        == RegistrationStatus.UNKNOWN
    )
