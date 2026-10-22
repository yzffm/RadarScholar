"""CLI entry point for the RadarScholar curated crawler.

Usage:
    python -m app.crawler.main
    python -m app.crawler.main --source djarum
    python -m app.crawler.main --source lpdp --dry-run
"""

import argparse
import logging
import sys

from sqlalchemy.orm import Session

from app.crawler.pipeline import CrawlerPipeline
from app.database.session import get_engine


def _setup_logging(verbose: bool = False) -> None:
    """Configure logging for the crawler CLI."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    # Suppress noisy libraries
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)


def main() -> int:
    """Run the curated crawler pipeline."""
    parser = argparse.ArgumentParser(
        prog="radarscholar-crawler",
        description="RadarScholar Curated Scholarship Crawler",
    )
    parser.add_argument(
        "--source",
        action="append",
        default=None,
        help="Restrict crawl to specific source(s). Can be repeated. "
        "Example: --source djarum --source lpdp",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        default=False,
        help="Parse and validate but do NOT write to the database.",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        default=False,
        help="Enable debug-level logging.",
    )

    args = parser.parse_args()
    _setup_logging(verbose=args.verbose)

    logger = logging.getLogger("app.crawler")
    logger.info("RadarScholar Crawler starting…")

    if args.dry_run:
        logger.info("DRY RUN mode — no database changes will be committed")

    # Create database session
    engine = get_engine()
    session = Session(bind=engine, autocommit=False, autoflush=False)

    try:
        pipeline = CrawlerPipeline(db=session, dry_run=args.dry_run)
        result = pipeline.run(source_filter=args.source)

        # Print summary
        print(result.summary())

        # Emit GitHub Actions warnings for any unavailable sources
        unavailable_count = getattr(result, "sources_unavailable", 0)
        source_results = getattr(result, "source_results", []) or []
        unavailable_items = [
            sr for sr in source_results if getattr(sr, "unavailable", False)
        ]
        if unavailable_items:
            for sr in unavailable_items:
                print(
                    f"::warning::Source '{sr.source_key}' ({sr.provider_name}) "
                    f"is unavailable: {sr.error or 'unreachable'}"
                )
        elif unavailable_count > 0:
            print(
                f"::warning::{unavailable_count}/{result.sources_attempted} "
                "source(s) unavailable during crawl"
            )

        # Exit code rules (B3):
        # - all sources failed or unavailable -> 1
        # - any parser/DB failure (with at least 1 success) -> 2
        # - all succeeded or only unavailable -> 0
        if result.sources_attempted > 0 and result.sources_succeeded == 0:
            logger.error("All sources failed or were unavailable!")
            return 1
        elif result.sources_failed > 0:
            logger.warning(
                "Partial failure: %d/%d sources failed",
                result.sources_failed,
                result.sources_attempted,
            )
            return 2
        else:
            return 0

    except Exception as exc:
        logger.error("Crawler pipeline failed: %s", exc, exc_info=True)
        return 1
    finally:
        session.close()
        engine.dispose()


if __name__ == "__main__":
    sys.exit(main())
