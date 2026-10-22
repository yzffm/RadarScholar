"""Diagnostic probe script for curated scholarship sources.

For every URL in the curated source registry, fetches and prints:
- HTTP status code
- Response byte count
- Server header
- Final URL after redirects
- HTML <title>
- robots.txt compliance decision (robots.txt-compliant check)

Usage:
    python -m scripts.probe_sources
    python -m scripts.probe_sources --source cimb_scholarship --source djarum
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass

import httpx

from app.crawler.base import BaseScraper, SourceUnavailableError
from app.crawler.registry import get_registry


@dataclass
class ProbeReport:
    """Diagnostic result for a single probed URL."""

    key: str
    provider_name: str
    enabled: bool
    source_url: str
    robots_decision: str
    status: str
    byte_count: int
    server: str
    final_url: str
    title: str


def _extract_title(html: str) -> str:
    """Extract and normalize the first <title> tag from HTML."""
    match = re.search(r"<title[^>]*>(.*?)</title>", html, re.IGNORECASE | re.DOTALL)
    if not match:
        return "-"
    title = re.sub(r"\s+", " ", match.group(1)).strip()
    return title[:120] if title else "-"


def _evaluate_robots(url: str) -> str:
    """Return human-readable robots.txt decision for ``url``."""
    try:
        BaseScraper.check_robots_txt(url)
        return "ALLOWED"
    except SourceUnavailableError as exc:
        msg = str(exc)
        if "Disallowed by robots.txt" in msg:
            return "DISALLOWED"
        return f"UNAVAILABLE ({msg})"
    except Exception as exc:
        return f"ERROR ({exc})"


def probe_url(
    key: str,
    provider_name: str,
    source_url: str,
    *,
    enabled: bool = False,
) -> ProbeReport:
    """Probe a single source URL and return a structured report."""
    robots_decision = _evaluate_robots(source_url)
    BaseScraper._wait_for_host_slot(source_url)

    try:
        response = httpx.get(
            source_url,
            timeout=httpx.Timeout(connect=10.0, read=30.0, write=10.0, pool=10.0),
            follow_redirects=True,
            headers=BaseScraper._DEFAULT_HEADERS,
        )
        status = str(response.status_code)
        byte_count = len(response.content)
        server = response.headers.get("server", "-")
        final_url = str(response.url)
        title = _extract_title(response.text)
    except httpx.HTTPError as exc:
        status = f"ERROR ({exc.__class__.__name__}: {exc})"
        byte_count = 0
        server = "-"
        final_url = "-"
        title = "-"

    return ProbeReport(
        key=key,
        provider_name=provider_name,
        enabled=enabled,
        source_url=source_url,
        robots_decision=robots_decision,
        status=status,
        byte_count=byte_count,
        server=server,
        final_url=final_url,
        title=title,
    )


def format_reports(reports: list[ProbeReport]) -> str:
    """Format probe reports into readable blocks for GitHub Actions logs."""
    lines = [
        "========================================================================",
        "RadarScholar Curated Source Probe (robots.txt-compliant diagnostic)",
        "========================================================================",
    ]
    for report in reports:
        lines.extend(
            [
                f"\n[{report.key}] {report.provider_name} (enabled={report.enabled})",
                f"  source_url : {report.source_url}",
                f"  final_url  : {report.final_url}",
                f"  status     : {report.status}",
                f"  bytes      : {report.byte_count}",
                f"  server     : {report.server}",
                f"  title      : {report.title}",
                f"  robots     : {report.robots_decision}",
            ]
        )
    lines.append("\n========================================================================")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    """CLI entry point for probing registry sources."""
    parser = argparse.ArgumentParser(
        prog="probe-sources",
        description="Probe curated scholarship sources for reachability and robots.txt compliance.",
    )
    parser.add_argument(
        "--source",
        action="append",
        default=None,
        help="Optional source key(s) from the registry to probe. Defaults to all registry sources.",
    )
    args = parser.parse_args(argv)

    BaseScraper.reset_runtime_state()
    registry = get_registry()
    if args.source:
        selected = {k: v for k, v in registry.items() if k in args.source}
    else:
        selected = registry

    reports: list[ProbeReport] = []
    for key, entry in selected.items():
        reports.append(
            probe_url(
                key=key,
                provider_name=entry.provider_name,
                source_url=entry.source_url,
                enabled=entry.enabled,
            )
        )

    print(format_reports(reports))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

