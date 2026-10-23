"""Inspect and clean up production scholarship data (SEED rows, fictitious deadlines,
duplicate BCA rows, and inconsistent active flags when deadline is null).

By default, runs in ``--dry-run`` mode and does NOT commit any changes unless
``--apply`` is explicitly provided.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from datetime import date

from sqlalchemy.orm import Session

from app.applications.models import Application, SavedScholarship
from app.database.session import get_db
from app.scholarships.models import Scholarship, ScholarshipSource
from app.users.models import UserProfile  # noqa: F401

KNOWN_FICTITIOUS_SEED_DATES: frozenset[date] = frozenset(
    {
        date(2027, 5, 30),  # Legacy seed_scholarships.py Djarum Beasiswa Plus
        date(2027, 9, 15),  # Legacy seed_scholarships.py Beasiswa BCA
    }
)

CANONICAL_BCA_TITLE = "Beasiswa BCA PPBP/PPTI"
LEGACY_BCA_TITLES = frozenset({"Beasiswa BCA"})
LEGACY_BCA_PROVIDERS = frozenset({"Bank Central Asia"})


@dataclass
class CleanupReport:
    seed_rows: list[str] = field(default_factory=list)
    unverified_rows: list[str] = field(default_factory=list)
    fictitious_deadline_rows: list[str] = field(default_factory=list)
    duplicate_bca_rows: list[str] = field(default_factory=list)
    null_deadline_active_rows: list[str] = field(default_factory=list)
    reassigned_saved_count: int = 0
    reassigned_application_count: int = 0
    deleted_scholarship_ids: list[str] = field(default_factory=list)
    deleted_source_ids: list[str] = field(default_factory=list)
    cleared_deadline_ids: list[str] = field(default_factory=list)
    deactivated_null_deadline_ids: list[str] = field(default_factory=list)
    applied: bool = False


def _is_fictitious_deadline(scholarship: Scholarship) -> bool:
    if scholarship.deadline is None:
        return False
    if scholarship.deadline.date() in KNOWN_FICTITIOUS_SEED_DATES:
        return True
    if scholarship.data_origin == "SEED" or scholarship.last_verified_live_at is None:
        return True
    return False


def _reassign_user_references(
    session: Session,
    from_scholarship_id,
    to_scholarship_id,
    report: CleanupReport,
) -> None:
    saved_rows = (
        session.query(SavedScholarship)
        .filter(SavedScholarship.scholarship_id == from_scholarship_id)
        .all()
    )
    for saved in saved_rows:
        existing = (
            session.query(SavedScholarship)
            .filter(
                SavedScholarship.user_id == saved.user_id,
                SavedScholarship.scholarship_id == to_scholarship_id,
            )
            .first()
        )
        if existing is not None:
            session.delete(saved)
        else:
            saved.scholarship_id = to_scholarship_id
            report.reassigned_saved_count += 1

    app_rows = (
        session.query(Application)
        .filter(Application.scholarship_id == from_scholarship_id)
        .all()
    )
    for app in app_rows:
        existing = (
            session.query(Application)
            .filter(
                Application.user_id == app.user_id,
                Application.scholarship_id == to_scholarship_id,
            )
            .first()
        )
        if existing is not None:
            session.delete(app)
        else:
            app.scholarship_id = to_scholarship_id
            report.reassigned_application_count += 1


def cleanup_production_scholarships(
    session: Session | None = None,
    *,
    apply: bool = False,
) -> CleanupReport:
    """Inspect and optionally clean up production scholarship records."""
    owns_session = session is None
    db_gen = get_db() if owns_session else None
    session = next(db_gen) if owns_session else session
    report = CleanupReport(applied=apply)

    try:
        scholarships = (
            session.query(Scholarship)
            .outerjoin(ScholarshipSource, Scholarship.source_id == ScholarshipSource.id)
            .order_by(Scholarship.created_at.asc())
            .all()
        )

        canonical_bca = (
            session.query(Scholarship)
            .filter(Scholarship.title == CANONICAL_BCA_TITLE)
            .order_by(
                Scholarship.last_verified_live_at.is_(None).asc(),
                Scholarship.updated_at.desc(),
            )
            .first()
        )

        duplicate_bca_candidates: list[Scholarship] = []
        for s in scholarships:
            provider = s.source.provider_name if s.source else "-"
            desc = (
                f"{s.id} | title={s.title!r} | provider={provider!r} | "
                f"origin={s.data_origin!r} | is_active={s.is_active} | "
                f"deadline={s.deadline} | verified={s.last_verified_live_at}"
            )
            if s.data_origin == "SEED":
                report.seed_rows.append(desc)
            if s.last_verified_live_at is None:
                report.unverified_rows.append(desc)
            if _is_fictitious_deadline(s):
                report.fictitious_deadline_rows.append(desc)

            is_legacy_bca = (
                s.title in LEGACY_BCA_TITLES or provider in LEGACY_BCA_PROVIDERS
            )
            if canonical_bca is not None and s.id != canonical_bca.id and (
                is_legacy_bca or s.title == CANONICAL_BCA_TITLE
            ):
                report.duplicate_bca_rows.append(desc)
                duplicate_bca_candidates.append(s)

        # 1. Remove duplicate BCA rows (migrating user references first)
        duplicate_ids = {dup.id for dup in duplicate_bca_candidates}
        if canonical_bca is not None:
            for dup in duplicate_bca_candidates:
                source_id = dup.source_id
                _reassign_user_references(session, dup.id, canonical_bca.id, report)
                report.deleted_scholarship_ids.append(str(dup.id))
                session.delete(dup)
                session.flush()

                remaining = (
                    session.query(Scholarship)
                    .filter(Scholarship.source_id == source_id)
                    .count()
                )
                source = (
                    session.query(ScholarshipSource)
                    .filter(ScholarshipSource.id == source_id)
                    .first()
                )
                if (
                    remaining == 0
                    and source is not None
                    and source.provider_name in LEGACY_BCA_PROVIDERS
                ):
                    report.deleted_source_ids.append(str(source.id))
                    session.delete(source)

        # 2. Clear fictitious deadlines on remaining scholarships
        for s in scholarships:
            if s.id in duplicate_ids:
                continue
            if _is_fictitious_deadline(s):
                s.deadline = None
                s.is_active = False
                report.cleared_deadline_ids.append(str(s.id))

        # 3. Ensure rows with deadline=None are not marked is_active=True
        for s in scholarships:
            if s.id in duplicate_ids:
                continue
            if s.deadline is None and s.is_active:
                provider = s.source.provider_name if s.source else "-"
                report.null_deadline_active_rows.append(
                    f"{s.id} | title={s.title!r} | provider={provider!r} | "
                    f"origin={s.data_origin!r}"
                )
                s.is_active = False
                report.deactivated_null_deadline_ids.append(str(s.id))

        if apply:
            session.commit()
        else:
            session.rollback()

        return report
    except Exception:
        session.rollback()
        raise
    finally:
        if owns_session:
            try:
                next(db_gen)
            except StopIteration:
                pass


def format_report(report: CleanupReport) -> str:
    mode = "APPLIED" if report.applied else "DRY-RUN (no changes committed)"
    lines = [
        "=" * 72,
        f"RadarScholar Production Scholarship Cleanup [{mode}]",
        "=" * 72,
        f"SEED rows ({len(report.seed_rows)}):",
        *([f"  - {item}" for item in report.seed_rows] or ["  (none)"]),
        f"Unverified rows (last_verified_live_at IS NULL) ({len(report.unverified_rows)}):",
        *([f"  - {item}" for item in report.unverified_rows] or ["  (none)"]),
        f"Fictitious deadline rows ({len(report.fictitious_deadline_rows)}):",
        *([f"  - {item}" for item in report.fictitious_deadline_rows] or ["  (none)"]),
        f"Duplicate BCA rows ({len(report.duplicate_bca_rows)}):",
        *([f"  - {item}" for item in report.duplicate_bca_rows] or ["  (none)"]),
        f"Rows with deadline IS NULL AND is_active=True ({len(report.null_deadline_active_rows)}):",
        *([f"  - {item}" for item in report.null_deadline_active_rows] or ["  (none)"]),
        "-" * 72,
        f"Deleted duplicate scholarships : {len(report.deleted_scholarship_ids)}",
        f"Deleted orphan legacy sources  : {len(report.deleted_source_ids)}",
        f"Reassigned saved scholarships  : {report.reassigned_saved_count}",
        f"Reassigned applications        : {report.reassigned_application_count}",
        f"Cleared fictitious deadlines   : {len(report.cleared_deadline_ids)}",
        f"Deactivated null-deadline rows : {len(report.deactivated_null_deadline_ids)}",
        "=" * 72,
    ]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Inspect and clean up production scholarship records."
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--dry-run",
        action="store_true",
        default=True,
        help="Inspect and simulate cleanup without committing changes (default).",
    )
    group.add_argument(
        "--apply",
        action="store_true",
        default=False,
        help="Commit cleanup changes to the database.",
    )
    args = parser.parse_args()
    report = cleanup_production_scholarships(apply=args.apply)
    print(format_report(report))


if __name__ == "__main__":
    main()

