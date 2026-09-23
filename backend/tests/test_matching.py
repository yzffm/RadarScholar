import pytest
from app.matching.engine import MatchingEngine
from app.matching.schemas import CriterionState
from app.scholarships.models import ScholarshipRequirement
from app.users.models import UserProfile, DegreeLevel
import uuid

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
