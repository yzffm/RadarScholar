"""Unit tests for Fase D Wave 1 scrapers (D1, D2, D3)."""

from datetime import datetime
from pathlib import Path
from types import SimpleNamespace

import pytest

from app.crawler.date_utils import parse_indonesian_date
from app.crawler.scrapers.dataprint import DataPrintScraper
from app.crawler.scrapers.genbi import BankIndonesiaGenbiScraper
from app.crawler.scrapers.kse import KseScraper
from app.crawler.scrapers.ugm_ditmawa_index import UgmDitmawaIndexScraper
from app.crawler.scrapers.vdmi import VdmiScraper

FIXTURES = Path(__file__).parent / "fixtures"
FIXED_REF = datetime(2026, 10, 23, 0, 0, 0)


@pytest.mark.parametrize(
    "fixture_name",
    [
        "kse.html",
        "vdmi.html",
        "dataprint.html",
        "bank_indonesia_genbi.html",
        "ugm_ditmawa_index.html",
    ],
)
def test_wave1_fixtures_are_real_snapshots_with_fetch_metadata(fixture_name: str):
    first_line = (FIXTURES / fixture_name).read_text(encoding="utf-8").splitlines()[0]
    assert first_line.startswith("<!-- Real HTML snapshot fetched from https://")
    assert "on 2026-10-23" in first_line


def test_kse_scraper_parses_real_snapshot():
    html = (FIXTURES / "kse.html").read_text(encoding="utf-8")
    items = KseScraper().parse_html(html, reference_time=FIXED_REF)

    assert len(items) == 1
    item = items[0]
    assert item.title == "Beasiswa Karya Salemba Empat (KSE)"
    assert item.provider_name == "Karya Salemba Empat (KSE)"
    assert item.source_url == "https://kse.or.id/"
    assert item.application_url == "https://kse.or.id/"
    assert item.deadline is None
    assert item.is_active is False
    assert item.has_contextual_dates is False
    assert item.is_live_verified is True
    assert [(r.requirement_type, r.operator, r.value) for r in item.requirements] == [
        ("DEGREE_LEVEL", "EQ", {"level": "S1"})
    ]
    assert {b.benefit_type for b in item.benefits} == {
        "TUITION_FEE",
        "LEADERSHIP_DEVELOPMENT",
        "TRAINING",
    }


def test_kse_scraper_rejects_unrecognized_html():
    with pytest.raises(ValueError, match="KSE scholarship marker"):
        KseScraper().parse_html("<html><body>Unrelated page</body></html>")


def test_vdmi_scraper_parses_real_snapshot_without_fabricating_requirements():
    html = (FIXTURES / "vdmi.html").read_text(encoding="utf-8")
    items = VdmiScraper().parse_html(html, reference_time=FIXED_REF)

    assert len(items) == 1
    item = items[0]
    assert item.title == "Beasiswa Van Deventer-Maas Indonesia (VDMI)"
    assert item.provider_name == "Van Deventer-Maas Indonesia (VDMI)"
    assert item.source_url == "https://vandeventermaas.or.id/"
    assert item.application_url == "https://vandeventermaas.or.id/"
    assert item.deadline is None
    assert item.is_active is False
    assert item.has_contextual_dates is False
    assert item.requirements == []
    assert [b.benefit_type for b in item.benefits] == ["EDUCATIONAL_SUPPORT"]


def test_vdmi_scraper_rejects_unrecognized_html():
    with pytest.raises(ValueError, match="VDMI scholarship marker"):
        VdmiScraper().parse_html("<html><body>Unrelated page</body></html>")


def test_dataprint_scraper_extracts_active_periode_4_deadline_and_stated_benefit():
    html = (FIXTURES / "dataprint.html").read_text(encoding="utf-8")
    items = DataPrintScraper().parse_html(html, reference_time=FIXED_REF)

    assert len(items) == 1
    item = items[0]
    assert item.title == "Beasiswa DataPrint"
    assert item.provider_name == "Beasiswa DataPrint"
    assert item.deadline == datetime(2026, 11, 30, 16, 59, 59)
    assert item.is_active is True
    assert item.has_contextual_dates is True
    assert item.requirements == []
    assert len(item.benefits) == 1
    assert item.benefits[0].benefit_type == "EDUCATIONAL_SUPPORT"
    assert "Rp 500 ribu/penerima beasiswa" in item.benefits[0].description


def test_dataprint_scraper_marks_expired_after_periode_4_deadline():
    html = (FIXTURES / "dataprint.html").read_text(encoding="utf-8")
    items = DataPrintScraper().parse_html(
        html,
        reference_time=datetime(2026, 12, 1, 0, 0, 0),
    )

    assert len(items) == 1
    item = items[0]
    assert item.deadline is None
    assert item.is_active is False
    assert item.has_contextual_dates is True


def test_genbi_scraper_parses_real_snapshot_without_false_deadline_from_infographics():
    html = (FIXTURES / "bank_indonesia_genbi.html").read_text(encoding="utf-8")
    items = BankIndonesiaGenbiScraper().parse_html(html, reference_time=FIXED_REF)

    assert len(items) == 1
    item = items[0]
    assert item.title == "Beasiswa Bank Indonesia (GenBI)"
    assert item.provider_name == "Bank Indonesia / GenBI"
    assert item.source_url == "https://www.bi.go.id/id/edukasi/"
    assert item.application_url == "https://www.bi.go.id/id/edukasi/"
    assert item.deadline is None
    assert item.is_active is False
    assert item.has_contextual_dates is False
    assert item.requirements == []
    assert item.benefits == []


def test_ugm_ditmawa_index_parses_real_snapshot_concisely():
    html = (FIXTURES / "ugm_ditmawa_index.html").read_text(encoding="utf-8")
    items = UgmDitmawaIndexScraper().parse_html(html, reference_time=FIXED_REF)

    assert len(items) == 4
    expected_titles = [
        "[UPDATE] BEASISWA ASA NUSANTARA DARI DANANTARA INDONESIA TRUST Tahun Akademik 2026/2027",
        "BSI SCHOLARSHIP TALENTA 2026",
        "[Update] BEASISWA PT LAUTAN LUAS Tbk",
        "Beasiswa Afirmasi Pendidikan Tinggi bagi Penyandang Disabilitas Angkatan tahun 2026",
    ]
    assert [item.title for item in items] == expected_titles

    for item in items:
        assert item.provider_name == "UGM Direktorat Kemahasiswaan - Info Beasiswa"
        assert item.source_url == "https://ditmawa.ugm.ac.id/category/info-beasiswa/"
        assert item.application_url.startswith("https://ditmawa.ugm.ac.id/2026/")
        assert not item.application_url.endswith("/")
        assert item.deadline is None
        assert item.is_active is True
        assert item.has_contextual_dates is False
        assert item.requirements == []
        assert item.benefits == []
        # D3: Do not copy long article text
        assert len(item.summary) <= 220
        assert len(item.description) <= 320
        assert "Merujuk surat dari" not in item.summary
        assert "Merujuk surat dari" not in item.description


def test_ugm_ditmawa_index_respects_max_posts_and_90_day_age_cutoff():
    html = (FIXTURES / "ugm_ditmawa_index.html").read_text(encoding="utf-8")

    # Max posts cap = 2
    capped = UgmDitmawaIndexScraper(max_posts=2).parse_html(
        html,
        reference_time=FIXED_REF,
    )
    assert len(capped) == 2

    # At 2027-01-04 (cutoff = 2026-10-06):
    # - 9 Oct 2026 (included)
    # - 8 Oct 2026 (included)
    # - 6 Oct 2026 (included, exactly 90 days)
    # - 28 Sep 2026 (excluded, >90 days old)
    filtered = UgmDitmawaIndexScraper().parse_html(
        html,
        reference_time=datetime(2027, 1, 4, 0, 0, 0),
    )
    assert len(filtered) == 3
    assert all("Disabilitas" not in item.title for item in filtered)

    # At 2027-02-01, all 4 posts are older than 90 days -> returns empty list
    expired_all = UgmDitmawaIndexScraper().parse_html(
        html,
        reference_time=datetime(2027, 2, 1, 0, 0, 0),
    )
    assert expired_all == []


def test_ugm_ditmawa_index_deduplicates_normalized_urls_and_fetches_first_page_only(
    monkeypatch,
):
    duplicate_html = """
    <html><body>
      <article class="post">
        <div class="post-title">
          <h3><a href="https://ditmawa.ugm.ac.id/2026/10/beasiswa-uji/">Beasiswa Uji Satu</a></h3>
        </div>
        <div class="post-meta"><span class="post-date">Jumat, 9 Oktober 2026</span></div>
      </article>
      <article class="post">
        <div class="post-title">
          <h3><a href="https://ditmawa.ugm.ac.id/2026/10/beasiswa-uji">Beasiswa Uji Duplikat</a></h3>
        </div>
        <div class="post-meta"><span class="post-date">Jumat, 9 Oktober 2026</span></div>
      </article>
      <ul class="pagination">
        <li><a href="https://ditmawa.ugm.ac.id/category/info-beasiswa/page/2/">2</a></li>
      </ul>
    </body></html>
    """
    fetched_urls: list[str] = []
    scraper = UgmDitmawaIndexScraper()

    def _fake_fetch(url: str, **kwargs):
        fetched_urls.append(url)
        return SimpleNamespace(text=duplicate_html)

    monkeypatch.setattr(scraper, "fetch", _fake_fetch)
    items = scraper.scrape()

    assert fetched_urls == ["https://ditmawa.ugm.ac.id/category/info-beasiswa/"]
    assert len(items) == 1
    assert items[0].application_url == "https://ditmawa.ugm.ac.id/2026/10/beasiswa-uji"


def test_parse_indonesian_date_helper():
    assert parse_indonesian_date("Kamis, 8 Oktober 2026") == datetime(2026, 10, 8, 16, 59, 59)
    assert parse_indonesian_date("No date here") is None

