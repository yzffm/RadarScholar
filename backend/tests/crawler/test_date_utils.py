from datetime import datetime

from app.crawler.date_utils import (
    JAKARTA_TZ,
    extract_contextual_dates,
    extract_contextual_deadline,
)

FIXED_REF = datetime(2026, 10, 20, 3, 0, 0)


def test_date_without_deadline_context_is_not_guessed():
    assert (
        extract_contextual_deadline(
            "Program dimulai 31 Desember 2028",
            reference_time=FIXED_REF,
        )
        is None
    )


def test_deadline_context_is_selected_over_later_program_date():
    result = extract_contextual_deadline(
        "Pendaftaran sampai 30 September 2027. Program dimulai 31 Desember 2028.",
        reference_time=FIXED_REF,
    )
    assert result == datetime(2027, 9, 30, 16, 59, 59)


def test_pendaftaran_online_sd_abbreviation_is_extracted():
    text = "Pendaftaran online: s.d. 27 September 2026"
    dates = extract_contextual_dates(text)
    assert dates == [datetime(2026, 9, 27, 16, 59, 59)]

    active_result = extract_contextual_deadline(
        text,
        reference_time=datetime(2026, 9, 27, 3, 0, 0),
    )
    assert active_result == datetime(2026, 9, 27, 16, 59, 59)

    expired_result = extract_contextual_deadline(
        text,
        reference_time=FIXED_REF,
    )
    assert expired_result is None


def test_abbreviations_do_not_truncate_deadline_sentence():
    text = (
        "Berdasarkan Surat Edaran No. 14/2026 dari Prof. Dr. Hendra di "
        "PT. Bank Central Asia Tbk. pendaftaran dibuka s.d. 20 Oktober 2026."
    )
    result = extract_contextual_deadline(
        text,
        reference_time=datetime(2026, 10, 20, 3, 0, 0),
    )
    assert result == datetime(2026, 10, 20, 16, 59, 59)


def test_deadline_same_day_active_until_end_of_day_jakarta():
    text = "Batas pendaftaran 20 Oktober 2026."
    # 2026-10-20 23:59:59 WIB == 2026-10-20 16:59:59 UTC (still active)
    assert extract_contextual_deadline(
        text,
        reference_time=datetime(2026, 10, 20, 16, 59, 59),
    ) == datetime(2026, 10, 20, 16, 59, 59)

    # Aware Asia/Jakarta timestamp at 23:59:59 WIB
    assert extract_contextual_deadline(
        text,
        reference_time=datetime(2026, 10, 20, 23, 59, 59, tzinfo=JAKARTA_TZ),
    ) == datetime(2026, 10, 20, 16, 59, 59)

    # 2026-10-21 00:00:00 WIB == 2026-10-20 17:00:00 UTC (expired)
    assert (
        extract_contextual_deadline(
            text,
            reference_time=datetime(2026, 10, 20, 17, 0, 0),
        )
        is None
    )
