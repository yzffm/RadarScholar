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

        # Exit code: 0 if all succeeded, 1 if all failed, 2 if partial
        if result.sources_failed == 0:
            return 0
        elif result.sources_succeeded == 0:
            logger.error("All sources failed!")
            return 1
        else:
            logger.warning("Partial failure: %d/%d sources failed",
                           result.sources_failed, result.sources_attempted)
            return 2

    except Exception as exc:
        logger.error("Crawler pipeline failed: %s", exc, exc_info=True)
        return 1
    finally:
        session.close()
        engine.dispose()


if __name__ == "__main__":
    sys.exit(main())
