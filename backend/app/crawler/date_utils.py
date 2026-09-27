"""Helpers for extracting source-backed dates from crawler text."""

import re
from datetime import datetime

from app.core.time import utc_now

_DATE_PATTERN = re.compile(
    r"(\d{1,2})\s+(Januari|Februari|Maret|April|Mei|Juni|"
    r"Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})",
    re.IGNORECASE,
)
_MONTHS = {
    "januari": 1, "februari": 2, "maret": 3, "april": 4,
    "mei": 5, "juni": 6, "juli": 7, "agustus": 8,
    "september": 9, "oktober": 10, "november": 11, "desember": 12,
}
_DEADLINE_CONTEXT = re.compile(
    r"deadline|batas\s+(?:akhir\s+)?pendaftaran|"
    r"pendaftaran\s+(?:dibuka\s+)?(?:sampai|hingga|ditutup)|"
    r"(?:sampai|hingga|ditutup)\s+(?:tanggal\s+)?|tanggal\s+terakhir",
    re.IGNORECASE,
)


def extract_contextual_deadline(text: str) -> datetime | None:
    """Return a future date only when nearby text identifies a deadline."""
    now = utc_now()
    candidates: list[datetime] = []
    for match in _DATE_PATTERN.finditer(text):
        segment_start = max(
            text.rfind(".", 0, match.start()),
            text.rfind("!", 0, match.start()),
            text.rfind("?", 0, match.start()),
        )
        segment_end_candidates = [
            position for position in (
                text.find(".", match.end()),
                text.find("!", match.end()),
                text.find("?", match.end()),
            ) if position >= 0
        ]
        segment_end = min(segment_end_candidates) if segment_end_candidates else len(text)
        context = text[segment_start + 1 : segment_end]
        if not _DEADLINE_CONTEXT.search(context):
            continue
        try:
            date = datetime(
                int(match.group(3)),
                _MONTHS[match.group(2).lower()],
                int(match.group(1)),
            )
        except (KeyError, ValueError):
            continue
        if date > now:
            candidates.append(date)
    return max(candidates) if candidates else None
