"""UGM Directorate of Student Affairs scholarship bulletin scraper."""

from datetime import datetime

from bs4 import BeautifulSoup

from app.crawler.base import (
    BaseScraper,
    ScrapedBenefit,
    ScrapedRequirement,
    ScrapedScholarship,
)
from app.crawler.date_utils import (
    _normalize_reference_time,
    extract_contextual_dates,
    extract_contextual_deadline,
    extract_registration_period,
)


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

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text(" ", strip=True)
        if "Beasiswa Cendekia BAZNAS" not in text:
            raise ValueError("UGM BAZNAS bulletin marker was not found")

        open_date, range_deadline = extract_registration_period(text)
        ctx_deadline = extract_contextual_deadline(text, reference_time=reference_time)
        historical_deadlines = extract_contextual_dates(text)
        if range_deadline and range_deadline not in historical_deadlines:
            historical_deadlines.append(range_deadline)

        if ctx_deadline is not None:
            deadline = ctx_deadline
        elif range_deadline is not None:
            deadline = max([range_deadline] + historical_deadlines) if historical_deadlines else range_deadline
        elif historical_deadlines:
            deadline = max(historical_deadlines)
        else:
            deadline = None

        now_utc = _normalize_reference_time(reference_time)
        is_active = (
            deadline is not None
            and deadline >= now_utc
            and (open_date is None or open_date <= now_utc)
        )
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
                open_date=open_date,
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
                is_active=is_active,
                has_contextual_dates=bool(historical_deadlines or open_date),
                is_live_verified=True,
            )
        ]
