// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CriterionEvaluationImpl _$$CriterionEvaluationImplFromJson(
  Map<String, dynamic> json,
) => _$CriterionEvaluationImpl(
  requirementType: json['requirementType'] as String,
  operator: json['operator'] as String,
  requiredValue: json['requiredValue'],
  actualValue: json['actualValue'],
  state: $enumDecode(_$CriterionStateEnumMap, json['state']),
  explanation: json['explanation'] as String,
);

Map<String, dynamic> _$$CriterionEvaluationImplToJson(
  _$CriterionEvaluationImpl instance,
) => <String, dynamic>{
  'requirementType': instance.requirementType,
  'operator': instance.operator,
  'requiredValue': instance.requiredValue,
  'actualValue': instance.actualValue,
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
      criterionEvaluations: (json['criterionEvaluations'] as List<dynamic>)
          .map((e) => CriterionEvaluation.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchedCount: (json['matchedCount'] as num).toInt(),
      notMatchedCount: (json['notMatchedCount'] as num).toInt(),
      unknownCount: (json['unknownCount'] as num).toInt(),
      needsVerificationCount: (json['needsVerificationCount'] as num).toInt(),
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$$MatchResultImplToJson(_$MatchResultImpl instance) =>
    <String, dynamic>{
      'relevance': _$RelevanceTierEnumMap[instance.relevance]!,
      'criterionEvaluations': instance.criterionEvaluations,
      'matchedCount': instance.matchedCount,
      'notMatchedCount': instance.notMatchedCount,
      'unknownCount': instance.unknownCount,
      'needsVerificationCount': instance.needsVerificationCount,
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
