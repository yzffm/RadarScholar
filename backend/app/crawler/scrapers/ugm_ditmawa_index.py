"""UGM Direktorat Kemahasiswaan category index scraper (info-beasiswa)."""

from datetime import datetime, timedelta
from urllib.parse import urlsplit, urlunsplit

from bs4 import BeautifulSoup

from app.crawler.base import BaseScraper, ScrapedScholarship
from app.crawler.date_utils import _normalize_reference_time, parse_indonesian_date


def _normalize_post_url(url: str) -> str:
    parts = urlsplit(url.strip())
    path = parts.path.rstrip("/") or "/"
    return urlunsplit((parts.scheme.lower(), parts.netloc.lower(), path, "", ""))


class UgmDitmawaIndexScraper(BaseScraper):
    """Scrape the first page of UGM Ditmawa's info-beasiswa category index.

    Rules (D3):
    - First page only (never follows pagination).
    - At most ``max_posts`` items returned.
    - Ignores posts older than ``max_age_days`` (default 90 days) relative to ``reference_time``.
    - Deduplicates by normalized post URL.
    - Uses polite per-host delay via ``BaseScraper.fetch``.
    - Does not copy long article text; leaves unwritten values (deadline, requirements, benefits) empty.
    """

    provider_name = "UGM Direktorat Kemahasiswaan - Info Beasiswa"
    source_url = "https://ditmawa.ugm.ac.id/category/info-beasiswa/"

    def __init__(self, max_posts: int = 5, max_age_days: int = 90) -> None:
        self.max_posts = max_posts
        self.max_age_days = max_age_days

    def scrape(self) -> list[ScrapedScholarship]:
        response = self.fetch(self.source_url)
        return self.parse_html(response.text)

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
        max_posts: int | None = None,
    ) -> list[ScrapedScholarship]:
        soup = BeautifulSoup(html, "html.parser")
        text = soup.get_text(" ", strip=True)
        articles = soup.select("article.post")
        if not articles and "Info Beasiswa" not in text:
            raise ValueError("UGM Ditmawa category index marker was not found")

        now_utc = _normalize_reference_time(reference_time)
        cutoff_utc = now_utc - timedelta(days=self.max_age_days)
        limit = self.max_posts if max_posts is None else max_posts

        results: list[ScrapedScholarship] = []
        seen_urls: set[str] = set()

        for article in articles:
            if len(results) >= limit:
                break

            link = article.select_one(".post-title h3 a, h3 a, h2 a")
            if link is None:
                continue

            title = link.get_text(" ", strip=True)
            href = (link.get("href") or "").strip()
            if not title or not href:
                continue

            norm_url = _normalize_post_url(href)
            if norm_url in seen_urls:
                continue

            date_el = article.select_one(".post-date")
            date_text = date_el.get_text(" ", strip=True) if date_el else ""
            post_date = parse_indonesian_date(date_text)
            if post_date is None or post_date < cutoff_utc:
                continue

            seen_urls.add(norm_url)
            results.append(
                ScrapedScholarship(
                    provider_name=self.provider_name,
                    source_url=self.source_url,
                    title=title,
                    summary=f"Pengumuman beasiswa resmi {self.provider_name}: {title}.",
                    description=(
                        f"Pengumuman indeks resmi {self.provider_name}. "
                        f"Buka tautan resmi ({norm_url}) untuk melihat rincian persyaratan dan batas waktu."
                    ),
                    deadline=None,
                    application_url=norm_url,
                    requirements=[],
                    benefits=[],
                    is_active=True,
                    has_contextual_dates=False,
                    is_live_verified=True,
                )
            )

        return results

