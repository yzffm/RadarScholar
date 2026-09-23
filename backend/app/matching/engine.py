from typing import Any

from app.matching.schemas import CriterionEvaluation, CriterionState
from app.scholarships.models import ScholarshipRequirement
from app.users.models import UserProfile


class MatchingEngine:
    """Deterministic matching engine for evaluating user profiles against scholarship requirements."""

    def evaluate(self, profile: UserProfile, requirement: ScholarshipRequirement) -> CriterionEvaluation:
        """Evaluates a single requirement against the user's profile."""

        req_type = requirement.requirement_type.upper()
        op = requirement.operator.upper()
        val = requirement.value
        desc = requirement.description

        if req_type == "GPA":
            return self._evaluate_gpa(profile, op, val, desc)
        elif req_type == "SEMESTER":
            return self._evaluate_semester(profile, op, val, desc)
        elif req_type == "ORGANIZATION":
            return self._evaluate_organization(profile, op, val, desc)
        elif req_type == "EDUCATION_LEVEL" or req_type == "DEGREE_LEVEL":
            return self._evaluate_education_level(profile, op, val, desc)
        elif req_type == "MAJOR":
            return self._evaluate_major(profile, op, val, desc)
        elif req_type == "AGE":
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=val,
                actual_value=None,
                state=CriterionState.NEEDS_VERIFICATION,
                explanation="Persyaratan umur tidak dapat dievaluasi secara otomatis karena data umur tidak tersedia."
            )
        else:
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=val,
                actual_value=None,
                state=CriterionState.NEEDS_VERIFICATION,
                explanation=f"Persyaratan tipe '{req_type}' tidak dapat dievaluasi secara otomatis."
            )

    def _evaluate_gpa(self, profile: UserProfile, op: str, val: dict[str, Any], desc: str) -> CriterionEvaluation:
        if "gpa" not in val:
            return self._needs_verification("GPA", op, val, "Format nilai GPA tidak sesuai.")

        required_gpa = val["gpa"]
        try:
            required_gpa = float(required_gpa)
        except (ValueError, TypeError):
            return self._needs_verification("GPA", op, val, "Format nilai GPA tidak valid (bukan angka).")

        actual_gpa = profile.gpa

        if actual_gpa is None:
            return CriterionEvaluation(
                requirement_type="GPA",
                operator=op,
                required_value=required_gpa,
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="IPK belum tersedia pada profil Anda."
            )

        if op == "GTE":
            if actual_gpa >= required_gpa:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} memenuhi minimum {required_gpa:.2f}."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} berada di bawah minimum {required_gpa:.2f}."
                )
        elif op == "LTE":
            if actual_gpa <= required_gpa:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} memenuhi batas maksimum {required_gpa:.2f}."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} melebihi batas maksimum {required_gpa:.2f}."
                )
        elif op == "EQUALS" or op == "EQ":
            if abs(actual_gpa - required_gpa) < 0.01:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} sesuai dengan persyaratan {required_gpa:.2f}."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="GPA",
                    operator=op,
                    required_value=required_gpa,
                    actual_value=actual_gpa,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"IPK Anda {actual_gpa:.2f} tidak sesuai dengan persyaratan {required_gpa:.2f}."
                )

        return self._needs_verification("GPA", op, val, f"Operator '{op}' tidak didukung untuk IPK.")

    def _evaluate_semester(self, profile: UserProfile, op: str, val: dict[str, Any], desc: str) -> CriterionEvaluation:
        if "semester" not in val:
            return self._needs_verification("SEMESTER", op, val, "Format nilai Semester tidak sesuai.")

        req_sem = val["semester"]
        try:
            req_sem = int(req_sem)
        except (ValueError, TypeError):
            return self._needs_verification("SEMESTER", op, val, "Format nilai Semester tidak valid (bukan angka).")

        actual_sem = profile.semester

        if actual_sem is None:
            return CriterionEvaluation(
                requirement_type="SEMESTER",
                operator=op,
                required_value=req_sem,
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="Semester belum tersedia pada profil Anda."
            )

        if op == "GTE":
            if actual_sem >= req_sem:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.MATCH,
                    explanation=f"Semester Anda ({actual_sem}) memenuhi minimum semester {req_sem}."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Semester Anda ({actual_sem}) di bawah persyaratan minimum semester {req_sem}."
                )
        elif op == "LTE":
            if actual_sem <= req_sem:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.MATCH,
                    explanation=f"Semester Anda ({actual_sem}) memenuhi batas maksimum semester {req_sem}."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Semester Anda ({actual_sem}) melebihi batas maksimum semester {req_sem}."
                )
        elif op == "EQUALS" or op == "EQ":
            if actual_sem == req_sem:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.MATCH,
                    explanation=f"Semester Anda ({actual_sem}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="SEMESTER",
                    operator=op,
                    required_value=req_sem,
                    actual_value=actual_sem,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Semester Anda ({actual_sem}) tidak sesuai dengan yang diwajibkan (semester {req_sem})."
                )

        return self._needs_verification("SEMESTER", op, val, f"Operator '{op}' tidak didukung untuk Semester.")

    def _evaluate_organization(self, profile: UserProfile, op: str, val: dict[str, Any], desc: str) -> CriterionEvaluation:
        if "required" not in val:
            return self._needs_verification("ORGANIZATION", op, val, "Format nilai Organisasi tidak sesuai.")

        req_val = bool(val["required"])
        orgs = profile.organizations or []
        has_orgs = len(orgs) > 0

        if op == "EXISTS":
            if req_val:
                if has_orgs:
                    return CriterionEvaluation(
                        requirement_type="ORGANIZATION",
                        operator=op,
                        required_value=True,
                        actual_value=True,
                        state=CriterionState.MATCH,
                        explanation="Anda memiliki pengalaman organisasi."
                    )
                else:
                    return CriterionEvaluation(
                        requirement_type="ORGANIZATION",
                        operator=op,
                        required_value=True,
                        actual_value=False,
                        state=CriterionState.UNKNOWN,
                        explanation="Pengalaman organisasi belum tersedia pada profil Anda."
                    )

        return self._needs_verification("ORGANIZATION", op, val, f"Operator '{op}' tidak didukung untuk Organisasi.")

    def _evaluate_education_level(self, profile: UserProfile, op: str, val: dict[str, Any], desc: str) -> CriterionEvaluation:
        if "level" not in val:
            return self._needs_verification("EDUCATION_LEVEL", op, val, "Format tingkat pendidikan tidak sesuai.")

        req_level = str(val["level"]).strip().upper()
        actual_level = profile.degree_level

        if actual_level is None:
            return CriterionEvaluation(
                requirement_type="EDUCATION_LEVEL",
                operator=op,
                required_value=req_level,
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="Tingkat pendidikan belum tersedia pada profil Anda."
            )

        actual_level_str = actual_level.value.upper()

        if op == "EQUALS" or op == "EQ":
            if actual_level_str == req_level:
                return CriterionEvaluation(
                    requirement_type="EDUCATION_LEVEL",
                    operator=op,
                    required_value=req_level,
                    actual_value=actual_level_str,
                    state=CriterionState.MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="EDUCATION_LEVEL",
                    operator=op,
                    required_value=req_level,
                    actual_value=actual_level_str,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) tidak sesuai persyaratan ({req_level})."
                )
        elif op == "IN":
            req_levels = req_level.split(",")
            req_levels = [l.strip() for l in req_levels]
            if actual_level_str in req_levels:
                return CriterionEvaluation(
                    requirement_type="EDUCATION_LEVEL",
                    operator=op,
                    required_value=req_levels,
                    actual_value=actual_level_str,
                    state=CriterionState.MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="EDUCATION_LEVEL",
                    operator=op,
                    required_value=req_levels,
                    actual_value=actual_level_str,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) tidak sesuai persyaratan."
                )

        return self._needs_verification("EDUCATION_LEVEL", op, val, f"Operator '{op}' tidak didukung untuk tingkat pendidikan.")

    def _evaluate_major(self, profile: UserProfile, op: str, val: dict[str, Any], desc: str) -> CriterionEvaluation:
        if "major" not in val and "majors" not in val:
            return self._needs_verification("MAJOR", op, val, "Format nilai jurusan tidak sesuai.")

        actual_major = profile.major

        if actual_major is None or str(actual_major).strip() == "":
            return CriterionEvaluation(
                requirement_type="MAJOR",
                operator=op,
                required_value=val,
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="Jurusan belum tersedia pada profil Anda."
            )

        actual_major_norm = str(actual_major).strip().upper()

        if op == "EQUALS" or op == "EQ":
            req_major = str(val.get("major", "")).strip().upper()
            if actual_major_norm == req_major:
                return CriterionEvaluation(
                    requirement_type="MAJOR",
                    operator=op,
                    required_value=val.get("major"),
                    actual_value=actual_major,
                    state=CriterionState.MATCH,
                    explanation=f"Jurusan Anda ({actual_major}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="MAJOR",
                    operator=op,
                    required_value=val.get("major"),
                    actual_value=actual_major,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Jurusan Anda ({actual_major}) tidak sesuai persyaratan."
                )
        elif op == "IN":
            req_majors = val.get("majors", [])
            if not isinstance(req_majors, list):
                return self._needs_verification("MAJOR", op, val, "Format jurusan untuk IN harus berupa daftar.")

            req_majors_norm = [str(m).strip().upper() for m in req_majors]
            if actual_major_norm in req_majors_norm:
                return CriterionEvaluation(
                    requirement_type="MAJOR",
                    operator=op,
                    required_value=req_majors,
                    actual_value=actual_major,
                    state=CriterionState.MATCH,
                    explanation=f"Jurusan Anda ({actual_major}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type="MAJOR",
                    operator=op,
                    required_value=req_majors,
                    actual_value=actual_major,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Jurusan Anda ({actual_major}) tidak termasuk dalam jurusan yang dipersyaratkan."
                )

        return self._needs_verification("MAJOR", op, val, f"Operator '{op}' tidak didukung untuk jurusan.")

    def _needs_verification(self, req_type: str, op: str, val: Any, reason: str) -> CriterionEvaluation:
        return CriterionEvaluation(
            requirement_type=req_type,
            operator=op,
            required_value=val,
            actual_value=None,
            state=CriterionState.NEEDS_VERIFICATION,
            explanation=reason
        )
