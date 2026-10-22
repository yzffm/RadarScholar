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


def _mount_mock_transport(monkeypatch, handler):
    """Route httpx.get calls through an httpx.MockTransport handler."""
    transport = httpx.MockTransport(handler)

    def _get(url, **kwargs):
        headers = kwargs.get("headers")
        follow_redirects = kwargs.get("follow_redirects", True)
        timeout = kwargs.get("timeout")
        with httpx.Client(
            transport=transport,
            follow_redirects=follow_redirects,
            timeout=timeout,
        ) as client:
            return client.get(url, headers=headers)

    monkeypatch.setattr(httpx, "get", _get)


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


def test_mock_transport_202_with_2183_char_body_is_unavailable_without_retry(monkeypatch):
    calls: list[str] = []
    waf_body_2183 = "<script>" + ("a" * (2183 - 17)) + "</script>"
    assert len(waf_body_2183) == 2183

    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        calls.append(url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(
            202,
            text=waf_body_2183,
            headers={"server": "awselb/2.0", "x-amzn-waf-action": "challenge"},
        )

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match="HTTP 202"):
        scraper.fetch(
            "https://investor.cimbniaga.co.id/csr/scholarship.html",
            max_retries=2,
            backoff_seconds=0.0,
        )

    assert calls == [
        "https://investor.cimbniaga.co.id/robots.txt",
        "https://investor.cimbniaga.co.id/csr/scholarship.html",
    ]


@pytest.mark.parametrize("status_code", [201, 202, 203, 204, 206])
def test_non_200_2xx_statuses_are_unavailable_without_retry(monkeypatch, status_code):
    calls: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        calls.append(url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        body = "" if status_code == 204 else _valid_html()
        return httpx.Response(status_code, text=body)

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match=f"HTTP {status_code}"):
        scraper.fetch("https://example.org/scholarships", max_retries=2, backoff_seconds=0.0)

    assert calls == [
        "https://example.org/robots.txt",
        "https://example.org/scholarships",
    ]


def test_normal_200_passes_via_mock_transport(monkeypatch):
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(200, text=_valid_html(title="Beasiswa Resmi 2026"))

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    response = scraper.fetch("https://example.org/scholarships")
    assert response.status_code == 200


@pytest.mark.parametrize("status_code", [401, 403, 451])
def test_fetch_does_not_retry_on_401_403_451(monkeypatch, status_code):
    calls: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        calls.append(url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(status_code, text=_valid_html())

    _mount_mock_transport(monkeypatch, handler)

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
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(200, text=_valid_html(title=challenge_title))

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match="Challenge page detected"):
        scraper.fetch("https://example.org/scholarships")


def test_fetch_does_not_false_positive_when_keywords_appear_in_body(monkeypatch):
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(
            200,
            text=_valid_html(
                title="Beasiswa Resmi 2026",
                body_extra=" Note: access denied for late submissions; just a moment to read.",
            ),
        )

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    response = scraper.fetch("https://example.org/scholarships")
    assert response.status_code == 200


def test_fetch_rejects_response_shorter_than_500_chars(monkeypatch):
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(
            200,
            text="<html><head><title>Beasiswa</title></head><body>Short page</body></html>",
        )

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match="Response too short"):
        scraper.fetch("https://example.org/scholarships")


def test_fetch_logs_diagnostic_headers_only_when_present(monkeypatch, caplog):
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if url.endswith("/robots.txt"):
            # No server, x-amzn-waf-action, or cf-mitigated headers present
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(
            200,
            text=_valid_html(),
            headers={
                "server": "awselb/2.0",
                "x-amzn-waf-action": "challenge",
                "cf-mitigated": "challenge",
            },
        )

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with caplog.at_level(logging.INFO, logger="app.crawler.base"):
        scraper.fetch("https://example.org/scholarships")

    robots_logs = [r.message for r in caplog.records if "robots.txt" in r.message]
    page_logs = [r.message for r in caplog.records if "/scholarships:" in r.message]

    assert len(robots_logs) == 1
    assert "server=" not in robots_logs[0]
    assert "x-amzn-waf-action=" not in robots_logs[0]
    assert "cf-mitigated=" not in robots_logs[0]

    assert len(page_logs) == 1
    assert "server=awselb/2.0" in page_logs[0]
    assert "x-amzn-waf-action=challenge" in page_logs[0]
    assert "cf-mitigated=challenge" in page_logs[0]


def test_robots_txt_cached_per_run_and_enforces_disallow(monkeypatch):
    robots_calls = 0

    def handler(request: httpx.Request) -> httpx.Response:
        nonlocal robots_calls
        url = str(request.url)
        if url.endswith("/robots.txt"):
            robots_calls += 1
            return httpx.Response(
                200,
                text="User-agent: *\nDisallow: /private/\nAllow: /public/\n",
            )
        return httpx.Response(200, text=_valid_html())

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    resp = scraper.fetch("https://example.org/public/scholarship")
    assert resp.status_code == 200

    with pytest.raises(SourceUnavailableError, match="Disallowed by robots.txt"):
        scraper.fetch("https://example.org/private/secret")

    # robots.txt was only fetched once for example.org across both requests
    assert robots_calls == 1


@pytest.mark.parametrize("robots_status", [202, 204, 401, 403, 404, 500, 503])
def test_robots_txt_non_200_is_treated_as_unavailable(monkeypatch, robots_status):
    page_called = False

    def handler(request: httpx.Request) -> httpx.Response:
        nonlocal page_called
        url = str(request.url)
        if url.endswith("/robots.txt"):
            body = "" if robots_status == 204 else "non-200 robots response"
            return httpx.Response(robots_status, text=body)
        page_called = True
        return httpx.Response(200, text=_valid_html())

    _mount_mock_transport(monkeypatch, handler)

    scraper = DummyScraper()
    with pytest.raises(SourceUnavailableError, match=f"HTTP {robots_status}"):
        scraper.fetch("https://example.org/scholarships")

    assert page_called is False


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
    def handler(request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        host = urlsplit(url).netloc
        if url.endswith("/robots.txt"):
            return httpx.Response(200, text="User-agent: *\nAllow: /\n")
        return httpx.Response(
            200,
            text=f"<html><head><title>Portal {host}</title></head><body>Content</body></html>",
            headers={"server": "cloudflare", "cf-mitigated": "challenge"},
        )

    _mount_mock_transport(monkeypatch, handler)

    report = probe_url(
        key="test_src",
        provider_name="Test Provider",
        source_url="https://example.org/beasiswa",
        enabled=True,
    )
    formatted = format_reports([report])

    assert report.status == "200"
    assert report.server == "server=cloudflare cf-mitigated=challenge"
    assert report.title == "Portal example.org"
    assert report.robots_decision == "ALLOWED"
    assert "robots.txt-compliant" in formatted
    assert "[test_src] Test Provider" in formatted
