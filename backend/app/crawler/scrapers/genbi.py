"""Bank Indonesia / GenBI education portal scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedScholarship
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class BankIndonesiaGenbiScraper(BaseScraper):
    """Scrape the public Bank Indonesia Edukasi portal."""

    provider_name = "Bank Indonesia / GenBI"
    source_url = "https://www.bi.go.id/id/edukasi/"
    application_url = "https://www.bi.go.id/id/edukasi/"

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
        if "Bank Indonesia" not in text or "Edukasi" not in text:
            raise ValueError("Bank Indonesia Edukasi marker was not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa Bank Indonesia (GenBI)",
                summary=(
                    "Portal edukasi resmi Bank Indonesia. Rincian pendaftaran Beasiswa "
                    "Bank Indonesia (GenBI) mengacu pada pengumuman resmi yang sedang berjalan."
                ),
                description=(
                    "Informasi sumber diambil dari portal Edukasi Bank Indonesia. "
                    "Batas waktu pendaftaran, komponen manfaat, dan persyaratan spesifik "
                    "tidak diasumsikan apabila tidak tertulis pada halaman publik ini."
                ),
                deadline=deadline,
                application_url=self.application_url,
                requirements=[],
                benefits=[],
                is_active=deadline is not None,
                has_contextual_dates=bool(historical_deadlines),
                is_live_verified=True,
            )
        ]

