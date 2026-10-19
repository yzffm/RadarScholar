"""CIMB Niaga scholarship scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedBenefit, ScrapedScholarship
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class CimbScholarshipScraper(BaseScraper):
    """Scrape the public CIMB Niaga CSR scholarship page."""

    provider_name = "CIMB Niaga Scholarship"
    source_url = "https://investor.cimbniaga.co.id/csr/scholarship.html"
    application_url = source_url

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        text = BeautifulSoup(html, "html.parser").get_text(" ", strip=True)
        if "scholarship" not in text.lower():
            raise ValueError("CIMB scholarship marker was not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)
        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="CIMB Niaga Scholarship Program",
                summary="Program beasiswa CIMB Niaga untuk memperluas akses pendidikan dan pengembangan kapasitas mahasiswa berprestasi.",
                description="Informasi program diambil dari halaman resmi CIMB Niaga. Deadline dan persyaratan periode aktif belum dianggap diketahui jika tidak tercantum pada halaman publik.",
                deadline=deadline,
                application_url=self.application_url,
                requirements=[],
                benefits=[ScrapedBenefit(benefit_type="EDUCATIONAL_SUPPORT", description="Dukungan pendanaan pendidikan dan capacity building.")],
                is_active=deadline is not None,
                has_contextual_dates=bool(historical_deadlines),
                is_live_verified=True,
            )
        ]
