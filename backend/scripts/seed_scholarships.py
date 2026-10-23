"""Idempotently seed baseline scholarship data.

Seed records preserve their official source URLs and are marked ``SEED``.
They intentionally keep ``last_verified_live_at`` empty and ``deadline`` as
``None`` because this script does not fetch or verify live provider pages.
"""

from app.crawler.pipeline import _normalize_url
from app.database.session import get_db
from app.scholarships.models import (
    Scholarship,
    ScholarshipBenefit,
    ScholarshipRequirement,
    ScholarshipSource,
)

SEED_SCHOLARSHIPS = (
    {
        "provider_name": "Djarum Beasiswa Plus",
        "source_url": "https://djarumbeasiswaplus.org/our-program/regulation-djarum-beasiswa-plus",
        "title": "Djarum Beasiswa Plus",
        "summary": "Program Djarum Beasiswa Plus merupakan beasiswa prestasi.",
        "description": (
            "Program Djarum Beasiswa Plus merupakan beasiswa prestasi yang "
            "memberikan beragam pelatihan keterampilan lunak atau soft skills "
            "serta wawasan kebangsaan kepada para mahasiswa berprestasi di Indonesia."
        ),
        "deadline": None,
        "application_url": "https://register.djarumbeasiswaplus.org",
        "requirements": (
            ("SEMESTER", "EQ", {"semester": 4}, "Sedang menempuh pendidikan Strata 1/Diploma 4 di semester IV"),
            ("GPA", "GTE", {"gpa": 3.00}, "IPK minimum 3.00 pada semester III"),
            ("ORGANIZATION", "EXISTS", {"required": True}, "Aktif mengikuti kegiatan organisasi baik di dalam maupun di luar kampus"),
        ),
        "benefits": (
            ("TUITION_FEE", "Dana beasiswa selama 1 tahun"),
            ("TRAINING", "Pelatihan Soft Skills (Nation Building, Character Building, Leadership Development, Competition Challenges, International Exposure)"),
        ),
    },
    {
        "provider_name": "Beasiswa BCA PPBP/PPTI",
        "source_url": "https://karir.bca.co.id/beasiswa-bca",
        "title": "Beasiswa BCA PPBP/PPTI",
        "summary": "Program Beasiswa BCA ditujukan kepada para lulusan SMA/SMK/sederajat berprestasi.",
        "description": "Program Beasiswa BCA adalah salah satu program Corporate Social Responsibility (CSR) BCA yang ditujukan kepada para lulusan SMA/SMK/sederajat yang berprestasi.",
        "deadline": None,
        "application_url": "https://karir.bca.co.id/beasiswa-bca",
        "requirements": (
            ("EDUCATION_LEVEL", "IN", {"levels": ["SMA", "SMK"]}, "Siswa/siswi lulusan SMA/SMK/sederajat"),
            ("AGE", "LTE", {"age": 19}, "Usia maksimum 19 tahun"),
        ),
        "benefits": (
            ("TUITION_FEE", "Bebas biaya pendidikan dan mendapatkan uang saku bulanan"),
            ("INTERNSHIP", "Kesempatan magang dan penawaran kerja di BCA"),
        ),
    },
)


def _get_or_create_source(session, data: dict) -> ScholarshipSource:
    target_url = _normalize_url(data["source_url"])
    source = (
        session.query(ScholarshipSource)
        .filter(ScholarshipSource.source_url.in_([target_url, data["source_url"]]))
        .first()
    )
    if source is None:
        for candidate in session.query(ScholarshipSource).all():
            if _normalize_url(candidate.source_url) == target_url:
                source = candidate
                break
    if source is None:
        source = (
            session.query(ScholarshipSource)
            .filter(ScholarshipSource.provider_name == data["provider_name"])
            .first()
        )

    if source is None:
        source = ScholarshipSource(
            provider_name=data["provider_name"],
            source_url=target_url,
            crawl_allowed=True,
            active=True,
        )
        session.add(source)
        session.flush()
    else:
        source.provider_name = data["provider_name"]
        source.source_url = target_url
    return source


def _replace_children(session, scholarship: Scholarship, data: dict) -> None:
    scholarship.requirements.clear()
    scholarship.benefits.clear()
    for requirement_type, operator, value, description in data["requirements"]:
        scholarship.requirements.append(
            ScholarshipRequirement(
                requirement_type=requirement_type,
                operator=operator,
                value=value,
                description=description,
            )
        )
    for benefit_type, description in data["benefits"]:
        scholarship.benefits.append(
            ScholarshipBenefit(
                benefit_type=benefit_type,
                description=description,
            )
        )


def seed_scholarships(session=None) -> int:
    """Insert or update baseline records and return the number of scholarships."""
    owns_session = session is None
    db_gen = get_db() if owns_session else None
    session = next(db_gen) if owns_session else session
    try:
        for data in SEED_SCHOLARSHIPS:
            source = _get_or_create_source(session, data)
            app_url = _normalize_url(data["application_url"])
            scholarship = (
                session.query(Scholarship)
                .filter(
                    Scholarship.source_id == source.id,
                    Scholarship.application_url == app_url,
                )
                .first()
            )
            if scholarship is None:
                scholarship = (
                    session.query(Scholarship)
                    .filter(
                        Scholarship.source_id == source.id,
                        Scholarship.title == data["title"],
                    )
                    .first()
                )
            if scholarship is None:
                scholarship = Scholarship(source_id=source.id)
                session.add(scholarship)

            scholarship.title = data["title"]
            scholarship.summary = data["summary"]
            scholarship.description = data["description"]
            scholarship.deadline = data["deadline"]
            scholarship.application_url = app_url
            scholarship.is_active = bool(data["deadline"])
            scholarship.data_origin = "SEED"
            # Seed data has provenance but no live verification timestamp.
            scholarship.last_verified_live_at = None
            session.flush()
            _replace_children(session, scholarship, data)

        session.commit()
        return len(SEED_SCHOLARSHIPS)
    except Exception:
        session.rollback()
        raise
    finally:
        if owns_session:
            try:
                next(db_gen)
            except StopIteration:
                pass


if __name__ == "__main__":
    print(f"Seeded {seed_scholarships()} scholarships.")
