from pathlib import Path


def test_scholarship_downgrade_does_not_alter_user_profile_id():
    migration = Path(__file__).parents[1] / "alembic" / "versions" / (
        "ce5efc284f0e_create_scholarships_tables.py"
    )
    source = migration.read_text(encoding="utf-8")
    downgrade = source.split("def downgrade()", maxsplit=1)[1]

    assert "alter_column('user_profiles', 'id'" not in downgrade
    assert "drop_table('scholarship_requirements')" in downgrade
    assert "drop_table('scholarship_benefits')" in downgrade
    assert "drop_table('scholarships')" in downgrade
    assert "drop_table('scholarship_sources')" in downgrade
