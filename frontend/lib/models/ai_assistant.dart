import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_assistant.freezed.dart';
part 'ai_assistant.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum AssistantTaskType { cv, motivationLetter, essay, interview }

@freezed
class AssistantRequest with _$AssistantRequest {
  const factory AssistantRequest({
    @JsonKey(name: 'task_type') required AssistantTaskType taskType,
    @JsonKey(name: 'draft_text') String? draftText,
  }) = _AssistantRequest;

  factory AssistantRequest.fromJson(Map<String, dynamic> json) =>
      _$AssistantRequestFromJson(json);
}

@freezed
class AssistantResponse with _$AssistantResponse {
  const factory AssistantResponse({
    required String feedback,
    @JsonKey(name: 'actionable_tips') @Default([]) List<String> actionableTips,
  }) = _AssistantResponse;

  factory AssistantResponse.fromJson(Map<String, dynamic> json) =>
      _$AssistantResponseFromJson(json);
}
