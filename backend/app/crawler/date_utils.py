"""Helpers for extracting source-backed dates from crawler text.

Timezone & Database Convention
------------------------------
All ``datetime`` columns in the RadarScholar database use **naive UTC**
(see ``app.core.time.utc_now``).

Indonesian scholarship deadlines are published as calendar dates in Western
Indonesian Time (``Asia/Jakarta``, ``UTC+07:00``). A deadline stated as a
calendar date ``YYYY-MM-DD`` remains open through ``23:59:59`` in
``Asia/Jakarta`` on that day. Converted to naive UTC, ``YYYY-MM-DD
23:59:59+07:00`` is ``YYYY-MM-DD 16:59:59`` UTC (same calendar year, month,
and day).
"""

import re
from datetime import UTC, datetime, timedelta, timezone

from app.core.time import utc_now

JAKARTA_UTC_OFFSET = timedelta(hours=7)
JAKARTA_TZ = timezone(JAKARTA_UTC_OFFSET, name="Asia/Jakarta")

_CONTEXT_WINDOW_BEFORE = 160
_CONTEXT_WINDOW_AFTER = 80

_DATE_PATTERN = re.compile(
    r"(\d{1,2})\s+(Januari|Februari|Maret|April|Mei|Juni|"
    r"Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})",
    re.IGNORECASE,
)
_MONTHS = {
    "januari": 1, "februari": 2, "maret": 3, "april": 4,
    "mei": 5, "juni": 6, "juli": 7, "agustus": 8,
    "september": 9, "oktober": 10, "november": 11, "desember": 12,
    "january": 1, "february": 2, "march": 3,
    "may": 5, "june": 6, "july": 7, "august": 8,
    "october": 10, "december": 12,
}

_ID_RANGE_PATTERN = re.compile(
    r"(?:pendaftaran\b[^\.\n]*?)?"
    r"(?:(?:akan\s+)?dibuka\s+(?:mulai\s+|pada\s+)?(?:bulan\s+|tanggal\s+)?|periode\s+pendaftaran\s*:?\s*)"
    r"(\d{1,2})\s+([A-Za-z]+)(?:\s+(\d{4}))?"
    r"\s*(?:sampai\s+(?:dengan)?|hingga|s\.d\.?|dan\s+ditutup\s+(?:pada\s+)?|[-–—])\s*(?:tanggal\s+)?"
    r"(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})",
    re.IGNORECASE,
)

_EN_RANGE_PATTERN = re.compile(
    r"(?:registration\b[^\.\n]*?)?"
    r"(?:is\s+open\s+from\s+|period\s*:?\s*)"
    r"([A-Za-z]+)\s+(\d{1,2})(?:,\s*(\d{4}))?"
    r"\s+(?:to|until|through|[-–—])\s+"
    r"([A-Za-z]+)\s+(\d{1,2}),\s*(\d{4})",
    re.IGNORECASE,
)
_ABBREVIATION_PATTERN = re.compile(
    r"\b(?:s\.d\.|no\.|dr\.|prof\.|tbk\.|pt\.|cv\.|jl\.|kab\.|kec\.|dll\.|dkk\.|dst\.|a\.n\.|u\.p\.|hlm\.)",
    re.IGNORECASE,
)
_DEADLINE_CONTEXT = re.compile(
    r"deadline|batas\s+(?:akhir\s+)?pendaftaran|"
    r"jadwal\s+pendaftaran|"
    r"pendaftaran\s+periode(?:\s+\d+)?\s*:|"
    r"pendaftaran\s+online\s*:|"
    r"pendaftaran\s+(?:dibuka\s+)?(?:sampai|hingga|ditutup|s\.d\.)|"
    r"(?:sebelum|before)\s+|"
    r"(?:sampai|hingga|ditutup)(?:\s+dengan)?\s+(?:tanggal\s+)?|"
    r"\bs\.d\.?\s+|"
    r"tanggal\s+terakhir",
    re.IGNORECASE,
)


def _mask_abbreviations(text: str) -> str:
    """Replace periods inside common abbreviations while preserving string length."""
    return _ABBREVIATION_PATTERN.sub(
        lambda match: match.group(0).replace(".", " "),
        text,
    )


def _open_date_start_of_day_utc(year: int, month: int, day: int) -> datetime:
    """Return naive UTC datetime for 00:00:00 Asia/Jakarta on the given date."""
    jakarta_sod = datetime(year, month, day, 0, 0, 0, tzinfo=JAKARTA_TZ)
    return jakarta_sod.astimezone(UTC).replace(tzinfo=None)


def _deadline_end_of_day_utc(year: int, month: int, day: int) -> datetime:
    """Return naive UTC datetime for 23:59:59 Asia/Jakarta on the given date."""
    jakarta_eod = datetime(year, month, day, 23, 59, 59, tzinfo=JAKARTA_TZ)
    return jakarta_eod.astimezone(UTC).replace(tzinfo=None)


def _normalize_reference_time(reference_time: datetime | None) -> datetime:
    """Normalize an optional reference timestamp to naive UTC."""
    if reference_time is None:
        return utc_now()
    if reference_time.tzinfo is not None:
        return reference_time.astimezone(UTC).replace(tzinfo=None)
    return reference_time


def extract_contextual_dates(text: str) -> list[datetime]:
    """Return naive-UTC deadlines (23:59:59 Asia/Jakarta) identified by deadline context."""
    dates: list[datetime] = []
    masked = _mask_abbreviations(text)

    for match in _DATE_PATTERN.finditer(text):
        window_start = max(0, match.start() - _CONTEXT_WINDOW_BEFORE)
        window_end = min(len(text), match.end() + _CONTEXT_WINDOW_AFTER)

        boundary_before = max(
            masked.rfind(".", window_start, match.start()),
            masked.rfind("!", window_start, match.start()),
            masked.rfind("?", window_start, match.start()),
            masked.rfind("\n", window_start, match.start()),
            masked.rfind(";", window_start, match.start()),
        )
        segment_start = boundary_before + 1 if boundary_before >= 0 else window_start

        boundary_after_candidates = [
            position
            for position in (
                masked.find(".", match.end(), window_end),
                masked.find("!", match.end(), window_end),
                masked.find("?", match.end(), window_end),
                masked.find("\n", match.end(), window_end),
                masked.find(";", match.end(), window_end),
            )
            if position >= 0
        ]
        segment_end = (
            min(boundary_after_candidates) if boundary_after_candidates else window_end
        )
        context = text[segment_start:segment_end]
        if not _DEADLINE_CONTEXT.search(context):
            continue
        try:
            dates.append(
                _deadline_end_of_day_utc(
                    int(match.group(3)),
                    _MONTHS[match.group(2).lower()],
                    int(match.group(1)),
                )
            )
        except (KeyError, ValueError):
            continue
    return dates


def extract_contextual_deadline(
    text: str,
    reference_time: datetime | None = None,
) -> datetime | None:
    """Return an active deadline (in naive UTC) only when nearby text identifies a deadline.

    A deadline on calendar day D is considered active until 23:59:59 Asia/Jakarta
    (16:59:59 UTC) on day D.
    """
    now_utc = _normalize_reference_time(reference_time)
    candidates = [
        date for date in extract_contextual_dates(text) if date >= now_utc
    ]
    return max(candidates) if candidates else None


def parse_indonesian_date(text: str) -> datetime | None:
    """Parse the first Indonesian calendar date in ``text`` as naive UTC end-of-day."""
    match = _DATE_PATTERN.search(text)
    if not match:
        return None
    try:
        return _deadline_end_of_day_utc(
            int(match.group(3)),
            _MONTHS[match.group(2).lower()],
            int(match.group(1)),
        )
    except (KeyError, ValueError):
        return None



def extract_registration_period(text: str) -> tuple[datetime | None, datetime | None]:
    """Extract (open_date, deadline) in naive UTC when a date range is stated.

    Supports Indonesian ranges (e.g. 'dibuka mulai 1 Juli 2026 sampai dengan 7 September 2026')
    and English ranges (e.g. 'open from July 1 to September 7, 2026').
    """
    m_id = _ID_RANGE_PATTERN.search(text)
    if m_id:
        d1, m1_str, y1, d2, m2_str, y2 = m_id.groups()
        m1 = _MONTHS.get(m1_str.lower())
        m2 = _MONTHS.get(m2_str.lower())
        year2 = int(y2)
        year1 = int(y1) if y1 else year2
        if m1 and m2:
            try:
                start_dt = _open_date_start_of_day_utc(year1, m1, int(d1))
                end_dt = _deadline_end_of_day_utc(year2, m2, int(d2))
                return start_dt, end_dt
            except ValueError:
                pass

    m_en = _EN_RANGE_PATTERN.search(text)
    if m_en:
        m1_str, d1, y1, m2_str, d2, y2 = m_en.groups()
        m1 = _MONTHS.get(m1_str.lower())
        m2 = _MONTHS.get(m2_str.lower())
        year2 = int(y2)
        year1 = int(y1) if y1 else year2
        if m1 and m2:
            try:
                start_dt = _open_date_start_of_day_utc(year1, m1, int(d1))
                end_dt = _deadline_end_of_day_utc(year2, m2, int(d2))
                return start_dt, end_dt
            except ValueError:
                pass

    return None, None
