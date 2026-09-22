"""Seed script for Scholarships.

Populates the database with initial scholarship sources and data
(Beasiswa Djarum Plus, Beasiswa BCA).
"""

from datetime import datetime
from uuid import uuid4

from app.database.session import get_db
from app.scholarships.models import (
    Scholarship,
    ScholarshipBenefit,
    ScholarshipRequirement,
    ScholarshipSource,
)


def seed_scholarships() -> None:
    """Seed scholarships into the database."""
    db_gen = get_db()
    session = next(db_gen)
    try:
        print("Seeding scholarship sources...")
        djarum_source = ScholarshipSource(
            id=uuid4(),
            provider_name="Djarum Foundation",
            source_url="https://djarumbeasiswaplus.org/",
            crawl_allowed=True,
            active=True,
        )

        bca_source = ScholarshipSource(
            id=uuid4(),
            provider_name="Bank Central Asia",
            source_url="https://karir.bca.co.id/beasiswa-bca",
            crawl_allowed=True,
            active=True,
        )

        session.add_all([djarum_source, bca_source])

        print("Seeding scholarships...")
        djarum = Scholarship(
            id=uuid4(),
            source_id=djarum_source.id,
            title="Djarum Beasiswa Plus",
            summary="Program Djarum Beasiswa Plus merupakan beasiswa prestasi.",
            description="Program Djarum Beasiswa Plus merupakan beasiswa prestasi yang memberikan beragam pelatihan keterampilan lunak atau soft skills serta wawasan kebangsaan kepada para mahasiswa berprestasi di Indonesia.",
            deadline=datetime(2027, 5, 30),
            application_url="https://djarumbeasiswaplus.org/",
            is_active=True,
        )

        bca = Scholarship(
            id=uuid4(),
            source_id=bca_source.id,
            title="Beasiswa BCA",
            summary="Program Beasiswa BCA ditujukan kepada para lulusan SMA/SMK/sederajat berprestasi.",
            description="Program Beasiswa BCA adalah salah satu program Corporate Social Responsibility (CSR) BCA yang ditujukan kepada para lulusan SMA/SMK/sederajat yang berprestasi.",
            deadline=datetime(2027, 9, 15),
            application_url="https://karir.bca.co.id/beasiswa-bca",
            is_active=True,
        )

        session.add_all([djarum, bca])

        print("Seeding requirements...")
        reqs = [
            # Djarum Requirements
            ScholarshipRequirement(
                id=uuid4(),
                scholarship_id=djarum.id,
                requirement_type="SEMESTER",
                operator="EQUALS",
                value={"semester": 4},
                description="Sedang menempuh pendidikan Strata 1/Diploma 4 di semester IV",
            ),
            ScholarshipRequirement(
                id=uuid4(),
                scholarship_id=djarum.id,
                requirement_type="GPA",
                operator="GTE",
                value={"gpa": 3.20},
                description="IPK minimum 3.20 pada semester III",
            ),
            ScholarshipRequirement(
                id=uuid4(),
                scholarship_id=djarum.id,
                requirement_type="ORGANIZATION",
                operator="EXISTS",
                value={"required": True},
                description="Aktif mengikuti kegiatan organisasi baik di dalam maupun di luar kampus",
            ),
            # BCA Requirements
            ScholarshipRequirement(
                id=uuid4(),
                scholarship_id=bca.id,
                requirement_type="EDUCATION_LEVEL",
                operator="EQUALS",
                value={"level": "SMA/SMK"},
                description="Siswa/siswi lulusan SMA/SMK/sederajat",
            ),
            ScholarshipRequirement(
                id=uuid4(),
                scholarship_id=bca.id,
                requirement_type="AGE",
                operator="LTE",
                value={"age": 19},
                description="Usia maksimum 19 tahun",
            ),
        ]
        session.add_all(reqs)

        print("Seeding benefits...")
        benefits = [
            # Djarum Benefits
            ScholarshipBenefit(
                id=uuid4(),
                scholarship_id=djarum.id,
                benefit_type="FINANCIAL",
                description="Dana beasiswa sebesar Rp 1.000.000,- setiap bulan selama 1 tahun",
            ),
            ScholarshipBenefit(
                id=uuid4(),
                scholarship_id=djarum.id,
                benefit_type="TRAINING",
                description="Pelatihan Soft Skills (Nation Building, Character Building, Leadership Development, Competition Challenges, International Exposure)",
            ),
            # BCA Benefits
            ScholarshipBenefit(
                id=uuid4(),
                scholarship_id=bca.id,
                benefit_type="FINANCIAL",
                description="Bebas biaya pendidikan dan mendapatkan uang saku bulanan",
            ),
            ScholarshipBenefit(
                id=uuid4(),
                scholarship_id=bca.id,
                benefit_type="CAREER",
                description="Kesempatan magang dan penawaran kerja di BCA",
            ),
            ScholarshipBenefit(
                id=uuid4(),
                scholarship_id=bca.id,
                benefit_type="LAPTOP",
                description="Fasilitas laptop selama program",
            ),
        ]
        session.add_all(benefits)

        session.commit()
        print("Successfully seeded database.")
    finally:
        try:
            next(db_gen)
        except StopIteration:
            pass


if __name__ == "__main__":
    seed_scholarships()
