"""Base abstractions for the RadarScholar curated crawler.

Defines:
- SourceUnavailableError — raised when a source is unreachable / blocked
- ScrapedRequirement / ScrapedBenefit — intermediate Pydantic models
- ScrapedScholarship — normalized extraction output
- BaseScraper — abstract class each curated scraper must implement
"""

import logging
import re
import time
from abc import ABC, abstractmethod
from datetime import datetime
from typing import ClassVar
from urllib.parse import urlsplit
from urllib.robotparser import RobotFileParser

import httpx
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

# HTTP status codes that indicate a source is intentionally blocking us.
# These MUST NOT be retried — they are policy decisions by the server.
_NO_RETRY_STATUSES = frozenset({401, 403, 451})

# <title> patterns that indicate anti-bot challenge pages.
# Checked with case-insensitive match on the first <title> tag only.
_CHALLENGE_TITLE_PATTERNS = re.compile(
    r"just a moment|attention required|access denied|verify you are human",
    re.IGNORECASE,
)

# Responses shorter than this (in characters) after a successful status code
# are suspicious — likely an empty placeholder, redirect page, or WAF
# interstitial rather than real content.
_MIN_CONTENT_CHARS = 500


class SourceUnavailableError(httpx.HTTPError):
    """The source is unreachable or actively blocking automated requests.

    This is a subclass of ``httpx.HTTPError`` so existing ``except
    httpx.HTTPError`` catch blocks (e.g. in djarum.py and lpdp.py
    fallback paths) continue to work without modification.

    The crawler pipeline handles this error separately from parse/DB
    errors: it preserves existing data and does NOT count the source
    as a hard failure.
    """

    def __init__(self, message: str, *, url: str = "") -> None:
        super().__init__(message)
        self.url = url


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
    is_active: bool = False
    # True when at least one contextual deadline date (past or future) was
    # extracted from the source page; False when no date was found at all.
    # Allows the pipeline to distinguish "dates found and all expired"
    # (deactivate) from "no date present on page" (preserve existing state).
    has_contextual_dates: bool = True
    requirements: list[ScrapedRequirement] = Field(default_factory=list)
    benefits: list[ScrapedBenefit] = Field(default_factory=list)
    # True when this data came from a successfully fetched live page just now;
    # False when it's the known verified baseline used as a fallback because
    # the official page couldn't be reached. Lets the pipeline track, per
    # scholarship, when it was last actually confirmed against the live source.
    is_live_verified: bool = False


class BaseScraper(ABC):
    """Abstract base for curated scholarship scrapers.

    Each concrete scraper:
    1. Targets a single curated official source.
    2. Returns ``list[ScrapedScholarship]`` without touching the DB.
    3. Is independently unit-testable with HTML fixtures.
    """

    provider_name: str
    source_url: str

    # Polite minimum interval (in seconds) between HTTP requests to the same host.
    # Default is 1.0s in production; tests set this to 0.0s.
    min_host_interval_seconds: ClassVar[float] = 1.0

    # Per-run cache of parsed robots.txt policies (or error strings for unavailable hosts)
    # keyed by normalized origin ("scheme://host").
    _robots_cache: ClassVar[dict[str, RobotFileParser | str]] = {}

    # Per-run tracker of the last monotonic request timestamp per host ("netloc").
    _host_last_request_at: ClassVar[dict[str, float]] = {}

    # Browser-like headers — reduces trivial User-Agent-based bot blocking.
    # Not guaranteed to pass sites with active anti-bot protection
    # (Cloudflare challenges, IP/behavioral fingerprinting, etc.).
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

    @classmethod
    def reset_runtime_state(cls) -> None:
        """Clear per-run robots.txt cache and per-host rate-limit timestamps."""
        cls._robots_cache.clear()
        cls._host_last_request_at.clear()

    @classmethod
    def _wait_for_host_slot(cls, url: str) -> None:
        """Enforce polite minimum delay between consecutive requests to the same host."""
        parsed = urlsplit(url)
        host = parsed.netloc.lower()
        if not host:
            return
        interval = cls.min_host_interval_seconds
        now = time.monotonic()
        if interval > 0 and host in cls._host_last_request_at:
            elapsed = now - cls._host_last_request_at[host]
            if elapsed < interval:
                sleep_for = interval - elapsed
                logger.debug("Polite host delay %.2fs for %s", sleep_for, host)
                time.sleep(sleep_for)
                now = time.monotonic()
        cls._host_last_request_at[host] = now

    @classmethod
    def _get_or_fetch_robots_parser(cls, url: str) -> RobotFileParser:
        """Fetch and parse robots.txt for ``url``'s origin, cached per crawler run.

        This check is strictly ``robots.txt-compliant``:
        - Uses ``httpx.get`` with the same User-Agent and explicit timeouts.
        - Only HTTP 200 is accepted as a valid ``robots.txt`` response; rules are
          parsed with ``RobotFileParser.parse()``.
        - Any non-200 HTTP status (including 201/202/203/204/206, 401/403/404/451,
          5xx) or network error conservatively treats the source as unavailable
          and raises ``SourceUnavailableError`` (cached per run).
        """
        parsed = urlsplit(url)
        if not parsed.scheme or not parsed.netloc:
            rp = RobotFileParser()
            rp.allow_all = True
            return rp

        origin = f"{parsed.scheme.lower()}://{parsed.netloc.lower()}"
        cached = cls._robots_cache.get(origin)
        if isinstance(cached, str):
            raise SourceUnavailableError(cached, url=url)
        if isinstance(cached, RobotFileParser):
            return cached

        robots_url = f"{origin}/robots.txt"
        cls._wait_for_host_slot(robots_url)
        try:
            response = httpx.get(
                robots_url,
                timeout=httpx.Timeout(connect=10.0, read=15.0, write=10.0, pool=10.0),
                follow_redirects=True,
                headers=cls._DEFAULT_HEADERS,
            )
            cls._log_response(robots_url, response)
        except httpx.HTTPError as exc:
            msg = f"Failed to fetch robots.txt at {robots_url}: {exc}"
            cls._robots_cache[origin] = msg
            raise SourceUnavailableError(msg, url=url) from exc

        status = response.status_code
        if status != 200:
            msg = (
                f"Conservative robots.txt block: HTTP {status} (expected 200) "
                f"when fetching {robots_url}"
            )
            cls._robots_cache[origin] = msg
            raise SourceUnavailableError(msg, url=url)

        rp = RobotFileParser()
        rp.parse(response.text.splitlines())
        cls._robots_cache[origin] = rp
        return rp

    @classmethod
    def check_robots_txt(cls, url: str) -> None:
        """Verify ``url`` is allowed by the origin's robots.txt policy.

        Raises ``SourceUnavailableError`` if robots.txt disallows crawling ``url``
        or if fetching robots.txt fails with 401/403/451/5xx/network error.
        """
        rp = cls._get_or_fetch_robots_parser(url)
        user_agent = cls._DEFAULT_HEADERS.get("User-Agent", "*")
        if not rp.can_fetch(user_agent, url):
            raise SourceUnavailableError(
                f"Disallowed by robots.txt policy for {url}",
                url=url,
            )

    def fetch(
        self,
        url: str,
        *,
        max_retries: int = 2,
        backoff_seconds: float = 3.0,
        check_robots: bool = True,
    ) -> httpx.Response:
        """Fetch a URL with robots.txt compliance, per-host polite delay, and retry-with-backoff.

        Raises:
            SourceUnavailableError: disallowed/unreachable robots.txt, HTTP 401/403/451
                (no retry), challenge page detected via ``<title>``, or response
                body < 500 characters.
            httpx.HTTPError: transient failures after exhausting retries.
        """
        if check_robots:
            self.check_robots_txt(url)

        last_exc: httpx.HTTPError | None = None
        for attempt in range(1, max_retries + 2):
            try:
                self._wait_for_host_slot(url)
                response = httpx.get(
                    url,
                    timeout=httpx.Timeout(connect=10.0, read=30.0, write=10.0, pool=10.0),
                    follow_redirects=True,
                    headers=self._DEFAULT_HEADERS,
                )

                # Log response metadata for every attempt (B1 requirement).
                self._log_response(url, response)

                # 401/403/451 → immediate SourceUnavailableError, no retry.
                if response.status_code in _NO_RETRY_STATUSES:
                    raise SourceUnavailableError(
                        f"HTTP {response.status_code} — source is blocking access",
                        url=url,
                    )

                response.raise_for_status()

                # Only HTTP 200 is valid for static HTML GET requests; any other
                # 2xx status (201/202/203/204/206, e.g. AWS WAF 202 interstitial)
                # is rejected immediately without retry.
                if response.status_code != 200:
                    raise SourceUnavailableError(
                        f"HTTP {response.status_code} (expected 200) — non-200 2xx response",
                        url=url,
                    )

                # Detect challenge pages by <title> only or short body (< 500 chars).
                self._check_challenge_page(url, response)

                return response

            except SourceUnavailableError:
                raise  # Never retry intentional blocks or challenge pages.

            except httpx.HTTPError as exc:
                last_exc = exc
                if attempt <= max_retries:
                    wait = backoff_seconds * attempt
                    logger.warning(
                        "Fetch attempt %d/%d failed for %s (%s) — retrying in %.0fs",
                        attempt, max_retries + 1, url, exc, wait,
                    )
                    time.sleep(wait)

        if last_exc is None:
            raise RuntimeError("Unreachable: fetch failed without an exception")
        raise last_exc  # noqa: RSE102 — last_exc is always set when this line is reached

    # ------------------------------------------------------------------
    # Fetch helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _log_response(url: str, response: httpx.Response) -> None:
        """Log status, size (bytes), final URL, and present diagnostic headers."""
        final_url = str(response.url)
        content_len = len(response.content)
        diag_headers: list[str] = []
        for header_name in ("server", "x-amzn-waf-action", "cf-mitigated"):
            val = response.headers.get(header_name)
            if val:
                diag_headers.append(f"{header_name}={val}")
        headers_suffix = (" " + " ".join(diag_headers)) if diag_headers else ""
        logger.info(
            "Fetch %s: status=%d size=%d final_url=%s%s",
            url, response.status_code, content_len, final_url, headers_suffix,
        )

    @staticmethod
    def _check_challenge_page(url: str, response: httpx.Response) -> None:
        """Detect anti-bot challenge pages by inspecting <title> only or < 500 chars.

        Raises ``SourceUnavailableError`` if a challenge pattern is found in
        ``<title>`` or if the response text is shorter than 500 characters.
        """
        content = response.text

        # Extract <title> first and check against known challenge patterns.
        title_match = re.search(
            r"<title[^>]*>(.*?)</title>", content, re.IGNORECASE | re.DOTALL
        )
        if title_match:
            title_text = re.sub(r"\s+", " ", title_match.group(1)).strip()
            if _CHALLENGE_TITLE_PATTERNS.search(title_text):
                raise SourceUnavailableError(
                    f"Challenge page detected (title: {title_text!r})",
                    url=url,
                )

        # Suspiciously short response (< 500 characters) — likely an interstitial or empty shell.
        char_len = len(content.strip())
        if char_len < _MIN_CONTENT_CHARS:
            raise SourceUnavailableError(
                f"Response too short ({char_len} chars < {_MIN_CONTENT_CHARS}) — possible challenge or empty page",
                url=url,
            )

    @abstractmethod
    def scrape(self) -> list[ScrapedScholarship]:
        """Fetch and parse scholarships from the official source.

        Returns a list of normalized ScrapedScholarship objects.
        Must NOT access the database.
        """
        ...

    def parse_html(
        self,
        html: str,
        reference_time: datetime | None = None,
    ) -> list[ScrapedScholarship]:
        """Parse raw HTML into ScrapedScholarship objects.

        Separated from ``scrape()`` so tests can call this
        directly with fixture HTML and a deterministic ``reference_time``
        without network access or wall-clock dependence.
        """
        raise NotImplementedError(
            f"{self.__class__.__name__} does not implement parse_html"
        )
