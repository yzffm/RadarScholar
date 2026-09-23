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
    required String requirementType,
    required String operator,
    required dynamic requiredValue,
    dynamic actualValue,
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
    required List<CriterionEvaluation> criterionEvaluations,
    required int matchedCount,
    required int notMatchedCount,
    required int unknownCount,
    required int needsVerificationCount,
    required String explanation,
  }) = _MatchResult;

  factory MatchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchResultFromJson(json);
}
