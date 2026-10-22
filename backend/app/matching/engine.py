import re
from typing import Any

from app.matching.schemas import CriterionEvaluation, CriterionState
from app.scholarships.models import ScholarshipRequirement
from app.users.models import UserProfile

_UNIVERSITY_ALIASES: dict[str, str] = {
    # UI
    "universitas indonesia": "universitas indonesia",
    "ui": "universitas indonesia",
    # UGM
    "universitas gadjah mada": "universitas gadjah mada",
    "universitas gajah mada": "universitas gadjah mada",
    "ugm": "universitas gadjah mada",
    # ITB
    "institut teknologi bandung": "institut teknologi bandung",
    "itb": "institut teknologi bandung",
    # IPB
    "institut pertanian bogor": "institut pertanian bogor",
    "ipb university": "institut pertanian bogor",
    "ipb": "institut pertanian bogor",
    # UNDIP
    "universitas diponegoro": "universitas diponegoro",
    "undip": "universitas diponegoro",
    # UB
    "universitas brawijaya": "universitas brawijaya",
    "ub": "universitas brawijaya",
    "unibraw": "universitas brawijaya",
    # UNHAS
    "universitas hasanuddin": "universitas hasanuddin",
    "unhas": "universitas hasanuddin",
    # USU
    "universitas sumatera utara": "universitas sumatera utara",
    "usu": "universitas sumatera utara",
    # UNRI
    "universitas riau": "universitas riau",
    "unri": "universitas riau",
    # UNMUL
    "universitas mulawarman": "universitas mulawarman",
    "unmul": "universitas mulawarman",
    # UNESA
    "universitas negeri surabaya": "universitas negeri surabaya",
    "unesa": "universitas negeri surabaya",
    # UNAIR
    "universitas airlangga": "universitas airlangga",
    "unair": "universitas airlangga",
    # ITS
    "institut teknologi sepuluh nopember": "institut teknologi sepuluh nopember",
    "institut teknologi sepuluh november": "institut teknologi sepuluh nopember",
    "its": "institut teknologi sepuluh nopember",
    # UNPAD
    "universitas padjadjaran": "universitas padjadjaran",
    "unpad": "universitas padjadjaran",
    # UNS
    "universitas sebelas maret": "universitas sebelas maret",
    "uns": "universitas sebelas maret",
    # UPI
    "universitas pendidikan indonesia": "universitas pendidikan indonesia",
    "upi": "universitas pendidikan indonesia",
    # UNY
    "universitas negeri yogyakarta": "universitas negeri yogyakarta",
    "uny": "universitas negeri yogyakarta",
    # UM
    "universitas negeri malang": "universitas negeri malang",
    "um": "universitas negeri malang",
    # UNNES
    "universitas negeri semarang": "universitas negeri semarang",
    "unnes": "universitas negeri semarang",
    # UNSOED
    "universitas jenderal soedirman": "universitas jenderal soedirman",
    "unsoed": "universitas jenderal soedirman",
    # UNSRI
    "universitas sriwijaya": "universitas sriwijaya",
    "unsri": "universitas sriwijaya",
    # UNAND
    "universitas andalas": "universitas andalas",
    "unand": "universitas andalas",
    # USK / UNSYIAH
    "universitas syiah kuala": "universitas syiah kuala",
    "usk": "universitas syiah kuala",
    "unsyiah": "universitas syiah kuala",
    # UNUD
    "universitas udayana": "universitas udayana",
    "unud": "universitas udayana",
    # UNILA
    "universitas lampung": "universitas lampung",
    "unila": "universitas lampung",
    # BINUS
    "universitas bina nusantara": "universitas bina nusantara",
    "binus university": "universitas bina nusantara",
    "binus": "universitas bina nusantara",
    # Telkom University
    "universitas telkom": "universitas telkom",
    "telkom university": "universitas telkom",
    "tel u": "universitas telkom",
    # UII
    "universitas islam indonesia": "universitas islam indonesia",
    "uii": "universitas islam indonesia",
    # UMY
    "universitas muhammadiyah yogyakarta": "universitas muhammadiyah yogyakarta",
    "umy": "universitas muhammadiyah yogyakarta",
    # UNPAR
    "universitas katolik parahyangan": "universitas katolik parahyangan",
    "unpar": "universitas katolik parahyangan",
    # UBAYA
    "universitas surabaya": "universitas surabaya",
    "ubaya": "universitas surabaya",
    # UNSRAT
    "universitas sam ratulangi": "universitas sam ratulangi",
    "unsrat": "universitas sam ratulangi",
    # UNTAN
    "universitas tanjungpura": "universitas tanjungpura",
    "untan": "universitas tanjungpura",
    # UNEJ
    "universitas jember": "universitas jember",
    "unej": "universitas jember",
    # UNRAM
    "universitas mataram": "universitas mataram",
    "unram": "universitas mataram",
    # UNJ
    "universitas negeri jakarta": "universitas negeri jakarta",
    "unj": "universitas negeri jakarta",
    # UNP
    "universitas negeri padang": "universitas negeri padang",
    "unp": "universitas negeri padang",
    # UNIMED
    "universitas negeri medan": "universitas negeri medan",
    "unimed": "universitas negeri medan",
    # UNM
    "universitas negeri makassar": "universitas negeri makassar",
    "unm": "universitas negeri makassar",
    # PENS
    "politeknik elektronika negeri surabaya": "politeknik elektronika negeri surabaya",
    "pens": "politeknik elektronika negeri surabaya",
    # UPN Veteran
    "universitas pembangunan nasional veteran jakarta": "universitas pembangunan nasional veteran jakarta",
    "upn veteran jakarta": "universitas pembangunan nasional veteran jakarta",
    "upnvj": "universitas pembangunan nasional veteran jakarta",
    "universitas pembangunan nasional veteran yogyakarta": "universitas pembangunan nasional veteran yogyakarta",
    "upn veteran yogyakarta": "universitas pembangunan nasional veteran yogyakarta",
    "upnvy": "universitas pembangunan nasional veteran yogyakarta",
    "universitas pembangunan nasional veteran jawa timur": "universitas pembangunan nasional veteran jawa timur",
    "upn veteran jawa timur": "universitas pembangunan nasional veteran jawa timur",
    "upnvjt": "universitas pembangunan nasional veteran jawa timur",
}

_AMBIGUOUS_UNIVERSITY_TERMS: frozenset[str] = frozenset(
    {
        "universitas",
        "institut",
        "politeknik",
        "sekolah tinggi",
        "akademi",
        "kampus",
        "ptn",
        "pts",
        "perguruan tinggi",
        "perguruan tinggi negeri",
        "perguruan tinggi swasta",
        "universitas negeri",
        "universitas islam",
        "universitas islam negeri",
        "universitas muhammadiyah",
        "universitas katolik",
        "universitas kristen",
        "universitas pembangunan nasional",
        "institut teknologi",
        "institut seni",
        "institut agama islam negeri",
        "politeknik negeri",
        "sekolah tinggi ilmu ekonomi",
        "sekolah tinggi teknologi",
    }
)

_SPECIFIC_INSTITUTION_PREFIXES: tuple[str, ...] = (
    "universitas ",
    "institut ",
    "politeknik ",
    "sekolah tinggi ",
    "akademi ",
    "uin ",
    "iain ",
)

_SPECIFIC_INSTITUTION_SUFFIXES: tuple[str, ...] = (
    " university",
    " institute",
    " polytechnic",
    " college",
)

_NATIONALITY_ALIASES: dict[str, str] = {
    "indonesia": "indonesia",
    "wni": "indonesia",
    "warga negara indonesia": "indonesia",
    "indonesian": "indonesia",
    "republik indonesia": "indonesia",
    "id": "indonesia",
    "idn": "indonesia",
    "wna": "wna",
    "warga negara asing": "wna",
}


def _normalize_text(value: str) -> str:
    """Lowercase, strip punctuation, and collapse whitespace."""
    cleaned = re.sub(r"[^a-z0-9\s]", " ", value.lower())
    return " ".join(cleaned.split())


def _canonicalize_university(raw_name: str) -> tuple[str, bool, bool]:
    """Return ``(canonical_name, is_in_alias_table, is_confident_specific)``."""
    norm = _normalize_text(raw_name)
    if not norm:
        return "", False, False

    if norm in _UNIVERSITY_ALIASES:
        return _UNIVERSITY_ALIASES[norm], True, True

    # Support combined "Full Name (ACRONYM)" or "ACRONYM (Full Name)" inputs
    paren_match = re.search(r"\(([^)]+)\)", raw_name)
    if paren_match:
        inner_norm = _normalize_text(paren_match.group(1))
        outer_norm = _normalize_text(re.sub(r"\([^)]*\)", " ", raw_name))
        inner_canon = _UNIVERSITY_ALIASES.get(inner_norm)
        outer_canon = _UNIVERSITY_ALIASES.get(outer_norm)
        if inner_canon and outer_canon and inner_canon == outer_canon:
            return inner_canon, True, True
        if outer_canon and not inner_norm:
            return outer_canon, True, True

    if norm in _AMBIGUOUS_UNIVERSITY_TERMS:
        return norm, False, False

    tokens = norm.split()
    if len(tokens) < 2:
        # Unknown single-word token/abbreviation is ambiguous
        return norm, False, False

    has_institution_marker = norm.startswith(_SPECIFIC_INSTITUTION_PREFIXES) or norm.endswith(
        _SPECIFIC_INSTITUTION_SUFFIXES
    )
    return norm, False, has_institution_marker


def _canonicalize_nationality(raw_value: str) -> str:
    norm = _normalize_text(raw_value)
    if not norm:
        return ""
    return _NATIONALITY_ALIASES.get(norm, norm)



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
            return self._evaluate_education_level(profile, req_type, op, val, desc)
        elif req_type == "MAJOR":
            return self._evaluate_major(profile, op, val, desc)
        elif req_type == "UNIVERSITY":
            return self._evaluate_university(profile, op, val, desc)
        elif req_type in ("NATIONALITY", "CITIZENSHIP"):
            return self._evaluate_nationality(profile, req_type, op, val, desc)
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

    def _evaluate_education_level(
        self,
        profile: UserProfile,
        req_type: str,
        op: str,
        val: dict[str, Any],
        desc: str,
    ) -> CriterionEvaluation:
        if not isinstance(val, dict):
            return self._needs_verification(
                req_type, op, val, "Format tingkat pendidikan tidak sesuai."
            )

        raw_levels = val.get("levels")
        if raw_levels is None:
            raw_levels = val.get("level")
        if raw_levels is None:
            return self._needs_verification(
                req_type, op, val, "Format tingkat pendidikan tidak sesuai."
            )

        if isinstance(raw_levels, list):
            req_levels = [str(level).strip().upper() for level in raw_levels]
        else:
            req_levels = [
                level.strip().upper() for level in str(raw_levels).split(",")
            ]

        if not req_levels or any(not level for level in req_levels):
            return self._needs_verification(
                req_type, op, val, "Daftar tingkat pendidikan tidak valid."
            )

        actual_level = profile.degree_level

        if actual_level is None:
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=req_levels if op == "IN" else req_levels[0],
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="Tingkat pendidikan belum tersedia pada profil Anda."
            )

        actual_level_str = actual_level.value.upper()

        if op == "EQUALS" or op == "EQ":
            if len(req_levels) != 1:
                return self._needs_verification(
                    req_type,
                    op,
                    val,
                    "Operator EQ hanya mendukung satu tingkat pendidikan.",
                )
            required_level = req_levels[0]
            if actual_level_str == required_level:
                return CriterionEvaluation(
                    requirement_type=req_type,
                    operator=op,
                    required_value=required_level,
                    actual_value=actual_level_str,
                    state=CriterionState.MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type=req_type,
                    operator=op,
                    required_value=required_level,
                    actual_value=actual_level_str,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) tidak sesuai persyaratan ({required_level})."
                )
        elif op == "IN":
            if actual_level_str in req_levels:
                return CriterionEvaluation(
                    requirement_type=req_type,
                    operator=op,
                    required_value=req_levels,
                    actual_value=actual_level_str,
                    state=CriterionState.MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) sesuai persyaratan."
                )
            else:
                return CriterionEvaluation(
                    requirement_type=req_type,
                    operator=op,
                    required_value=req_levels,
                    actual_value=actual_level_str,
                    state=CriterionState.NOT_MATCH,
                    explanation=f"Tingkat pendidikan Anda ({actual_level_str}) tidak sesuai persyaratan."
                )

        return self._needs_verification(req_type, op, val, f"Operator '{op}' tidak didukung untuk tingkat pendidikan.")

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

    def _evaluate_university(
        self,
        profile: UserProfile,
        op: str,
        val: dict[str, Any],
        desc: str,
    ) -> CriterionEvaluation:
        if not isinstance(val, dict) or ("university" not in val and "universities" not in val):
            return self._needs_verification(
                "UNIVERSITY", op, val, "Format nilai perguruan tinggi tidak sesuai."
            )

        if op in ("EQUALS", "EQ"):
            raw_uni = val.get("university")
            if raw_uni is None:
                raw_list = val.get("universities")
                if isinstance(raw_list, list) and len(raw_list) == 1:
                    raw_uni = raw_list[0]
            if not isinstance(raw_uni, str) or not raw_uni.strip():
                return self._needs_verification(
                    "UNIVERSITY", op, val, "Format nilai perguruan tinggi untuk EQ tidak sesuai."
                )
            req_universities = [raw_uni.strip()]
            required_display: Any = req_universities[0]
        elif op == "IN":
            raw_list = val.get("universities")
            if not isinstance(raw_list, list) or not raw_list:
                return self._needs_verification(
                    "UNIVERSITY", op, val, "Format perguruan tinggi untuk IN harus berupa daftar."
                )
            req_universities = [str(u).strip() for u in raw_list if str(u).strip()]
            if len(req_universities) != len(raw_list):
                return self._needs_verification(
                    "UNIVERSITY", op, val, "Daftar perguruan tinggi mengandung nilai kosong."
                )
            required_display = req_universities
        else:
            return self._needs_verification(
                "UNIVERSITY", op, val, f"Operator '{op}' tidak didukung untuk perguruan tinggi."
            )

        actual_uni = profile.university
        if actual_uni is None or str(actual_uni).strip() == "":
            return CriterionEvaluation(
                requirement_type="UNIVERSITY",
                operator=op,
                required_value=required_display,
                actual_value=None,
                state=CriterionState.UNKNOWN,
                explanation="Perguruan tinggi belum tersedia pada profil Anda.",
            )

        req_canon_set: set[str] = set()
        for req_u in req_universities:
            canon_u, _, _ = _canonicalize_university(req_u)
            if not canon_u:
                return self._needs_verification(
                    "UNIVERSITY", op, val, "Nama perguruan tinggi pada persyaratan tidak valid."
                )
            req_canon_set.add(canon_u)

        actual_canon, is_in_alias_table, is_confident_specific = _canonicalize_university(
            str(actual_uni)
        )
        if not actual_canon:
            return CriterionEvaluation(
                requirement_type="UNIVERSITY",
                operator=op,
                required_value=required_display,
                actual_value=actual_uni,
                state=CriterionState.NEEDS_VERIFICATION,
                explanation=(
                    f"Nama perguruan tinggi pada profil Anda ({actual_uni}) "
                    "perlu diverifikasi terhadap daftar perguruan tinggi mitra."
                ),
            )

        if actual_canon in req_canon_set:
            return CriterionEvaluation(
                requirement_type="UNIVERSITY",
                operator=op,
                required_value=required_display,
                actual_value=actual_uni,
                state=CriterionState.MATCH,
                explanation=f"Perguruan tinggi Anda ({actual_uni}) sesuai persyaratan.",
            )

        # Guard against partial/substring ambiguity when user input is not a known alias
        if not is_in_alias_table:
            has_partial_overlap = any(
                actual_canon in req_c or req_c in actual_canon for req_c in req_canon_set
            )
            if has_partial_overlap or not is_confident_specific:
                return CriterionEvaluation(
                    requirement_type="UNIVERSITY",
                    operator=op,
                    required_value=required_display,
                    actual_value=actual_uni,
                    state=CriterionState.NEEDS_VERIFICATION,
                    explanation=(
                        f"Nama perguruan tinggi pada profil Anda ({actual_uni}) tidak dapat "
                        "dipastikan kecocokannya secara otomatis; silakan verifikasi manual."
                    ),
                )

        return CriterionEvaluation(
            requirement_type="UNIVERSITY",
            operator=op,
            required_value=required_display,
            actual_value=actual_uni,
            state=CriterionState.NOT_MATCH,
            explanation=(
                f"Perguruan tinggi Anda ({actual_uni}) tidak termasuk dalam "
                "perguruan tinggi yang dipersyaratkan."
            ),
        )

    def _evaluate_nationality(
        self,
        profile: UserProfile,
        req_type: str,
        op: str,
        val: dict[str, Any],
        desc: str,
    ) -> CriterionEvaluation:
        if not isinstance(val, dict):
            return self._needs_verification(
                req_type, op, val, "Format nilai kewarganegaraan tidak sesuai."
            )

        raw_countries = (
            val.get("countries")
            or val.get("nationalities")
            or val.get("country")
            or val.get("nationality")
        )
        if raw_countries is None:
            return self._needs_verification(
                req_type, op, val, "Format nilai kewarganegaraan tidak sesuai."
            )

        if isinstance(raw_countries, list):
            req_countries = [str(c).strip() for c in raw_countries if str(c).strip()]
            if not req_countries or len(req_countries) != len(raw_countries):
                return self._needs_verification(
                    req_type, op, val, "Daftar kewarganegaraan tidak valid."
                )
        elif isinstance(raw_countries, str) and raw_countries.strip():
            req_countries = [raw_countries.strip()]
        else:
            return self._needs_verification(
                req_type, op, val, "Format nilai kewarganegaraan tidak sesuai."
            )

        if op in ("EQUALS", "EQ"):
            if len(req_countries) != 1:
                return self._needs_verification(
                    req_type, op, val, "Operator EQ hanya mendukung satu kewarganegaraan."
                )
            required_display: Any = req_countries[0]
        elif op == "IN":
            required_display = req_countries
        else:
            return self._needs_verification(
                req_type, op, val, f"Operator '{op}' tidak didukung untuk kewarganegaraan."
            )

        actual_nationality = getattr(profile, "nationality", None)
        if actual_nationality is None or str(actual_nationality).strip() == "":
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=required_display,
                actual_value=None,
                state=CriterionState.NEEDS_VERIFICATION,
                explanation=(
                    "Data kewarganegaraan belum tercatat pada skema profil pengguna; "
                    f"silakan pastikan Anda memenuhi syarat kewarganegaraan ({', '.join(req_countries)})."
                ),
            )

        actual_canon = _canonicalize_nationality(str(actual_nationality))
        req_canon_set = {_canonicalize_nationality(c) for c in req_countries}
        if not actual_canon:
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=required_display,
                actual_value=actual_nationality,
                state=CriterionState.NEEDS_VERIFICATION,
                explanation=(
                    f"Kewarganegaraan pada profil ({actual_nationality}) perlu diverifikasi "
                    f"terhadap persyaratan ({', '.join(req_countries)})."
                ),
            )

        if actual_canon in req_canon_set:
            return CriterionEvaluation(
                requirement_type=req_type,
                operator=op,
                required_value=required_display,
                actual_value=actual_nationality,
                state=CriterionState.MATCH,
                explanation=f"Kewarganegaraan Anda ({actual_nationality}) sesuai persyaratan.",
            )

        return CriterionEvaluation(
            requirement_type=req_type,
            operator=op,
            required_value=required_display,
            actual_value=actual_nationality,
            state=CriterionState.NOT_MATCH,
            explanation=(
                f"Kewarganegaraan Anda ({actual_nationality}) tidak sesuai persyaratan "
                f"({', '.join(req_countries)})."
            ),
        )

    def _needs_verification(self, req_type: str, op: str, val: Any, reason: str) -> CriterionEvaluation:
        return CriterionEvaluation(
            requirement_type=req_type,
            operator=op,
            required_value=val,
            actual_value=None,
            state=CriterionState.NEEDS_VERIFICATION,
            explanation=reason
        )
