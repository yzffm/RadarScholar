import uuid

import pytest

from app.matching.engine import MatchingEngine
from app.matching.schemas import CriterionState
from app.scholarships.models import ScholarshipRequirement
from app.users.models import DegreeLevel, UserProfile


@pytest.fixture
def engine():
    return MatchingEngine()

def create_req(req_type, op, val):
    return ScholarshipRequirement(
        id=uuid.uuid4(),
        scholarship_id=uuid.uuid4(),
        requirement_type=req_type,
        operator=op,
        value=val,
        description="Test requirement"
    )

def test_evaluate_gpa_match(engine):
    profile = UserProfile(gpa=3.5)
    req = create_req("GPA", "GTE", {"gpa": 3.0})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.MATCH
    assert "memenuhi minimum" in res.explanation

def test_evaluate_gpa_not_match(engine):
    profile = UserProfile(gpa=2.8)
    req = create_req("GPA", "GTE", {"gpa": 3.0})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NOT_MATCH

def test_evaluate_gpa_unknown(engine):
    profile = UserProfile(gpa=None)
    req = create_req("GPA", "GTE", {"gpa": 3.0})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.UNKNOWN

def test_evaluate_semester_match(engine):
    profile = UserProfile(semester=5)
    req = create_req("SEMESTER", "GTE", {"semester": 3})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.MATCH

def test_evaluate_semester_not_match(engine):
    profile = UserProfile(semester=2)
    req = create_req("SEMESTER", "GTE", {"semester": 3})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NOT_MATCH

def test_evaluate_semester_unknown(engine):
    profile = UserProfile(semester=None)
    req = create_req("SEMESTER", "GTE", {"semester": 3})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.UNKNOWN

def test_evaluate_degree_match(engine):
    profile = UserProfile(degree_level=DegreeLevel.S1)
    req = create_req("EDUCATION_LEVEL", "EQUALS", {"level": "S1"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.MATCH

def test_evaluate_degree_not_match(engine):
    profile = UserProfile(degree_level=DegreeLevel.S1)
    req = create_req("EDUCATION_LEVEL", "EQUALS", {"level": "S2"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NOT_MATCH

def test_evaluate_degree_unknown(engine):
    profile = UserProfile(degree_level=None)
    req = create_req("EDUCATION_LEVEL", "EQUALS", {"level": "S1"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.UNKNOWN


@pytest.mark.parametrize(
    ("degree_level", "levels", "expected"),
    [
        (DegreeLevel.S1, ["S1", "D4"], CriterionState.MATCH),
        (DegreeLevel.S2, ["S1", "D4"], CriterionState.NOT_MATCH),
        (DegreeLevel.S2, ["S2", "S3"], CriterionState.MATCH),
    ],
)
def test_evaluate_degree_level_list_from_scraper(engine, degree_level, levels, expected):
    profile = UserProfile(degree_level=degree_level)
    req = create_req("DEGREE_LEVEL", "IN", {"levels": levels})

    res = engine.evaluate(profile, req)

    assert res.state == expected
    assert res.requirement_type == "DEGREE_LEVEL"

def test_evaluate_major_in_match(engine):
    profile = UserProfile(major="Computer Science")
    req = create_req("MAJOR", "IN", {"majors": ["Computer Science", "Information Systems"]})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.MATCH

def test_evaluate_major_in_not_match(engine):
    profile = UserProfile(major="Law")
    req = create_req("MAJOR", "IN", {"majors": ["Computer Science", "Information Systems"]})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NOT_MATCH

def test_evaluate_malformed_gpa(engine):
    profile = UserProfile(gpa=3.5)
    req = create_req("GPA", "GTE", {"gpa": "abc"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NEEDS_VERIFICATION

def test_evaluate_unknown_operator(engine):
    profile = UserProfile(gpa=3.5)
    req = create_req("GPA", "UNKNOWN_OP", {"gpa": 3.0})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NEEDS_VERIFICATION

def test_evaluate_missing_value(engine):
    profile = UserProfile(gpa=3.5)
    req = create_req("GPA", "GTE", {})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NEEDS_VERIFICATION

def test_evaluate_age(engine):
    profile = UserProfile()
    req = create_req("AGE", "LTE", {"age": 19})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NEEDS_VERIFICATION


_TELADAN_PARTNERS = [
    "IPB University",
    "Institut Teknologi Bandung",
    "Universitas Brawijaya",
    "Universitas Diponegoro",
    "Universitas Gadjah Mada",
    "Universitas Hasanuddin",
    "Universitas Indonesia",
    "Universitas Mulawarman",
    "Universitas Riau",
    "Universitas Sumatera Utara",
]


@pytest.mark.parametrize(
    ("profile_uni", "expected_state"),
    [
        # Exact & case/punctuation variations -> MATCH
        ("Universitas Gadjah Mada", CriterionState.MATCH),
        ("universitas gadjah mada.", CriterionState.MATCH),
        # Known alias matches -> MATCH
        ("UGM", CriterionState.MATCH),
        ("UI", CriterionState.MATCH),
        ("Universitas Indonesia (UI)", CriterionState.MATCH),
        ("Institut Pertanian Bogor", CriterionState.MATCH),
        ("IPB", CriterionState.MATCH),
        ("UNDIP", CriterionState.MATCH),
        # Confident non-matches (known alias not in partner list, or specific university) -> NOT_MATCH
        ("Universitas Negeri Surabaya", CriterionState.NOT_MATCH),
        ("UNESA", CriterionState.NOT_MATCH),
        ("Universitas Airlangga", CriterionState.NOT_MATCH),
        ("UNAIR", CriterionState.NOT_MATCH),
        ("Universitas Pancasila", CriterionState.NOT_MATCH),
        # Missing / blank profile university -> UNKNOWN
        (None, CriterionState.UNKNOWN),
        ("", CriterionState.UNKNOWN),
        ("   ", CriterionState.UNKNOWN),
        # Ambiguous / generic / unknown single-token / partial substring -> NEEDS_VERIFICATION
        ("Universitas", CriterionState.NEEDS_VERIFICATION),
        ("Universitas Negeri", CriterionState.NEEDS_VERIFICATION),
        ("Perguruan Tinggi Negeri", CriterionState.NEEDS_VERIFICATION),
        ("PTN", CriterionState.NEEDS_VERIFICATION),
        ("XYZ", CriterionState.NEEDS_VERIFICATION),
        ("Universitas Sumatera", CriterionState.NEEDS_VERIFICATION),
        ("Fakultas Teknik Universitas Indonesia", CriterionState.NEEDS_VERIFICATION),
        ("---", CriterionState.NEEDS_VERIFICATION),
    ],
)
def test_evaluate_university_in_branches(engine, profile_uni, expected_state):
    profile = UserProfile(university=profile_uni)
    req = create_req("UNIVERSITY", "IN", {"universities": _TELADAN_PARTNERS})
    res = engine.evaluate(profile, req)
    assert res.state == expected_state
    assert res.requirement_type == "UNIVERSITY"


def test_evaluate_university_eq_alias_match_unesa(engine):
    profile = UserProfile(university="Universitas Negeri Surabaya")
    req = create_req("UNIVERSITY", "EQ", {"university": "UNESA"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.MATCH
    assert res.actual_value == "Universitas Negeri Surabaya"
    assert res.required_value == "UNESA"


def test_evaluate_university_eq_not_match(engine):
    profile = UserProfile(university="UNESA")
    req = create_req("UNIVERSITY", "EQ", {"university": "Universitas Gadjah Mada"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NOT_MATCH


def test_evaluate_university_malformed_and_unsupported_op(engine):
    profile = UserProfile(university="Universitas Indonesia")

    res_missing = engine.evaluate(profile, create_req("UNIVERSITY", "IN", {}))
    assert res_missing.state == CriterionState.NEEDS_VERIFICATION

    res_bad_in = engine.evaluate(
        profile, create_req("UNIVERSITY", "IN", {"universities": "Universitas Indonesia"})
    )
    assert res_bad_in.state == CriterionState.NEEDS_VERIFICATION

    res_bad_op = engine.evaluate(
        profile, create_req("UNIVERSITY", "GTE", {"university": "Universitas Indonesia"})
    )
    assert res_bad_op.state == CriterionState.NEEDS_VERIFICATION


def test_evaluate_nationality_without_profile_field_returns_needs_verification(engine):
    profile = UserProfile(university="Universitas Indonesia", gpa=3.7)
    req = create_req("NATIONALITY", "EQ", {"country": "Indonesia"})
    res = engine.evaluate(profile, req)
    assert res.state == CriterionState.NEEDS_VERIFICATION
    assert res.required_value == "Indonesia"
    assert res.actual_value is None
    assert "kewarganegaraan" in res.explanation.lower()


def test_evaluate_nationality_when_profile_attribute_present(engine):
    profile_wni = UserProfile()
    profile_wni.nationality = "WNI"
    req = create_req("NATIONALITY", "EQ", {"country": "Indonesia"})
    res_match = engine.evaluate(profile_wni, req)
    assert res_match.state == CriterionState.MATCH

    profile_wna = UserProfile()
    profile_wna.nationality = "WNA"
    res_not_match = engine.evaluate(profile_wna, req)
    assert res_not_match.state == CriterionState.NOT_MATCH


def test_evaluate_nationality_malformed(engine):
    profile = UserProfile()
    res_empty = engine.evaluate(profile, create_req("NATIONALITY", "EQ", {}))
    assert res_empty.state == CriterionState.NEEDS_VERIFICATION

    res_bad_op = engine.evaluate(
        profile, create_req("NATIONALITY", "GTE", {"country": "Indonesia"})
    )
    assert res_bad_op.state == CriterionState.NEEDS_VERIFICATION

