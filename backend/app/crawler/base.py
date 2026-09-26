"""Base abstractions for the RadarScholar curated crawler.

Defines:
- ScrapedRequirement / ScrapedBenefit — intermediate Pydantic models
- ScrapedScholarship — normalized extraction output
- BaseScraper — abstract class each curated scraper must implement
"""

import logging
import time
from abc import ABC, abstractmethod
from datetime import datetime

import httpx
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)


class ScrapedRequirement(BaseModel):
    """Intermediate model for a parsed scholarship requirement.

    Fields map directly to the existing ScholarshipRequirement DB schema
    so the pipeline can persist without translation.
    """

    requirement_type: str  # e.g. GPA, SEMESTER, DEGREE_LEVEL, ORGANIZATION
    operator: str  # e.g. GTE, EQ, IN, CONTAINS, EXISTS
    value: dict | list | str | float | int  # Structured requirement data (JSON-compatible)
    description: str  # Original human-readable text from the source


class ScrapedBenefit(BaseModel):
    """Intermediate model for a parsed scholarship benefit."""

    benefit_type: str  # e.g. TUITION_FEE, LIVING_ALLOWANCE, TRAINING
    description: str  # Human-readable benefit description


class ScrapedScholarship(BaseModel):
    """Normalized extraction output from a curated scraper.

    This is the contract between source-specific parsers and
    the pipeline's persistence layer.  Every field must map
    to an existing M3/M4 database column.
    """

    provider_name: str
    source_url: str  # Official page URL — primary dedup key
    title: str
    summary: str
    description: str
    deadline: datetime | None = None
    application_url: str
    is_active: bool = True
    requirements: list[ScrapedRequirement] = Field(default_factory=list)
    benefits: list[ScrapedBenefit] = Field(default_factory=list)


class BaseScraper(ABC):
    """Abstract base for curated scholarship scrapers.

    Each concrete scraper:
    1. Targets a single curated official source.
    2. Returns ``list[ScrapedScholarship]`` without touching the DB.
    3. Is independently unit-testable with HTML fixtures.
    """

    provider_name: str
    source_url: str

    # Browser-like headers — reduces trivial User-Agent-based bot blocking.
    # Not guaranteed to pass sites with active anti-bot protection
    # (Cloudflare challenges, IP/behavioral fingerprinting, etc.) — those
    # need a headless-browser scraper (e.g. Playwright), which is a bigger
    # change than this helper.
    _DEFAULT_HEADERS: dict[str, str] = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
    }

    def fetch(
        self,
        url: str,
        *,
        max_retries: int = 2,
        backoff_seconds: float = 3.0,
    ) -> httpx.Response:
        """Fetch a URL with browser-like headers and retry-with-backoff.

        Helps with transient network hiccups (e.g. a slow origin server
        timing out once) and reduces the chance of being blocked purely
        for looking like a generic script. Raises the last ``httpx.HTTPError``
        if every attempt fails.
        """
        last_exc: httpx.HTTPError | None = None
        for attempt in range(1, max_retries + 2):
            try:
                response = httpx.get(
                    url,
                    timeout=httpx.Timeout(connect=10.0, read=30.0, write=10.0, pool=10.0),
                    follow_redirects=True,
                    headers=self._DEFAULT_HEADERS,
                )
                response.raise_for_status()
                return response
            except httpx.HTTPError as exc:
                last_exc = exc
                if attempt <= max_retries:
                    wait = backoff_seconds * attempt
                    logger.warning(
                        "Fetch attempt %d/%d failed for %s (%s) — retrying in %.0fs",
                        attempt, max_retries + 1, url, exc, wait,
                    )
                    time.sleep(wait)
        if last_exc is not None:
            raise last_exc
        
        # Fallback if max_retries was set to a negative number somehow
        raise RuntimeError(f"Fetch failed for {url}: exceeded max retries without an explicit error")

    @abstractmethod
    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch and parse scholarships from the official source.

        Returns a list of normalized ScrapedScholarship objects.
        Must NOT access the database.
        """
        ...

    def parse_html(self, html: str) -> list[ScrapedScholarship]:
        """Parse raw HTML into ScrapedScholarship objects.

        Separated from ``scrape()`` so tests can call this
        directly with fixture HTML without network access.
        """
        raise NotImplementedError(
            f"{self.__class__.__name__} does not implement parse_html"
        )