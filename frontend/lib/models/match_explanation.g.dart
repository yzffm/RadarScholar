// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_explanation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchExplanationImpl _$$MatchExplanationImplFromJson(
  Map<String, dynamic> json,
) => _$MatchExplanationImpl(
  summary: json['summary'] as String,
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  weaknesses:
      (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  unknowns:
      (json['unknowns'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$MatchExplanationImplToJson(
  _$MatchExplanationImpl instance,
) => <String, dynamic>{
  'summary': instance.summary,
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'unknowns': instance.unknowns,
};
