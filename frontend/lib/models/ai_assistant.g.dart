// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_assistant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssistantRequestImpl _$$AssistantRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AssistantRequestImpl(
  taskType: $enumDecode(_$AssistantTaskTypeEnumMap, json['task_type']),
  draftText: json['draft_text'] as String?,
);

Map<String, dynamic> _$$AssistantRequestImplToJson(
  _$AssistantRequestImpl instance,
) => <String, dynamic>{
  'task_type': _$AssistantTaskTypeEnumMap[instance.taskType]!,
  'draft_text': instance.draftText,
};

const _$AssistantTaskTypeEnumMap = {
  AssistantTaskType.cv: 'cv',
  AssistantTaskType.motivationLetter: 'motivation_letter',
  AssistantTaskType.essay: 'essay',
  AssistantTaskType.interview: 'interview',
};

_$AssistantResponseImpl _$$AssistantResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AssistantResponseImpl(
  feedback: json['feedback'] as String,
  actionableTips:
      (json['actionable_tips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$AssistantResponseImplToJson(
  _$AssistantResponseImpl instance,
) => <String, dynamic>{
  'feedback': instance.feedback,
  'actionable_tips': instance.actionableTips,
};
