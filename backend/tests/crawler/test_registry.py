from app.crawler.registry import get_enabled_sources, get_registry


def test_registry_only_enables_audited_crawlable_source():
    registry = get_registry()
    enabled = get_enabled_sources()

    assert set(enabled) == {
        "teladan",
        "pertamina_sobat_bumi",
        "cimb_scholarship",
        "bca_scholarship",
        "ugm_bulletin",
    }
    assert registry["teladan"].crawl_status == "ACTIVE"
    assert registry["teladan"].crawl_method == "HTTP_HTML"
    assert registry["pertamina_sobat_bumi"].crawl_status == "ACTIVE"
    assert registry["cimb_scholarship"].crawl_status == "ACTIVE"
    assert registry["bca_scholarship"].crawl_status == "ACTIVE"
    assert registry["ugm_bulletin"].crawl_status == "ACTIVE"
    assert registry["djarum"].crawl_status == "ANTI_BOT_BLOCKED"
    assert registry["lpdp"].crawl_status == "WAF_BLOCKED"
    assert registry["beasiswa_unggulan"].crawl_method == "MANUAL_OFFICIAL"
    assert registry["kip_kuliah"].crawl_method == "MANUAL_OFFICIAL"
    assert registry["bank_indonesia_genbi"].crawl_status == "MANUAL_ONLY"
    assert registry["baznas"].crawl_status == "MANUAL_ONLY"
