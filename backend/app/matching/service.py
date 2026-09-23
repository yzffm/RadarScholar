from typing import List

from app.matching.engine import MatchingEngine
from app.matching.schemas import CriterionState, MatchResult, RelevanceTier, CriterionEvaluation
from app.scholarships.models import Scholarship
from app.users.models import UserProfile


class MatchingService:
    def __init__(self, engine: MatchingEngine = None):
        self.engine = engine or MatchingEngine()

    def match(self, profile: UserProfile, scholarship: Scholarship) -> MatchResult:
        """Evaluates a scholarship against a user profile to generate a match result."""
        evaluations: List[CriterionEvaluation] = []
        
        matched_count = 0
        not_matched_count = 0
        unknown_count = 0
        needs_verification_count = 0

        for req in scholarship.requirements:
            eval_result = self.engine.evaluate(profile, req)
            evaluations.append(eval_result)
            
            if eval_result.state == CriterionState.MATCH:
                matched_count += 1
            elif eval_result.state == CriterionState.NOT_MATCH:
                not_matched_count += 1
            elif eval_result.state == CriterionState.UNKNOWN:
                unknown_count += 1
            elif eval_result.state == CriterionState.NEEDS_VERIFICATION:
                needs_verification_count += 1

        relevance = self._determine_relevance(
            matched_count=matched_count,
            not_matched_count=not_matched_count,
            unknown_count=unknown_count,
            needs_verification_count=needs_verification_count,
            total_count=len(scholarship.requirements)
        )
        
        explanation = self._generate_overall_explanation(relevance, not_matched_count)

        return MatchResult(
            relevance=relevance,
            criterion_evaluations=evaluations,
            matched_count=matched_count,
            not_matched_count=not_matched_count,
            unknown_count=unknown_count,
            needs_verification_count=needs_verification_count,
            explanation=explanation
        )

    def _determine_relevance(
        self, 
        matched_count: int, 
        not_matched_count: int, 
        unknown_count: int, 
        needs_verification_count: int, 
        total_count: int
    ) -> RelevanceTier:
        
        if total_count == 0:
            return RelevanceTier.PERLU_DICEK
            
        if not_matched_count > 0:
            return RelevanceTier.TIDAK_MEMENUHI

        if matched_count == total_count:
            return RelevanceTier.SANGAT_RELEVAN
            
        if matched_count > 0 and unknown_count == 0 and needs_verification_count == 0:
            return RelevanceTier.SANGAT_RELEVAN
            
        if matched_count > 0 and unknown_count > 0 and needs_verification_count == 0:
            if matched_count >= unknown_count:
                return RelevanceTier.RELEVAN
            else:
                return RelevanceTier.MUNGKIN_RELEVAN

        if needs_verification_count > 0:
            return RelevanceTier.PERLU_DICEK
            
        if matched_count == 0 and unknown_count > 0:
            return RelevanceTier.BELUM_CUKUP_INFORMASI
            
        return RelevanceTier.PERLU_DICEK

    def _generate_overall_explanation(self, relevance: RelevanceTier, not_matched_count: int) -> str:
        if relevance == RelevanceTier.SANGAT_RELEVAN:
            return "Profil Anda memenuhi semua kualifikasi utama."
        elif relevance == RelevanceTier.RELEVAN:
            return "Profil Anda memenuhi sebagian besar kualifikasi utama. Beberapa data belum lengkap."
        elif relevance == RelevanceTier.MUNGKIN_RELEVAN:
            return "Beberapa kualifikasi terpenuhi, namun banyak informasi yang belum tersedia di profil Anda."
        elif relevance == RelevanceTier.PERLU_DICEK:
            return "Beberapa persyaratan memerlukan verifikasi manual atau tidak dapat dievaluasi secara otomatis."
        elif relevance == RelevanceTier.BELUM_CUKUP_INFORMASI:
            return "Data profil Anda belum cukup untuk melakukan evaluasi kecocokan secara akurat."
        elif relevance == RelevanceTier.TIDAK_MEMENUHI:
            return f"Ada {not_matched_count} persyaratan yang tidak terpenuhi oleh profil Anda."
        
        return "Status kecocokan tidak dapat dipastikan."
