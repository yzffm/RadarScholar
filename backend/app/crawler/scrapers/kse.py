"""Karya Salemba Empat (KSE) scholarship scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class KseScraper(BaseScraper):
    """Scrape the public Karya Salemba Empat (KSE) official website."""

    provider_name = "Karya Salemba Empat (KSE)"
    source_url = "https://kse.or.id/"
    application_url = "https://beasiswa.or.id"

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text(" ", strip=True)
        if "Program Beasiswa KSE" not in text and "Karya Salemba Empat" not in text:
            raise ValueError("KSE scholarship marker was not found")

        deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)

        requirements: list[ScrapedRequirement] = []
        if "mahasiswa S1" in text:
            requirements.append(
                ScrapedRequirement(
                    requirement_type="DEGREE_LEVEL",
                    operator="EQ",
                    value={"level": "S1"},
                    description="Mahasiswa program S1 yang membutuhkan bantuan finansial.",
                )
            )

        benefits = [
            ScrapedBenefit(
                benefit_type="TUITION_FEE",
                description="Bantuan finansial pendidikan tinggi untuk mahasiswa S1.",
            ),
            ScrapedBenefit(
                benefit_type="LEADERSHIP_DEVELOPMENT",
                description="Pengembangan diri, pelatihan kepemimpinan, soft skills, dan bimbingan karier.",
            ),
            ScrapedBenefit(
                benefit_type="TRAINING",
                description="Pembekalan inovasi, kewirausahaan, dan pengabdian masyarakat.",
            ),
        ]

        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa Karya Salemba Empat (KSE)",
                summary=(
                    "Program bantuan finansial dan pengembangan diri Karya Salemba Empat "
                    "bagi mahasiswa S1 di perguruan tinggi mitra."
                ),
                description=(
                    "Program Beasiswa KSE memberikan dukungan finansial, pelatihan kepemimpinan, "
                    "inovasi kewirausahaan, serta pengabdian masyarakat. Jadwal dan persyaratan "
                    "spesifik per kampus mengikuti pengumuman resmi KSE."
                ),
                deadline=deadline,
                application_url=self.application_url,
                requirements=requirements,
                benefits=benefits,
                is_active=deadline is not None,
                has_contextual_dates=bool(historical_deadlines),
                is_live_verified=True,
            )
        ]

