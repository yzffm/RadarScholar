import uuid

import pytest

from app.matching.engine import MatchingEngine
from app.matching.schemas import RelevanceTier
from app.matching.service import MatchingService
from app.scholarships.models import Scholarship, ScholarshipRequirement
from app.users.models import UserProfile


@pytest.fixture
def service():
    return MatchingService(MatchingEngine())

def create_scholarship(reqs=None):
    return Scholarship(
        id=uuid.uuid4(),
        source_id=uuid.uuid4(),
        title="Test Scholarship",
        summary="Test",
        description="Test",
        application_url="http://test",
        is_active=True,
        requirements=reqs or []
    )

def create_req(req_type, op, val):
    return ScholarshipRequirement(
        id=uuid.uuid4(),
        scholarship_id=uuid.uuid4(),
        requirement_type=req_type,
        operator=op,
        value=val,
        description="Desc"
    )

def test_service_sangat_relevan(service):
    profile = UserProfile(gpa=3.5, semester=5)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("SEMESTER", "GTE", {"semester": 3})
    scholarship = create_scholarship([req1, req2])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.SANGAT_RELEVAN
    assert result.matched_count == 2

def test_service_tidak_memenuhi(service):
    profile = UserProfile(gpa=2.8, semester=5)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("SEMESTER", "GTE", {"semester": 3})
    scholarship = create_scholarship([req1, req2])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.TIDAK_MEMENUHI
    assert result.not_matched_count == 1

def test_service_relevan(service):
    profile = UserProfile(gpa=3.5, semester=None)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("SEMESTER", "GTE", {"semester": 3})
    scholarship = create_scholarship([req1, req2])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.RELEVAN
    assert result.unknown_count == 1
    assert result.matched_count == 1

def test_service_mungkin_relevan(service):
    profile = UserProfile(gpa=3.5, semester=None)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("SEMESTER", "GTE", {"semester": 3})
    req3 = create_req("ORGANIZATION", "EXISTS", {"required": True}) # returns unknown since no orgs
    scholarship = create_scholarship([req1, req2, req3])

    result = service.match(profile, scholarship)
    # matched = 1, unknown = 2 => matched < unknown => MUNGKIN_RELEVAN
    assert result.relevance == RelevanceTier.MUNGKIN_RELEVAN
    assert result.unknown_count == 2
    assert result.matched_count == 1

def test_service_belum_cukup_informasi(service):
    profile = UserProfile(gpa=None, semester=None)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("SEMESTER", "GTE", {"semester": 3})
    scholarship = create_scholarship([req1, req2])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.BELUM_CUKUP_INFORMASI
    assert result.unknown_count == 2
    assert result.matched_count == 0

def test_service_perlu_dicek(service):
    profile = UserProfile(gpa=3.5)
    req1 = create_req("GPA", "GTE", {"gpa": 3.0})
    req2 = create_req("AGE", "LTE", {"age": 19}) # age returns needs_verification
    scholarship = create_scholarship([req1, req2])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.PERLU_DICEK
    assert result.needs_verification_count == 1
    assert result.matched_count == 1

def test_service_no_requirements(service):
    profile = UserProfile(gpa=3.5)
    scholarship = create_scholarship([])

    result = service.match(profile, scholarship)
    assert result.relevance == RelevanceTier.PERLU_DICEK
