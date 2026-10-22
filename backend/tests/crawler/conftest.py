import pytest

from app.crawler.base import BaseScraper


@pytest.fixture(autouse=True)
def _zero_host_delay_and_clean_cache(monkeypatch):
    """Set polite per-host delay to 0s in tests and reset runtime caches."""
    assert BaseScraper.min_host_interval_seconds == 1.0
    BaseScraper.reset_runtime_state()
    monkeypatch.setattr(BaseScraper, "min_host_interval_seconds", 0.0)
    yield
    BaseScraper.reset_runtime_state()

