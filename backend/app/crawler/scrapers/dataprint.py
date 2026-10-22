"""Beasiswa DataPrint scholarship scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedBenefit, ScrapedScholarship
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class DataPrintScraper(BaseScraper):
    """Scrape the public Beasiswa DataPrint CSR program page."""

    provider_name = "Beasiswa DataPrint"
    source_url = "https://beasiswadataprint.com/"
    application_url = "https://beasiswadataprint.com/"

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text("\n", strip=True)
        if "Beasiswa DataPrint" not in text:
            raise ValueError("DataPrint scholarship marker was not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)

        benefits: list[ScrapedBenefit] = []
        if "Rp 500 ribu/penerima beasiswa" in text:
            benefits.append(
                ScrapedBenefit(
                    benefit_type="EDUCATIONAL_SUPPORT",
                    description=(
                        "Dana beasiswa tambahan biaya pendidikan Rp 500 ribu/penerima beasiswa "
                        "(diberikan satu kali bagi peserta yang lolos penilaian)."
                    ),
                )
            )

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa DataPrint",
                summary=(
                    "Program CSR Beasiswa DataPrint berupa dana tambahan biaya pendidikan "
                    "bagi pelajar dan mahasiswa aktif."
                ),
                description=(
                    "Beasiswa DataPrint merupakan dana tambahan biaya pendidikan satu kali "
                    "berdasarkan penilaian video essay, prestasi, dan keaktifan pada halaman resmi DataPrint."
                ),
                deadline=deadline,
                application_url=self.application_url,
                requirements=[],
                benefits=benefits,
                is_active=deadline is not None,
                has_contextual_dates=bool(historical_deadlines),
                is_live_verified=True,
            )
        ]

