"""LPDP (Lembaga Pengelola Dana Pendidikan) scraper.

Source: https://lpdp.kemenkeu.go.id
Registration: https://beasiswalpdp-terintegrasi.kemenkeu.go.id

Source audit (2026-09-23):
- LPDP is the Indonesian Government's premier scholarship for
  postgraduate study (S2/S3) domestically and internationally.
- Key data:
  * Provider: LPDP / Kementerian Keuangan
  * Degree: S2, S3
  * Various program tracks (Reguler, Afirmasi, Targeted, STEM, dll.)
  * Requirements vary by program but core ones are identifiable
  * Registration via integrated portal

Limitation:
- The LPDP website structure changes with each registration period.
  This scraper provides known baseline data. The pipeline will
  log a WARNING if the page cannot be fetched or parsed.
"""

import logging
import re
from datetime import datetime

import httpx
from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)

logger = logging.getLogger(__name__)

_LPDP_REQUIREMENTS: list[ScrapedRequirement] = [
    ScrapedRequirement(
        requirement_type="DEGREE_LEVEL",
        operator="IN",
        value={"levels": ["S2", "S3"]},
        description="Program beasiswa untuk jenjang Magister (S2) dan Doktoral (S3)",
    ),
    ScrapedRequirement(
        requirement_type="GPA",
        operator="GTE",
        value={"gpa": 3.0},
        description="IPK minimal 3,00 dari skala 4,00",
    ),
]

_LPDP_BENEFITS: list[ScrapedBenefit] = [
    ScrapedBenefit(
        benefit_type="TUITION_FEE",
        description="Biaya pendidikan (tuition fee) penuh",
    ),
    ScrapedBenefit(
        benefit_type="LIVING_ALLOWANCE",
        description="Biaya hidup bulanan (living allowance)",
    ),
    ScrapedBenefit(
        benefit_type="OTHER",
        description="Tunjangan buku, riset, seminar, dan tesis/disertasi",
    ),
    ScrapedBenefit(
        benefit_type="OTHER",
        description="Biaya transportasi (tiket pesawat untuk luar negeri)",
    ),
]


class LpdpScraper(BaseScraper):
    """Scraper for LPDP scholarship program."""

    provider_name = "LPDP"
    source_url = "https://lpdp.kemenkeu.go.id/beasiswa"

    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch LPDP page and parse scholarships.

        Falls back to the known verified baseline data (without a live
        deadline) if the official page can't be reached — LPDP's site
        actively blocks automated requests, and the crawler's core value
        is the verified requirement/benefit data, not a live-scraped deadline.
        """
        logger.info("Fetching LPDP beasiswa page")
        try:
            response = self.fetch(self.source_url)
        except httpx.HTTPError as exc:
            logger.warning(
                "Could not reach LPDP page (%s) — using known baseline data instead",
                exc,
            )
            return self.parse_html("")

        return self.parse_html(response.text)

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        """Parse LPDP page HTML.

        The LPDP portal layout changes frequently. This parser
        extracts core scholarship data using known structure and
        supplements with verified baseline information.
        """
        soup = BeautifulSoup(html, "html.parser")

        # Extract meta info
        meta_desc = soup.find("meta", attrs={"name": "description"})
        description = (
            meta_desc.get("content", "").strip()
            if meta_desc
            else (
                "Beasiswa LPDP adalah program beasiswa dari Kementerian Keuangan RI "
                "untuk jenjang Magister (S2) dan Doktoral (S3) di dalam dan luar negeri."
            )
        )

        deadline = self._extract_deadline(soup)

        scholarship = ScrapedScholarship(
            provider_name=self.provider_name,
            source_url=self.source_url,
            title="Beasiswa LPDP",
            summary="Beasiswa penuh dari Kementerian Keuangan RI untuk jenjang S2 dan S3 di dalam dan luar negeri.",
            description=description,
            deadline=deadline,
            application_url="https://beasiswalpdp-terintegrasi.kemenkeu.go.id",
            is_active=True,
            requirements=list(_LPDP_REQUIREMENTS),
            benefits=list(_LPDP_BENEFITS),
        )

        return [scholarship]

    def _extract_deadline(self, soup: BeautifulSoup) -> datetime | None:
        """Attempt to extract deadline from page content."""
        text = soup.get_text()
        date_pattern = re.compile(
            r"(\d{1,2})\s+(Januari|Februari|Maret|April|Mei|Juni|"
            r"Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})",
            re.IGNORECASE,
        )
        months = {
            "januari": 1, "februari": 2, "maret": 3, "april": 4,
            "mei": 5, "juni": 6, "juli": 7, "agustus": 8,
            "september": 9, "oktober": 10, "november": 11, "desember": 12,
        }

        dates_found = []
        for match in date_pattern.finditer(text):
            day = int(match.group(1))
            month = months.get(match.group(2).lower())
            year = int(match.group(3))
            if month:
                try:
                    dates_found.append(datetime(year, month, day))
                except ValueError:
                    continue

        if dates_found:
            now = datetime.utcnow()
            future_dates = [d for d in dates_found if d > now]
            if future_dates:
                return max(future_dates)

        logger.info("No deadline found on LPDP page")
        return None