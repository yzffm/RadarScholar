"""UGM Directorate of Student Affairs scholarship bulletin scraper."""

from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)
from app.crawler.date_utils import extract_contextual_dates, extract_contextual_deadline


class UgmScholarshipBulletinScraper(BaseScraper):
    """Scrape one official UGM scholarship bulletin article."""

    provider_name = "UGM Direktorat Kemahasiswaan Bulletin"
    source_url = (
        "https://ditmawa.ugm.ac.id/2026/09/"
        "pembukaan-pendaftaran-beasiswa-cendekia-baznas-bcb-kerja-sama-kampus-dalam-negeri-2026/"
    )
    application_url = "https://beasiswa.baznas.go.id"

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text(" ", strip=True)
        if "Beasiswa Cendekia BAZNAS" not in text:
            raise ValueError("UGM BAZNAS bulletin marker was not found")

        deadline = extract_contextual_deadline(text)
        historical_deadlines = extract_contextual_dates(text)
        return [
            ScrapedScholarship(
                provider_name=self.provider_name,
                source_url=self.source_url,
                title="Beasiswa Cendekia BAZNAS - Kerja Sama Kampus Dalam Negeri 2026",
                summary=(
                    "Pengumuman resmi Direktorat Kemahasiswaan UGM tentang "
                    "Beasiswa Cendekia BAZNAS."
                ),
                description=(
                    "Program BAZNAS yang diumumkan melalui bulletin resmi UGM. "
                    "Cakupan pengumuman ini mengikuti konteks mahasiswa dan proses "
                    "pendaftaran yang disampaikan UGM."
                ),
                deadline=deadline,
                application_url=self.application_url,
                requirements=[
                    ScrapedRequirement(
                        requirement_type="DEGREE_LEVEL",
                        operator="IN",
                        value={"levels": ["S1", "D4"]},
                        description="Mahasiswa aktif program S1 Reguler dan D4.",
                    ),
                    ScrapedRequirement(
                        requirement_type="SEMESTER",
                        operator="EQ",
                        value={"semester": 5},
                        description="Mulai semester 5.",
                    ),
                    ScrapedRequirement(
                        requirement_type="GPA",
                        operator="GTE",
                        value={"gpa": 3.0},
                        description="IPK minimal 3,00 dari skala 4,00.",
                    ),
                    ScrapedRequirement(
                        requirement_type="NATIONALITY",
                        operator="EQ",
                        value={"country": "Indonesia"},
                        description="Warga negara Indonesia.",
                    ),
                ],
                benefits=[
                    ScrapedBenefit(
                        benefit_type="TUITION_FEE",
                        description="Bantuan UKT maksimal Rp7.000.000 per semester.",
                    ),
                    ScrapedBenefit(
                        benefit_type="RESEARCH_SUPPORT",
                        description="Bantuan biaya riset tugas akhir bagi peserta yang memenuhi ketentuan.",
                    ),
                    ScrapedBenefit(
                        benefit_type="MENTORING",
                        description="Pengembangan diri bersama mentor beasiswa BAZNAS.",
                    ),
                ],
                is_active=not historical_deadlines or deadline is not None,
                is_live_verified=True,
            )
        ]
