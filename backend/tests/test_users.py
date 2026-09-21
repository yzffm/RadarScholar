"""Tests for user profile schemas validation."""

import pytest
from app.users.schemas import UserProfileCreate, UserProfileUpdate, DegreeLevelSchema
from pydantic import ValidationError


def test_profile_create_all_optional():
    """Creating with empty data should be valid (gradual profile fill)."""
    profile = UserProfileCreate()
    assert profile.display_name is None
    assert profile.university is None
    assert profile.gpa is None


def test_profile_create_with_academic_data():
    """Full academic profile should validate correctly."""
    profile = UserProfileCreate(
        display_name="Ahmad Fauzi",
        university="Universitas Indonesia",
        faculty="Ilmu Komputer",
        major="Sistem Informasi",
        degree_level=DegreeLevelSchema.S1,
        semester=5,
        gpa=3.75,
    )
    assert profile.university == "Universitas Indonesia"
    assert profile.degree_level == DegreeLevelSchema.S1
    assert profile.gpa == 3.75


def test_profile_create_with_experience():
    """Experience list fields should validate."""
    profile = UserProfileCreate(
        organizations=["BEM UI", "HMSI"],
        achievements=["Juara 1 Hackathon"],
        skills=["Python", "Flutter", "SQL"],
    )
    assert len(profile.organizations) == 2
    assert "Python" in profile.skills


def test_gpa_validation_too_high():
    """GPA above 4.0 should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(gpa=4.5)


def test_gpa_validation_negative():
    """Negative GPA should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(gpa=-0.5)


def test_semester_validation_too_high():
    """Semester above 14 should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(semester=15)


def test_semester_validation_zero():
    """Semester 0 should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(semester=0)


def test_profile_update_partial():
    """Update should accept partial data."""
    update = UserProfileUpdate(gpa=3.85)
    data = update.model_dump(exclude_unset=True)
    assert data == {"gpa": 3.85}
    assert "display_name" not in data


def test_profile_create_with_interests():
    """Interest fields should validate."""
    profile = UserProfileCreate(
        career_interests=["Data Science", "Software Engineering"],
        fields_of_interest=["AI", "Web Development"],
        goals="Menjadi software engineer profesional",
    )
    assert len(profile.career_interests) == 2
    assert profile.goals is not None


def test_display_name_max_length():
    """Display name exceeding 255 chars should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(display_name="A" * 256)


def test_degree_level_enum():
    """All degree levels should be valid."""
    for level in ["D3", "D4", "S1", "S2", "S3"]:
        profile = UserProfileCreate(degree_level=level)
        assert profile.degree_level.value == level


def test_invalid_degree_level():
    """Invalid degree level should be rejected."""
    with pytest.raises(ValidationError):
        UserProfileCreate(degree_level="S4")
