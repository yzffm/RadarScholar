"""Tanoto Foundation TELADAN scholarship scraper."""

import logging
from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)
from app.crawler.date_utils import (
    _normalize_reference_time,
    extract_contextual_dates,
    extract_contextual_deadline,
    extract_registration_period,
)

logger = logging.getLogger(__name__)


class TeladanScraper(BaseScraper):
    """Scrape the public, official TELADAN program page."""

    provider_name = "Tanoto Foundation TELADAN"
    source_url = "https://www.tanotofoundation.org/initiative/teladan/"
    application_url = "https://www.tanotofoundation.org/teladan-2027"

    _PARTNER_UNIVERSITIES = (
        "IPB University",
        "Institut Teknologi Bandung",
        "Universitas Brawijaya",
        "Universitas Diponegoro",
        "Universitas Gadjah Mada",
        "Universitas Hasanuddin",
        "Universitas Indonesia",
        "Universitas Mulawarman",
        "Universitas Riau",
        "Universitas Sumatera Utara",
    )

    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch and parse the official TELADAN page."""
        try:
            response = self.fetch(self.application_url)
            return self.parse_html(response.text)
        except Exception as exc:
            logger.warning(
                "Failed to fetch application_url %s (%s); falling back to source_url %s",
                self.application_url,
                exc,
                self.source_url,
            )
            response = self.fetch(self.source_url)
            return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text(" ", strip=True)
        if "TELADAN" not in text.upper():
            raise ValueError("TELADAN page marker was not found")

        open_date, range_deadline = extract_registration_period(text)
        ctx_deadline = extract_contextual_deadline(text, reference_time=reference_time)
        all_candidates = extract_contextual_dates(text)
        if range_deadline and range_deadline not in all_candidates:
            all_candidates.append(range_deadline)

        # Prioritize active contextual deadline, then max candidate date
        if ctx_deadline is not None:
            deadline = ctx_deadline
        elif range_deadline is not None:
            deadline = max([range_deadline] + all_candidates) if all_candidates else range_deadline
        elif all_candidates:
            deadline = max(all_candidates)
        else:
            deadline = None

        now_utc = _normalize_reference_time(reference_time)
        is_active = (
            deadline is not None
            and deadline >= now_utc
            and (open_date is None or open_date <= now_utc)
        )

        requirements = [
            ScrapedRequirement(
                requirement_type="NATIONALITY",
                operator="EQ",
                value={"country": "Indonesia"},
                description="Warga Negara Indonesia (WNI).",
            ),
            ScrapedRequirement(
                requirement_type="DEGREE_LEVEL",
                operator="EQ",
                value={"level": "S1"},
                description="Mahasiswa reguler program S1.",
            ),
            ScrapedRequirement(
                requirement_type="SEMESTER",
                operator="EQ",
                value={"semester": 1},
                description="Mahasiswa semester pertama di perguruan tinggi mitra.",
            ),
            ScrapedRequirement(
                requirement_type="UNIVERSITY",
                operator="IN",
                value={"universities": list(self._PARTNER_UNIVERSITIES)},
                description="Terdaftar di salah satu perguruan tinggi mitra TELADAN.",
            ),
            ScrapedRequirement(
                requirement_type="ORGANIZATION",
                operator="EXISTS",
                value={"required": True},
                description=(
                    "Memiliki prestasi non-akademik atau pengalaman organisasi/komunitas sosial."
                ),
            ),
        ]
        benefits = [
            ScrapedBenefit(
                benefit_type="TUITION_FEE",
                description="Dukungan biaya kuliah penuh selama program.",
            ),
            ScrapedBenefit(
                benefit_type="LIVING_ALLOWANCE",
                description="Tunjangan biaya hidup bulanan.",
            ),
            ScrapedBenefit(
                benefit_type="LEADERSHIP_DEVELOPMENT",
                description="Pengembangan kepemimpinan terstruktur dan mentoring.",
            ),
            ScrapedBenefit(
                benefit_type="INTERNSHIP",
                description="Kesempatan pengalaman magang dan persiapan profesional.",
            ),
        ]

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Program Beasiswa Kepemimpinan TELADAN 2027",
                summary=(
                    "Program beasiswa dan pengembangan kepemimpinan Tanoto Foundation "
                    "untuk mahasiswa S1 di perguruan tinggi mitra."
                ),
                description=(
                    "TELADAN adalah program pengembangan kepemimpinan Tanoto Foundation "
                    "dengan dukungan biaya kuliah, tunjangan hidup, mentoring, dan pengalaman "
                    "pengembangan profesional."
                ),
                open_date=open_date,
                deadline=deadline,
                application_url=self.application_url,
                is_active=is_active,
                has_contextual_dates=bool(all_candidates) or deadline is not None,
                requirements=requirements,
                benefits=benefits,
                is_live_verified=True,
            )
        ]
