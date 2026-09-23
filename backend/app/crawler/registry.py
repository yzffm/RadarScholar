"""Curated source registry for RadarScholar crawler.

The registry is the allowlist.  Only sources explicitly listed here
may be crawled.  Do NOT dynamically discover scrapers from the filesystem.

Each entry maps a human-readable key to:
- A scraper class
- Whether the source is currently enabled
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.crawler.base import BaseScraper

logger = logging.getLogger(__name__)


@dataclass
class SourceEntry:
    """Registry entry for a curated scholarship source."""

    provider_name: str
    source_url: str
    scraper_factory: type  # Class reference, instantiated at run time
    enabled: bool = True


def _build_registry() -> dict[str, SourceEntry]:
    """Build the curated source registry.

    Imports are deferred to avoid circular-import issues
    and to keep the registry declarative.
    """
    from app.crawler.scrapers.djarum import DjarumScraper
    from app.crawler.scrapers.lpdp import LpdpScraper

    return {
        "djarum": SourceEntry(
            provider_name="Djarum Beasiswa Plus",
            source_url="https://djarumbeasiswaplus.org/our-program/regulation-djarum-beasiswa-plus",
            scraper_factory=DjarumScraper,
            enabled=True,
        ),
        "lpdp": SourceEntry(
            provider_name="LPDP",
            source_url="https://lpdp.kemenkeu.go.id/beasiswa",
            scraper_factory=LpdpScraper,
            enabled=True,
        ),
    }


def get_registry() -> dict[str, SourceEntry]:
    """Return the curated source registry."""
    return _build_registry()


def get_enabled_sources() -> dict[str, SourceEntry]:
    """Return only enabled sources from the registry."""
    return {k: v for k, v in get_registry().items() if v.enabled}


def get_scraper(key: str) -> BaseScraper:
    """Instantiate and return a scraper for the given source key.

    Raises KeyError if the source is not registered.
    Raises ValueError if the source is disabled.
    """
    registry = get_registry()
    if key not in registry:
        raise KeyError(f"Source '{key}' is not in the curated registry")
    entry = registry[key]
    if not entry.enabled:
        raise ValueError(f"Source '{key}' is disabled")
    return entry.scraper_factory()
