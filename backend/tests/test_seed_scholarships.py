from scripts.seed_scholarships import seed_scholarships
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database.base import Base
from app.scholarships.models import Scholarship, ScholarshipSource


def test_seed_is_idempotent_and_marks_provenance():
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine)()

    try:
        assert seed_scholarships(session) == 2
        assert seed_scholarships(session) == 2

        assert session.query(ScholarshipSource).count() == 2
        assert session.query(Scholarship).count() == 2
        for scholarship in session.query(Scholarship).all():
            assert scholarship.data_origin == "SEED"
            assert scholarship.last_verified_live_at is None
            assert len(scholarship.requirements) > 0
            assert len(scholarship.benefits) > 0
    finally:
        session.close()
        engine.dispose()


def test_provenance_migration_contract():
    from pathlib import Path

    migration = (
        Path(__file__).parents[1]
        / "alembic"
        / "versions"
        / "a8b7c6d5e4f3_add_scholarship_data_origin.py"
    )
    source = migration.read_text(encoding="utf-8")

    assert '"data_origin"' in source
    assert 'server_default="CRAWLER"' in source
    assert 'op.drop_column("scholarships", "data_origin")' in source
