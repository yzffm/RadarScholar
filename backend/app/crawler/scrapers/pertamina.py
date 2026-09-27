"""Pertamina Foundation Sobat Bumi scholarship scraper."""

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedBenefit, ScrapedScholarship
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class PertaminaSobatBumiScraper(BaseScraper):
    """Scrape public scholarship information from Pertamina Foundation."""

    provider_name = "Pertamina Foundation Sobat Bumi"
    source_url = "https://www.pertaminafoundation.org/"
    application_url = source_url

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        text = BeautifulSoup(html, "html.parser").get_text(" ", strip=True)
        if "Sobat Bumi" not in text:
            raise ValueError("Sobat Bumi marker was not found")

        deadline = extract_contextual_deadline(text)
        historical_deadlines = extract_contextual_dates(text)
        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa Sobat Bumi",
                summary="Program beasiswa Pertamina Foundation untuk mendukung pendidikan dan kontribusi generasi muda Indonesia.",
                description="Informasi program diambil dari halaman resmi Pertamina Foundation. Persyaratan detail harus diverifikasi pada pengumuman resmi periode terkait.",
                deadline=deadline,
                application_url=self.application_url,
                requirements=[],
                benefits=[ScrapedBenefit(benefit_type="EDUCATIONAL_SUPPORT", description="Dukungan pendidikan dari Pertamina Foundation.")],
                is_active=not historical_deadlines or deadline is not None,
                is_live_verified=True,
            )
        ]
