"""Unit tests for Fase B crawler resilience (B1, B4, B5, B8)."""

import logging
from urllib.parse import urlsplit

import httpx
import pytest
from scripts.probe_sources import format_reports, probe_url

from app.crawler.base import BaseScraper, SourceUnavailableError
from app.crawler.scrapers.djarum import DjarumScraper
from app.crawler.scrapers.lpdp import LpdpScraper


class DummyScraper(BaseScraper):
    provider_name = "Dummy Provider"
    source_url = "https://example.org/scholarships"

    def scrape(self):
        return []


def _make_response(
    url: str,
    status_code: int = 200,
    text: str = "",
    headers: dict[str, str] | None = None,
) -> httpx.Response:
    req = httpx.Request("GET", url)
    hdrs = {"server": "cloudflare", **(headers or {})}
    return httpx.Response(status_code=status_code, text=text, headers=hdrs, request=req)


def _valid_html(title: str = "Official Scholarship Page", body_extra: str = "") -> str:
    filler = "Informasi resmi pendaftaran beasiswa tahun akademik berjalan. " * 12
    return f"<html><head><title>{title}</title></head><body><p>{filler}{body_extra}</p></body></html>"


def test_source_unavailable_error_is_httpx_http_error_subclass():
    err = SourceUnavailableError("blocked", url="https://example.org")
    assert isinstance(err, httpx.HTTPError)
    assert err.url == "https://example.org"


def test_djarum_and_lpdp_fall_back_on_source_unavailable_error(monkeypatch):
    def _raise_unavailable(*args, **kwargs):
        raise SourceUnavailableError("HTTP 403 — source is blocking access", url="https://example.org")

    djarum = DjarumScraper()
    lpdp = LpdpScraper()
    monkeypatch.setattr(djarum, "fetch", _raise_unavailable)
    monkeypatch.setattr(lpdp, "fetch", _raise_unavailable)

    djarum_items = djarum.scrape()
    lpdp_items = lpdp.scrape()

    assert len(djarum_items) == 1
    assert djarum_items[0].is_live_verified is False
    assert len(lpdp_items) == 1
    assert lpdp_items[0].is_live_verified is False


@pytest.mark.parametrize("status_code", [401, 403, 451])
def test_fetch_does_not_retry_on_401_403_451(monkeypatch, status_code):
    calls: list[str] = []

    def fake_get(url, **kwargs):
        calls.append(url)
        if url.endswith("/robots.txt"):
            return _make_response(url, 200, "User-agent: *\nAllow: /\n")
        return _make_response(url, status_code, _valid_html())

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match=f"HTTP {status_code}"):
        scraper.fetch("https://example.org/scholarships", max_retries=2, backoff_seconds=0.0)

    # Exactly 1 robots.txt call + 1 target URL call (no retries)
    assert calls == [
        "https://example.org/robots.txt",
        "https://example.org/scholarships",
    ]


@pytest.mark.parametrize(
    "challenge_title",
    [
        "Just a moment...",
        "Attention Required! | Cloudflare",
        "Access Denied",
        "Verify you are human",
    ],
)
def test_fetch_detects_challenge_from_title_only(monkeypatch, challenge_title):
    def fake_get(url, **kwargs):
        if url.endswith("/robots.txt"):
            return _make_response(url, 200, "User-agent: *\nAllow: /\n")
        return _make_response(url, 200, _valid_html(title=challenge_title))

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match="Challenge page detected"):
        scraper.fetch("https://example.org/scholarships")


def test_fetch_does_not_false_positive_when_keywords_appear_in_body(monkeypatch):
    def fake_get(url, **kwargs):
        if url.endswith("/robots.txt"):
            return _make_response(url, 200, "User-agent: *\nAllow: /\n")
        return _make_response(
            url,
            200,
            _valid_html(
                title="Beasiswa Resmi 2026",
                body_extra=" Note: access denied for late submissions; just a moment to read.",
            ),
        )

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    response = scraper.fetch("https://example.org/scholarships")
    assert response.status_code == 200


def test_fetch_rejects_response_shorter_than_500_chars(monkeypatch):
    def fake_get(url, **kwargs):
        if url.endswith("/robots.txt"):
            return _make_response(url, 200, "User-agent: *\nAllow: /\n")
        return _make_response(
            url,
            200,
            "<html><head><title>Beasiswa</title></head><body>Short page</body></html>",
        )

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match="Response too short"):
        scraper.fetch("https://example.org/scholarships")


def test_fetch_logs_status_size_final_url_and_server(monkeypatch, caplog):
    def fake_get(url, **kwargs):
        if url.endswith("/robots.txt"):
            return _make_response(url, 404, "Not Found", headers={"server": "nginx"})
        return _make_response(
            "https://example.org/redirected-scholarships",
            200,
            _valid_html(),
            headers={"server": "Apache/2.4"},
        )

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    with caplog.at_level(logging.INFO, logger="app.crawler.base"):
        scraper.fetch("https://example.org/scholarships")

    assert any(
        "status=200" in rec.message
        and "final_url=https://example.org/redirected-scholarships" in rec.message
        and "server=Apache/2.4" in rec.message
        for rec in caplog.records
    )


def test_robots_txt_cached_per_run_and_enforces_disallow(monkeypatch):
    robots_calls = 0

    def fake_get(url, **kwargs):
        nonlocal robots_calls
        if url.endswith("/robots.txt"):
            robots_calls += 1
            return _make_response(
                url,
                200,
                "User-agent: *\nDisallow: /private/\nAllow: /public/\n",
            )
        return _make_response(url, 200, _valid_html())

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    resp = scraper.fetch("https://example.org/public/scholarship")
    assert resp.status_code == 200

    with pytest.raises(SourceUnavailableError, match="Disallowed by robots.txt"):
        scraper.fetch("https://example.org/private/secret")

    # robots.txt was only fetched once for example.org across both requests
    assert robots_calls == 1


@pytest.mark.parametrize("robots_status", [401, 403, 500, 503])
def test_robots_txt_conservative_error_on_401_403_5xx(monkeypatch, robots_status):
    def fake_get(url, **kwargs):
        if url.endswith("/robots.txt"):
            return _make_response(url, robots_status, "error")
        return _make_response(url, 200, _valid_html())

    monkeypatch.setattr(httpx, "get", fake_get)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match=f"HTTP {robots_status}"):
        scraper.fetch("https://example.org/scholarships")


def test_polite_delay_is_per_host_not_across_different_hosts(monkeypatch):
    # Verify test fixture sets 0.0s by default while production default (checked in conftest) is 1.0s
    assert BaseScraper.min_host_interval_seconds == 0.0

    monkeypatch.setattr(BaseScraper, "min_host_interval_seconds", 1.0)
    fake_clock = [100.0]
    sleeps: list[float] = []

    def fake_monotonic():
        return fake_clock[0]

    def fake_sleep(seconds: float):
        sleeps.append(round(seconds, 3))
        fake_clock[0] += seconds

    monkeypatch.setattr("app.crawler.base.time.monotonic", fake_monotonic)
    monkeypatch.setattr("app.crawler.base.time.sleep", fake_sleep)

    # First request to host A -> no sleep
    BaseScraper._wait_for_host_slot("https://host-a.example.org/page1")
    assert sleeps == []

    # Advance 0.3s and request host B -> different host, no sleep!
    fake_clock[0] += 0.3
    BaseScraper._wait_for_host_slot("https://host-b.example.org/page1")
    assert sleeps == []

    # Advance 0.1s (total 0.4s since host A) and request host A again -> sleeps 0.6s!
    fake_clock[0] += 0.1
    BaseScraper._wait_for_host_slot("https://host-a.example.org/page2")
    assert sleeps == [0.6]


def test_probe_sources_formats_report(monkeypatch):
    def fake_get(url, **kwargs):
        host = urlsplit(url).netloc
        if url.endswith("/robots.txt"):
            return _make_response(url, 200, "User-agent: *\nAllow: /\n")
        return _make_response(
            url,
            200,
            f"<html><head><title>Portal {host}</title></head><body>Content</body></html>",
            headers={"server": "cloudflare"},
        )

    monkeypatch.setattr(httpx, "get", fake_get)

    report = probe_url(
        key="test_src",
        provider_name="Test Provider",
        source_url="https://example.org/beasiswa",
        enabled=True,
    )
    formatted = format_reports([report])

    assert report.status == "200"
    assert report.server == "cloudflare"
    assert report.title == "Portal example.org"
    assert report.robots_decision == "ALLOWED"
    assert "robots.txt-compliant" in formatted
    assert "[test_src] Test Provider" in formatted

