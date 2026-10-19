"""BCA PPBP/PPTI scholarship scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class BcaScholarshipScraper(BaseScraper):
    """Scrape the public official BCA scholarship page."""

    provider_name = "Beasiswa BCA PPBP/PPTI"
    source_url = "https://karir.bca.co.id/beasiswa-bca"
    application_url = "https://karir.bca.co.id/beasiswa-bca"

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        text = BeautifulSoup(html, "html.parser").get_text(" ", strip=True)
        if "Beasiswa BCA" not in text or "PPBP" not in text or "PPTI" not in text:
            raise ValueError("BCA scholarship program markers were not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa BCA PPBP/PPTI",
                summary=(
                    "Program Pendidikan Bisnis dan Perbankan (PPBP) serta "
                    "Program Pendidikan Teknik Informatika (PPTI) BCA."
                ),
                description=(
                    "Program pendidikan BCA untuk lulusan SMA/SMK berprestasi, "
                    "dengan dukungan pendidikan, uang saku, dan peluang pengembangan karier."
                ),
                deadline=deadline,
                application_url=self.application_url,
                requirements=[
                    ScrapedRequirement(
                        requirement_type="NATIONALITY",
                        operator="EQ",
                        value={"country": "Indonesia"},
                        description="Warga negara Indonesia.",
                    ),
                    ScrapedRequirement(
                        requirement_type="EDUCATION_LEVEL",
                        operator="IN",
                        value={"levels": ["SMA", "SMK"]},
                        description="Siswa kelas XII atau lulusan SMA/SMK.",
                    ),
                    ScrapedRequirement(
                        requirement_type="AGE",
                        operator="LTE",
                        value={"age": 19},
                        description="Usia maksimum 19 tahun saat mendaftar.",
                    ),
                ],
                benefits=[
                    ScrapedBenefit(
                        benefit_type="TUITION_FEE",
                        description="Bebas biaya pendidikan.",
                    ),
                    ScrapedBenefit(
                        benefit_type="LIVING_ALLOWANCE",
                        description="Uang saku setiap bulan.",
                    ),
                    ScrapedBenefit(
                        benefit_type="BOOKS",
                        description="Buku pelajaran selama program.",
                    ),
                    ScrapedBenefit(
                        benefit_type="INTERNSHIP",
                        description="Kesempatan magang dan penawaran kerja BCA.",
                    ),
                ],
                is_active=deadline is not None,
                has_contextual_dates=bool(historical_deadlines),
                is_live_verified=True,
            )
        ]
