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
    scraper_factory: type | None  # Class reference, instantiated at run time
    enabled: bool = True
    crawl_status: str = "ACTIVE"
    crawl_method: str = "HTTP_HTML"


def _build_registry() -> dict[str, SourceEntry]:
    """Build the curated source registry.

    Imports are deferred to avoid circular-import issues
    and to keep the registry declarative.
    """
    from app.crawler.scrapers.bca import BcaScholarshipScraper
    from app.crawler.scrapers.cimb import CimbScholarshipScraper
    from app.crawler.scrapers.djarum import DjarumScraper
    from app.crawler.scrapers.lpdp import LpdpScraper
    from app.crawler.scrapers.pertamina import PertaminaSobatBumiScraper
    from app.crawler.scrapers.teladan import TeladanScraper
    from app.crawler.scrapers.ugm_bulletin import UgmScholarshipBulletinScraper

    return {
        "djarum": SourceEntry(
            provider_name="Djarum Beasiswa Plus",
            source_url="https://djarumbeasiswaplus.org/our-program/regulation-djarum-beasiswa-plus",
            scraper_factory=DjarumScraper,
            enabled=False,
            crawl_status="ANTI_BOT_BLOCKED",
        ),
        "lpdp": SourceEntry(
            provider_name="LPDP",
            source_url="https://lpdp.kemenkeu.go.id/beasiswa",
            scraper_factory=LpdpScraper,
            enabled=False,
            crawl_status="WAF_BLOCKED",
        ),
        "teladan": SourceEntry(
            provider_name="Tanoto Foundation TELADAN",
            source_url="https://www.tanotofoundation.org/initiative/teladan/",
            scraper_factory=TeladanScraper,
            enabled=True,
            crawl_status="ACTIVE",
        ),
        "pertamina_sobat_bumi": SourceEntry(
            provider_name="Pertamina Foundation Sobat Bumi",
            source_url="https://www.pertaminafoundation.org/",
            scraper_factory=PertaminaSobatBumiScraper,
            enabled=True,
            crawl_status="ACTIVE",
        ),
        "cimb_scholarship": SourceEntry(
            provider_name="CIMB Niaga Scholarship",
            source_url="https://investor.cimbniaga.co.id/csr/scholarship.html",
            scraper_factory=CimbScholarshipScraper,
            enabled=True,
            crawl_status="ACTIVE",
        ),
        "bca_scholarship": SourceEntry(
            provider_name="Beasiswa BCA PPBP/PPTI",
            source_url="https://karir.bca.co.id/beasiswa-bca",
            scraper_factory=BcaScholarshipScraper,
            enabled=True,
            crawl_status="ACTIVE",
        ),
        "ugm_bulletin": SourceEntry(
            provider_name="UGM Direktorat Kemahasiswaan Bulletin",
            source_url="https://ditmawa.ugm.ac.id/2026/09/pembukaan-pendaftaran-beasiswa-cendekia-baznas-bcb-kerja-sama-kampus-dalam-negeri-2026/",
            scraper_factory=UgmScholarshipBulletinScraper,
            enabled=True,
            crawl_status="ACTIVE",
        ),
        "beasiswa_unggulan": SourceEntry(
            provider_name="Beasiswa Unggulan Kemendikbudristek",
            source_url="https://beasiswaunggulan.kemdikbud.go.id/",
            scraper_factory=None,
            enabled=False,
            crawl_status="NEEDS_REVIEW",
            crawl_method="MANUAL_OFFICIAL",
        ),
        "kip_kuliah": SourceEntry(
            provider_name="KIP Kuliah",
            source_url="https://kip-kuliah.kemdikbud.go.id/",
            scraper_factory=None,
            enabled=False,
            crawl_status="NEEDS_REVIEW",
            crawl_method="MANUAL_OFFICIAL",
        ),
        "bank_indonesia_genbi": SourceEntry(
            provider_name="Bank Indonesia / GenBI",
            source_url="https://www.bi.go.id/id/edukasi/",
            scraper_factory=None,
            enabled=False,
            crawl_status="MANUAL_ONLY",
            crawl_method="MANUAL_OFFICIAL",
        ),
        "baznas": SourceEntry(
            provider_name="Beasiswa BAZNAS",
            source_url="https://beasiswa.baznas.go.id/program",
            scraper_factory=None,
            enabled=False,
            crawl_status="MANUAL_ONLY",
            crawl_method="MANUAL_OFFICIAL",
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
    if entry.scraper_factory is None:
        raise ValueError(f"Source '{key}' has no crawler adapter")
    return entry.scraper_factory()
