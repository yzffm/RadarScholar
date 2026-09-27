import sys
from types import SimpleNamespace
from unittest.mock import Mock

from app.crawler import main as crawler_main


def run_cli(monkeypatch, pipeline_result):
    engine = Mock()
    session = Mock()
    pipeline = Mock()
    pipeline.run.return_value = pipeline_result

    monkeypatch.setattr(sys, "argv", ["radarscholar-crawler", "--dry-run"])
    monkeypatch.setattr(crawler_main, "get_engine", lambda: engine)
    monkeypatch.setattr(crawler_main, "Session", lambda **kwargs: session)
    monkeypatch.setattr(crawler_main, "CrawlerPipeline", lambda **kwargs: pipeline)

    return crawler_main.main(), engine, session, pipeline


def result(attempted, succeeded, failed):
    return SimpleNamespace(
        sources_attempted=attempted,
        sources_succeeded=succeeded,
        sources_failed=failed,
        summary=lambda: "summary",
    )


def test_cli_returns_zero_for_success_and_cleans_up(monkeypatch):
    exit_code, engine, session, pipeline = run_cli(monkeypatch, result(1, 1, 0))

    assert exit_code == 0
    pipeline.run.assert_called_once_with(source_filter=None)
    session.close.assert_called_once()
    engine.dispose.assert_called_once()


def test_cli_returns_one_when_all_sources_fail(monkeypatch):
    exit_code, engine, session, _ = run_cli(monkeypatch, result(1, 0, 1))

    assert exit_code == 1
    session.close.assert_called_once()
    engine.dispose.assert_called_once()


def test_cli_returns_two_for_partial_failure(monkeypatch):
    exit_code, engine, session, _ = run_cli(monkeypatch, result(2, 1, 1))

    assert exit_code == 2
    session.close.assert_called_once()
    engine.dispose.assert_called_once()
