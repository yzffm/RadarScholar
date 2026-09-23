import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_result.freezed.dart';
part 'match_result.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CriterionState {
  match,
  notMatch,
  unknown,
  notApplicable,
  needsVerification,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RelevanceTier {
  sangatRelevan,
  relevan,
  mungkinRelevan,
  perluDicek,
  belumCukupInformasi,
  tidakMemenuhi,
}

@freezed
class CriterionEvaluation with _$CriterionEvaluation {
  const factory CriterionEvaluation({
    @JsonKey(name: 'requirement_type') required String requirementType,
    required String operator,
    @JsonKey(name: 'required_value') required dynamic requiredValue,
    @JsonKey(name: 'actual_value') dynamic actualValue,
    required CriterionState state,
    required String explanation,
  }) = _CriterionEvaluation;

  factory CriterionEvaluation.fromJson(Map<String, dynamic> json) =>
      _$CriterionEvaluationFromJson(json);
}

@freezed
class MatchResult with _$MatchResult {
  const factory MatchResult({
    required RelevanceTier relevance,
    @JsonKey(name: 'criterion_evaluations')
    required List<CriterionEvaluation> criterionEvaluations,
    @JsonKey(name: 'matched_count') required int matchedCount,
    @JsonKey(name: 'not_matched_count') required int notMatchedCount,
    @JsonKey(name: 'unknown_count') required int unknownCount,
    @JsonKey(name: 'needs_verification_count')
    required int needsVerificationCount,
    required String explanation,
  }) = _MatchResult;

  factory MatchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchResultFromJson(json);
}
