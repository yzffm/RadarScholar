from app.crawler.registry import get_enabled_sources, get_registry


def test_registry_only_enables_audited_crawlable_source():
    registry = get_registry()
    enabled = get_enabled_sources()

    assert set(enabled) == {
        "teladan",
        "pertamina_sobat_bumi",
        "bca_scholarship",
        "ugm_bulletin",
        "kse",
        "vdmi",
        "dataprint",
        "bank_indonesia_genbi",
        "ugm_ditmawa_index",
    }
    assert registry["teladan"].crawl_status == "ACTIVE"
    assert registry["teladan"].crawl_method == "HTTP_HTML"
    assert registry["pertamina_sobat_bumi"].crawl_status == "ACTIVE"
    assert registry["cimb_scholarship"].enabled is False
    assert registry["cimb_scholarship"].crawl_status == "WAF_BLOCKED"
    assert registry["cimb_scholarship"].crawl_method == "MANUAL_OFFICIAL"
    assert registry["bca_scholarship"].crawl_status == "ACTIVE"
    assert registry["ugm_bulletin"].crawl_status == "ACTIVE"
    assert registry["djarum"].crawl_status == "ANTI_BOT_BLOCKED"
    assert registry["lpdp"].crawl_status == "WAF_BLOCKED"
    assert registry["beasiswa_unggulan"].crawl_method == "MANUAL_OFFICIAL"
    assert registry["kip_kuliah"].crawl_method == "MANUAL_OFFICIAL"
    assert registry["baznas"].crawl_status == "MANUAL_ONLY"

    for wave1_key in (
        "kse",
        "vdmi",
        "dataprint",
        "bank_indonesia_genbi",
        "ugm_ditmawa_index",
    ):
        assert registry[wave1_key].enabled is True
        assert registry[wave1_key].crawl_status == "ACTIVE"
        assert registry[wave1_key].crawl_method == "HTTP_HTML"
        assert registry[wave1_key].scraper_factory is not None
