// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:radarscholar/models/scholarship.dart';

part 'application.freezed.dart';
part 'application.g.dart';

enum ApplicationStatus {
  @JsonValue('PLANNED')
  planned,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('SUBMITTED')
  submitted,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('WITHDRAWN')
  withdrawn,
}

@freezed
class ApplicationTask with _$ApplicationTask {
  const factory ApplicationTask({
    required String id,
    @JsonKey(name: 'application_id') required String applicationId,
    required String title,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ApplicationTask;

  factory ApplicationTask.fromJson(Map<String, dynamic> json) =>
      _$ApplicationTaskFromJson(json);
}

@freezed
class Application with _$Application {
  const factory Application({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'scholarship_id') required String scholarshipId,
    required ApplicationStatus status,
    @JsonKey(name: 'target_deadline') DateTime? targetDeadline,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    required Scholarship scholarship,
    @Default([]) List<ApplicationTask> tasks,
  }) = _Application;

  const Application._();

  int get tasksTotal => tasks.length;
  int get tasksCompleted => tasks.where((task) => task.isCompleted).length;
  double get progress => tasksTotal == 0 ? 0.0 : tasksCompleted / tasksTotal;

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);
}

@freezed
class SavedScholarship with _$SavedScholarship {
  const factory SavedScholarship({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'scholarship_id') required String scholarshipId,
    @JsonKey(name: 'saved_at') required DateTime savedAt,
    required Scholarship scholarship,
  }) = _SavedScholarship;

  factory SavedScholarship.fromJson(Map<String, dynamic> json) =>
      _$SavedScholarshipFromJson(json);
}
