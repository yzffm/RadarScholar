"""Van Deventer-Maas Indonesia (VDMI) scholarship scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedBenefit, ScrapedScholarship
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class VdmiScraper(BaseScraper):
    """Scrape the public Van Deventer-Maas Indonesia (VDMI) official website."""

    provider_name = "Van Deventer-Maas Indonesia (VDMI)"
    source_url = "https://vandeventermaas.or.id/"
    application_url = "https://vandeventermaas.or.id/"

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
        if "Van Deventer-Maas" not in text:
            raise ValueError("VDMI scholarship marker was not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)

        lower_text = text.lower()
        benefits: list[ScrapedBenefit] = []
        if "grants for scholarships" in lower_text or "capacity building" in lower_text:
            benefits.append(
                ScrapedBenefit(
                    benefit_type="EDUCATIONAL_SUPPORT",
                    description="Dukungan hibah beasiswa (grants for scholarships) dan program capacity building.",
                )
            )

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa Van Deventer-Maas Indonesia (VDMI)",
                summary=(
                    "Program hibah beasiswa dan pengembangan kapasitas (capacity building) "
                    "dari Yayasan Van Deventer-Maas Indonesia."
                ),
                description=(
                    "Informasi program diambil dari halaman resmi Van Deventer-Maas Indonesia. "
                    "Batas waktu pendaftaran dan persyaratan detail periode aktif tidak "
                    "diasumsikan apabila belum tercantum pada halaman publik."
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
