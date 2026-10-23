import uuid
from datetime import datetime

from scripts.cleanup_production_scholarships import (
    cleanup_production_scholarships,
    format_report,
)
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.applications.models import Application, ApplicationStatus, SavedScholarship
from app.database.base import Base
from app.scholarships.models import Scholarship, ScholarshipSource
from app.users.models import UserProfile


def _seed_dirty_production_db(session):
    user = UserProfile(
        id=str(uuid.uuid4()),
        email="student@example.com",
    )
    session.add(user)

    src_djarum_seed = ScholarshipSource(
        provider_name="Djarum Foundation",
        source_url="https://djarumbeasiswaplus.org",
    )
    src_bca_seed = ScholarshipSource(
        provider_name="Bank Central Asia",
        source_url="https://karir.bca.co.id/beasiswa-bca",
    )
    src_bca_live = ScholarshipSource(
        provider_name="Beasiswa BCA PPBP/PPTI",
        source_url="https://karir.bca.co.id/beasiswa-bca",
    )
    src_teladan_live = ScholarshipSource(
        provider_name="Tanoto Foundation TELADAN",
        source_url="https://www.tanotofoundation.org/initiative/teladan",
    )
    session.add_all([src_djarum_seed, src_bca_seed, src_bca_live, src_teladan_live])
    session.flush()

    djarum_seed = Scholarship(
        source_id=src_djarum_seed.id,
        title="Djarum Beasiswa Plus",
        summary="Seed Djarum",
        description="Seed Djarum description",
        deadline=datetime(2027, 5, 30),  # Fictitious seed deadline
        application_url="https://djarumbeasiswaplus.org",
        is_active=True,
        data_origin="SEED",
        last_verified_live_at=None,
    )
    bca_duplicate = Scholarship(
        source_id=src_bca_seed.id,
        title="Beasiswa BCA",
        summary="Legacy Seed BCA",
        description="Legacy Seed BCA description",
        deadline=datetime(2027, 9, 15),  # Fictitious seed deadline
        application_url="https://karir.bca.co.id/beasiswa-bca",
        is_active=True,
        data_origin="SEED",
        last_verified_live_at=None,
    )
    bca_canonical = Scholarship(
        source_id=src_bca_live.id,
        title="Beasiswa BCA PPBP/PPTI",
        summary="Canonical BCA",
        description="Canonical BCA description",
        deadline=None,
        application_url="https://karir.bca.co.id/beasiswa-bca",
        is_active=True,  # Inconsistent active flag when deadline=None
        data_origin="CRAWLER_LIVE",
        last_verified_live_at=datetime(2026, 10, 23, 2, 36, 55),
    )
    teladan_live = Scholarship(
        source_id=src_teladan_live.id,
        title="Program Beasiswa Kepemimpinan TELADAN 2027",
        summary="TELADAN",
        description="TELADAN description",
        deadline=None,
        application_url="https://www.tanotofoundation.org/teladan-2027",
        is_active=True,  # Inconsistent active flag when deadline=None
        data_origin="CRAWLER_LIVE",
        last_verified_live_at=datetime(2026, 10, 23, 2, 36, 44),
    )
    session.add_all([djarum_seed, bca_duplicate, bca_canonical, teladan_live])
    session.flush()

    session.add(
        SavedScholarship(
            user_id=user.id,
            scholarship_id=bca_duplicate.id,
        )
    )
    session.add(
        Application(
            user_id=user.id,
            scholarship_id=bca_duplicate.id,
            status=ApplicationStatus.PLANNED,
        )
    )
    session.commit()
    return {
        "user_id": user.id,
        "djarum_id": djarum_seed.id,
        "bca_dup_id": bca_duplicate.id,
        "bca_canon_id": bca_canonical.id,
        "teladan_id": teladan_live.id,
    }


def test_cleanup_dry_run_reports_issues_without_committing():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()

    try:
        ids = _seed_dirty_production_db(session)
        report = cleanup_production_scholarships(session, apply=False)

        assert report.applied is False
        assert len(report.seed_rows) == 2
        assert len(report.fictitious_deadline_rows) == 2
        assert len(report.duplicate_bca_rows) == 1
        assert len(report.null_deadline_active_rows) == 2
        assert "DRY-RUN" in format_report(report)

        # Verify rollback preserved original DB state
        assert session.query(Scholarship).count() == 4
        djarum = session.get(Scholarship, ids["djarum_id"])
        assert djarum.deadline == datetime(2027, 5, 30)
        assert djarum.is_active is True
    finally:
        session.close()
        engine.dispose()


def test_cleanup_apply_removes_bca_duplicate_clears_fictitious_deadlines_and_fixes_flags():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()

    try:
        ids = _seed_dirty_production_db(session)
        report = cleanup_production_scholarships(session, apply=True)

        assert report.applied is True
        assert len(report.deleted_scholarship_ids) == 1
        assert report.reassigned_saved_count == 1
        assert report.reassigned_application_count == 1
        assert len(report.cleared_deadline_ids) == 1  # Djarum fictitious deadline cleared
        assert len(report.deactivated_null_deadline_ids) == 2  # BCA canonical + TELADAN

        # Duplicate BCA row was removed; canonical BCA row kept and received user refs
        assert session.get(Scholarship, ids["bca_dup_id"]) is None
        bca_canon = session.get(Scholarship, ids["bca_canon_id"])
        assert bca_canon is not None
        assert bca_canon.is_active is False

        saved = session.query(SavedScholarship).one()
        assert saved.scholarship_id == ids["bca_canon_id"]
        app = session.query(Application).one()
        assert app.scholarship_id == ids["bca_canon_id"]

        # Djarum fictitious deadline cleared and deactivated
        djarum = session.get(Scholarship, ids["djarum_id"])
        assert djarum.deadline is None
        assert djarum.is_active is False

        # TELADAN null-deadline row deactivated
        teladan = session.get(Scholarship, ids["teladan_id"])
        assert teladan.deadline is None
        assert teladan.is_active is False
    finally:
        session.close()
        engine.dispose()
