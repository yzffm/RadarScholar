// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CriterionEvaluationImpl _$$CriterionEvaluationImplFromJson(
  Map<String, dynamic> json,
) => _$CriterionEvaluationImpl(
  requirementType: json['requirement_type'] as String,
  operator: json['operator'] as String,
  requiredValue: json['required_value'],
  actualValue: json['actual_value'],
  state: $enumDecode(_$CriterionStateEnumMap, json['state']),
  explanation: json['explanation'] as String,
);

Map<String, dynamic> _$$CriterionEvaluationImplToJson(
  _$CriterionEvaluationImpl instance,
) => <String, dynamic>{
  'requirement_type': instance.requirementType,
  'operator': instance.operator,
  'required_value': instance.requiredValue,
  'actual_value': instance.actualValue,
  'state': _$CriterionStateEnumMap[instance.state]!,
  'explanation': instance.explanation,
};

const _$CriterionStateEnumMap = {
  CriterionState.match: 'MATCH',
  CriterionState.notMatch: 'NOT_MATCH',
  CriterionState.unknown: 'UNKNOWN',
  CriterionState.notApplicable: 'NOT_APPLICABLE',
  CriterionState.needsVerification: 'NEEDS_VERIFICATION',
};

_$MatchResultImpl _$$MatchResultImplFromJson(Map<String, dynamic> json) =>
    _$MatchResultImpl(
      relevance: $enumDecode(_$RelevanceTierEnumMap, json['relevance']),
      criterionEvaluations: (json['criterion_evaluations'] as List<dynamic>)
          .map((e) => CriterionEvaluation.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchedCount: (json['matched_count'] as num).toInt(),
      notMatchedCount: (json['not_matched_count'] as num).toInt(),
      unknownCount: (json['unknown_count'] as num).toInt(),
      needsVerificationCount: (json['needs_verification_count'] as num).toInt(),
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$$MatchResultImplToJson(_$MatchResultImpl instance) =>
    <String, dynamic>{
      'relevance': _$RelevanceTierEnumMap[instance.relevance]!,
      'criterion_evaluations': instance.criterionEvaluations,
      'matched_count': instance.matchedCount,
      'not_matched_count': instance.notMatchedCount,
      'unknown_count': instance.unknownCount,
      'needs_verification_count': instance.needsVerificationCount,
      'explanation': instance.explanation,
    };

const _$RelevanceTierEnumMap = {
  RelevanceTier.sangatRelevan: 'SANGAT_RELEVAN',
  RelevanceTier.relevan: 'RELEVAN',
  RelevanceTier.mungkinRelevan: 'MUNGKIN_RELEVAN',
  RelevanceTier.perluDicek: 'PERLU_DICEK',
  RelevanceTier.belumCukupInformasi: 'BELUM_CUKUP_INFORMASI',
  RelevanceTier.tidakMemenuhi: 'TIDAK_MEMENUHI',
};
