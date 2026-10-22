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


def result(attempted, succeeded, failed, unavailable=0, source_results=None):
    return SimpleNamespace(
        sources_attempted=attempted,
        sources_succeeded=succeeded,
        sources_failed=failed,
        sources_unavailable=unavailable,
        source_results=source_results or [],
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


def test_cli_returns_one_when_all_sources_unavailable(monkeypatch):
    exit_code, engine, session, _ = run_cli(monkeypatch, result(2, 0, 0, unavailable=2))

    assert exit_code == 1
    session.close.assert_called_once()
    engine.dispose.assert_called_once()


def test_cli_returns_two_for_partial_failure(monkeypatch):
    exit_code, engine, session, _ = run_cli(monkeypatch, result(2, 1, 1))

    assert exit_code == 2
    session.close.assert_called_once()
    engine.dispose.assert_called_once()


def test_cli_returns_zero_with_github_warning_when_only_unavailable(monkeypatch, capsys):
    unavailable_sr = SimpleNamespace(
        source_key="cimb_scholarship",
        provider_name="CIMB Niaga Scholarship",
        unavailable=True,
        error="HTTP 403 — source is blocking access",
    )
    exit_code, engine, session, _ = run_cli(
        monkeypatch,
        result(2, 1, 0, unavailable=1, source_results=[unavailable_sr]),
    )

    captured = capsys.readouterr()
    assert exit_code == 0
    assert "::warning::" in captured.out
    assert "cimb_scholarship" in captured.out
    session.close.assert_called_once()
    engine.dispose.assert_called_once()
