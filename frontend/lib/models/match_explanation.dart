import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_explanation.freezed.dart';
part 'match_explanation.g.dart';

@freezed
class MatchExplanation with _$MatchExplanation {
  const factory MatchExplanation({
    required String summary,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
    @Default([]) List<String> unknowns,
  }) = _MatchExplanation;

  factory MatchExplanation.fromJson(Map<String, dynamic> json) =>
      _$MatchExplanationFromJson(json);
}
