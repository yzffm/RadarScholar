"""Pure data and functions for Indonesian university name normalization and matching."""

from __future__ import annotations

import re
from difflib import SequenceMatcher

UNIVERSITY_ALIASES: dict[str, str] = {
    # Universitas Indonesia
    "universitas indonesia": "universitas indonesia",
    "ui": "universitas indonesia",
    # Universitas Gadjah Mada
    "universitas gadjah mada": "universitas gadjah mada",
    "ugm": "universitas gadjah mada",
    # Institut Teknologi Bandung
    "institut teknologi bandung": "institut teknologi bandung",
    "itb": "institut teknologi bandung",
    # Institut Pertanian Bogor / IPB University
    "institut pertanian bogor": "institut pertanian bogor",
    "ipb university": "institut pertanian bogor",
    "ipb": "institut pertanian bogor",
    # Universitas Diponegoro
    "universitas diponegoro": "universitas diponegoro",
    "undip": "universitas diponegoro",
    # Universitas Brawijaya
    "universitas brawijaya": "universitas brawijaya",
    "ub": "universitas brawijaya",
    "unibraw": "universitas brawijaya",
    # Universitas Hasanuddin
    "universitas hasanuddin": "universitas hasanuddin",
    "unhas": "universitas hasanuddin",
    # Universitas Sumatera Utara
    "universitas sumatera utara": "universitas sumatera utara",
    "usu": "universitas sumatera utara",
    # Universitas Riau
    "universitas riau": "universitas riau",
    "unri": "universitas riau",
    # Universitas Mulawarman
    "universitas mulawarman": "universitas mulawarman",
    "unmul": "universitas mulawarman",
    # Universitas Negeri Surabaya
    "universitas negeri surabaya": "universitas negeri surabaya",
    "unesa": "universitas negeri surabaya",
    # Universitas Airlangga
    "universitas airlangga": "universitas airlangga",
    "unair": "universitas airlangga",
    # Institut Teknologi Sepuluh Nopember
    "institut teknologi sepuluh nopember": "institut teknologi sepuluh nopember",
    "institut teknologi sepuluh november": "institut teknologi sepuluh nopember",
    "its": "institut teknologi sepuluh nopember",
    # Universitas Padjadjaran
    "universitas padjadjaran": "universitas padjadjaran",
    "unpad": "universitas padjadjaran",
    # Universitas Sebelas Maret
    "universitas sebelas maret": "universitas sebelas maret",
    "uns": "universitas sebelas maret",
    # Universitas Pendidikan Indonesia
    "universitas pendidikan indonesia": "universitas pendidikan indonesia",
    "upi": "universitas pendidikan indonesia",
    # Universitas Negeri Yogyakarta
    "universitas negeri yogyakarta": "universitas negeri yogyakarta",
    "uny": "universitas negeri yogyakarta",
    # Universitas Negeri Malang
    "universitas negeri malang": "universitas negeri malang",
    "um": "universitas negeri malang",
    # Universitas Negeri Semarang
    "universitas negeri semarang": "universitas negeri semarang",
    "unnes": "universitas negeri semarang",
    # Universitas Jenderal Soedirman
    "universitas jenderal soedirman": "universitas jenderal soedirman",
    "unsoed": "universitas jenderal soedirman",
    # Universitas Sriwijaya
    "universitas sriwijaya": "universitas sriwijaya",
    "unsri": "universitas sriwijaya",
    # Universitas Andalas
    "universitas andalas": "universitas andalas",
    "unand": "universitas andalas",
    # Universitas Syiah Kuala
    "universitas syiah kuala": "universitas syiah kuala",
    "usk": "universitas syiah kuala",
    "unsyiah": "universitas syiah kuala",
    # Universitas Udayana
    "universitas udayana": "universitas udayana",
    "unud": "universitas udayana",
    # Universitas Lampung
    "universitas lampung": "universitas lampung",
    "unila": "universitas lampung",
    # BINUS University
    "universitas bina nusantara": "universitas bina nusantara",
    "binus university": "universitas bina nusantara",
    "binus": "universitas bina nusantara",
    # Telkom University
    "universitas telkom": "universitas telkom",
    "telkom university": "universitas telkom",
    "tel u": "universitas telkom",
    # Universitas Islam Indonesia
    "universitas islam indonesia": "universitas islam indonesia",
    "uii": "universitas islam indonesia",
    # Universitas Muhammadiyah Yogyakarta
    "universitas muhammadiyah yogyakarta": "universitas muhammadiyah yogyakarta",
    "umy": "universitas muhammadiyah yogyakarta",
    # Universitas Katolik Parahyangan
    "universitas katolik parahyangan": "universitas katolik parahyangan",
    "unpar": "universitas katolik parahyangan",
    # Universitas Surabaya
    "universitas surabaya": "universitas surabaya",
    "ubaya": "universitas surabaya",
    # Universitas Sam Ratulangi
    "universitas sam ratulangi": "universitas sam ratulangi",
    "unsrat": "universitas sam ratulangi",
    # Universitas Tanjungpura
    "universitas tanjungpura": "universitas tanjungpura",
    "untan": "universitas tanjungpura",
    # Universitas Jember
    "universitas jember": "universitas jember",
    "unej": "universitas jember",
    # Universitas Mataram
    "universitas mataram": "universitas mataram",
    "unram": "universitas mataram",
    # Universitas Negeri Jakarta
    "universitas negeri jakarta": "universitas negeri jakarta",
    "unj": "universitas negeri jakarta",
    # Universitas Negeri Padang
    "universitas negeri padang": "universitas negeri padang",
    "unp": "universitas negeri padang",
    # Universitas Negeri Medan
    "universitas negeri medan": "universitas negeri medan",
    "unimed": "universitas negeri medan",
    # Universitas Negeri Makassar
    "universitas negeri makassar": "universitas negeri makassar",
    "unm": "universitas negeri makassar",
    # Politeknik Elektronika Negeri Surabaya
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

GENERIC_UNIVERSITY_WORDS: frozenset[str] = frozenset(
    {
        "universitas",
        "institut",
        "negeri",
        "politeknik",
        "univ",
        "inst",
        "university",
        "institute",
        "perguruan",
        "tinggi",
        "sekolah",
        "akademi",
        "kampus",
        "ptn",
        "pts",
    }
)

_PREFIX_EXPANSIONS: dict[str, str] = {
    "univ": "universitas",
    "inst": "institut",
}


def normalize_university_name(raw_name: str) -> str:
    """Lowercase, strip punctuation, collapse spaces, and expand 'univ'/'inst' tokens."""
    cleaned = re.sub(r"[^a-z0-9\s]", " ", raw_name.lower())
    tokens = [_PREFIX_EXPANSIONS.get(tok, tok) for tok in cleaned.split()]
    return " ".join(tokens)


def resolve_university_alias(raw_name: str) -> str | None:
    """Resolve ``raw_name`` to its canonical university name via ``UNIVERSITY_ALIASES``.

    Returns ``None`` if ``raw_name`` is not a known alias or official name in the table.
    """
    norm = normalize_university_name(raw_name)
    if not norm:
        return None

    if norm in UNIVERSITY_ALIASES:
        return UNIVERSITY_ALIASES[norm]

    # Support "Full Name (ACRONYM)" or "ACRONYM (Full Name)" when both map to the same canonical name
    paren_match = re.search(r"\(([^)]+)\)", raw_name)
    if paren_match:
        inner_norm = normalize_university_name(paren_match.group(1))
        outer_norm = normalize_university_name(re.sub(r"\([^)]*\)", " ", raw_name))
        inner_canon = UNIVERSITY_ALIASES.get(inner_norm)
        outer_canon = UNIVERSITY_ALIASES.get(outer_norm)
        if inner_canon and outer_canon and inner_canon == outer_canon:
            return inner_canon

    return None


def extract_core_university_tokens(raw_name: str) -> list[str]:
    """Return normalized tokens after removing generic institutional words."""
    norm = normalize_university_name(raw_name)
    return [tok for tok in norm.split() if tok not in GENERIC_UNIVERSITY_WORDS]


def _aliases_for_canonical(canonical_name: str) -> set[str]:
    return {
        alias
        for alias, canon in UNIVERSITY_ALIASES.items()
        if canon == canonical_name and alias != canonical_name
    }


def is_similar_to_any_partner(
    raw_name: str,
    partner_names: list[str],
    ratio_threshold: float = 0.8,
) -> bool:
    """Return ``True`` if ``raw_name`` is similar to any partner in ``partner_names``.

    Similarity is computed on normalized names with generic words stripped
    (``universitas``, ``institut``, ``negeri``, ``politeknik``, ``univ``, etc.)
    using either ``difflib.SequenceMatcher`` ratio >= ``ratio_threshold`` or
    significant non-generic token overlap.
    """
    actual_core = extract_core_university_tokens(raw_name)
    if not actual_core:
        # Input contains only generic words or punctuation -> ambiguous, needs verification
        return True

    actual_core_str = " ".join(actual_core)
    actual_core_set = set(actual_core)

    for partner in partner_names:
        partner_canon = resolve_university_alias(partner) or normalize_university_name(partner)
        partner_core = extract_core_university_tokens(partner_canon)
        if not partner_core:
            continue

        partner_core_str = " ".join(partner_core)
        partner_core_set = set(partner_core)

        # 1. Fuzzy character similarity on non-generic core strings (catches typos)
        if SequenceMatcher(None, actual_core_str, partner_core_str).ratio() >= ratio_threshold:
            return True

        # 2. Significant token overlap (e.g., partner name + city/faculty, or partial core name)
        if partner_core_set.issubset(actual_core_set) or actual_core_set.issubset(partner_core_set):
            return True

        overlap = actual_core_set & partner_core_set
        if overlap and (len(overlap) / min(len(actual_core_set), len(partner_core_set))) >= 0.5:
            return True

        # 3. Partner short alias appears as a token in actual input (e.g. "Univ. IPB", "ITB Bandung")
        partner_aliases = _aliases_for_canonical(partner_canon)
        if actual_core_set & partner_aliases:
            return True

        # 4. Token-level fuzzy match when extra city/faculty token is present alongside a typo
        if all(
            any(
                SequenceMatcher(None, a_tok, p_tok).ratio() >= ratio_threshold
                for a_tok in actual_core
            )
            for p_tok in partner_core
        ):
            return True

    return False
