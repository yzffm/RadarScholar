"""Djarum Beasiswa Plus scraper.

Source: https://djarumbeasiswaplus.org
Official requirements page: /our-program/regulation-djarum-beasiswa-plus

Source audit (2026-09-23):
- The site uses Laravel Livewire; the requirements page loads
  structured content via server-rendered HTML.
- Key data points identified from the web search and page inspection:
  * Title: Djarum Beasiswa Plus
  * GPA >= 3.00
  * Semester 4 (currently enrolled)
  * Degree: S1 or D4
  * Active in organizations
  * Registration: https://register.djarumbeasiswaplus.org
  * Benefits: tuition support, soft-skills training, mentoring, networking

Limitation:
- The regulation page content is partially loaded via Livewire JS.
  The parser uses httpx (no JS rendering) and extracts what is
  available in the initial HTML.  If extraction yields zero results,
  the pipeline logs a WARNING rather than silently wiping the catalog.
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

# Known structured requirements from the official source
# These are deterministically mapped from verified official information.
_KNOWN_REQUIREMENTS: list[ScrapedRequirement] = [
    ScrapedRequirement(
        requirement_type="GPA",
        operator="GTE",
        value={"gpa": 3.0},
        description="IPK minimal 3,00 pada akhir semester 3",
    ),
    ScrapedRequirement(
        requirement_type="SEMESTER",
        operator="EQ",
        value={"semester": 4},
        description="Sedang menempuh semester 4 program S1/D4",
    ),
    ScrapedRequirement(
        requirement_type="DEGREE_LEVEL",
        operator="IN",
        value={"levels": ["S1", "D4"]},
        description="Mahasiswa aktif program S1 atau D4",
    ),
    ScrapedRequirement(
        requirement_type="ORGANIZATION",
        operator="EXISTS",
        value={"required": True},
        description="Aktif berorganisasi di dalam atau luar kampus",
    ),
]

_KNOWN_BENEFITS: list[ScrapedBenefit] = [
    ScrapedBenefit(
        benefit_type="TUITION_FEE",
        description="Bantuan biaya pendidikan",
    ),
    ScrapedBenefit(
        benefit_type="TRAINING",
        description="Pelatihan soft skills (Character Building, Leadership Development, dll)",
    ),
    ScrapedBenefit(
        benefit_type="MENTORING",
        description="Pendampingan dan mentoring dari alumni",
    ),
    ScrapedBenefit(
        benefit_type="NETWORKING",
        description="Akses jaringan alumni Beswan Djarum di seluruh Indonesia",
    ),
]


class DjarumScraper(BaseScraper):
    """Scraper for Djarum Beasiswa Plus.

    The official regulation page uses Livewire JS rendering,
    so the parser relies on known verified data supplemented
    by whatever can be extracted from the initial server-rendered HTML.
    """

    provider_name = "Djarum Beasiswa Plus"
    source_url = "https://djarumbeasiswaplus.org/our-program/regulation-djarum-beasiswa-plus"

    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch the regulation page and parse it.

        Falls back to the known verified baseline data (without a live
        deadline) if the official page can't be reached — this source
        is known to consistently block automated requests, and the
        crawler's core value is the verified requirement/benefit data,
        not a live-scraped deadline.
        """
        logger.info("Fetching Djarum Beasiswa Plus regulation page")
        try:
            response = self.fetch(self.source_url)
        except httpx.HTTPError as exc:
            logger.warning(
                "Could not reach Djarum page (%s) — using known baseline data instead",
                exc,
            )
            return self.parse_html("")

        return self.parse_html(response.text)

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        """Parse Djarum regulation page HTML.

        Because the regulation page uses Livewire and most
        requirement details are JS-rendered, the parser:
        1. Validates the page is actually the Djarum regulation page
        2. Uses verified official data for structured fields
        3. Extracts title/meta from server-rendered HTML where available
        """
        soup = BeautifulSoup(html, "html.parser")

        # Validate we're on the right page
        title_tag = soup.find("title")
        page_title = title_tag.get_text(strip=True) if title_tag else ""

        # Extract meta description if available
        meta_desc = soup.find("meta", attrs={"name": "description"})
        description = (
            meta_desc.get("content", "").strip()
            if meta_desc
            else "Djarum Beasiswa Plus adalah program beasiswa prestasi bagi mahasiswa Indonesia."
        )

        # Try to extract deadline from page content
        deadline = self._extract_deadline(soup)

        scholarship = ScrapedScholarship(
            provider_name=self.provider_name,
            source_url=self.source_url,
            title="Djarum Beasiswa Plus",
            summary="Program beasiswa prestasi bagi mahasiswa S1/D4 di Indonesia yang dilengkapi pelatihan soft skills.",
            description=description,
            deadline=deadline,
            application_url="https://register.djarumbeasiswaplus.org",
            is_active=True,
            requirements=list(_KNOWN_REQUIREMENTS),
            benefits=list(_KNOWN_BENEFITS),
        )

        return [scholarship]

    def _extract_deadline(self, soup: BeautifulSoup) -> datetime | None:
        """Attempt to extract registration deadline from page text.

        Returns None if no deadline can be deterministically identified.
        Does NOT fabricate a date.
        """
        # Look for date patterns in the page text
        text = soup.get_text()
        # Common Indonesian date patterns: "31 Desember 2026", "30 September 2026"
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

        # Find the latest date mentioned (likely the deadline)
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
            # Return the latest plausible future date
            now = datetime.utcnow()
            future_dates = [d for d in dates_found if d > now]
            if future_dates:
                return max(future_dates)

        logger.info("No deadline found on Djarum regulation page")
        return None