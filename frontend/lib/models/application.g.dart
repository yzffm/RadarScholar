// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApplicationTaskImpl _$$ApplicationTaskImplFromJson(
  Map<String, dynamic> json,
) => _$ApplicationTaskImpl(
  id: json['id'] as String,
  applicationId: json['application_id'] as String,
  title: json['title'] as String,
  isCompleted: json['is_completed'] as bool? ?? false,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ApplicationTaskImplToJson(
  _$ApplicationTaskImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'application_id': instance.applicationId,
  'title': instance.title,
  'is_completed': instance.isCompleted,
  'due_date': instance.dueDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_$ApplicationImpl _$$ApplicationImplFromJson(Map<String, dynamic> json) =>
    _$ApplicationImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      scholarshipId: json['scholarship_id'] as String,
      status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
      targetDeadline: json['target_deadline'] == null
          ? null
          : DateTime.parse(json['target_deadline'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      scholarship: Scholarship.fromJson(
        json['scholarship'] as Map<String, dynamic>,
      ),
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => ApplicationTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ApplicationImplToJson(_$ApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'scholarship_id': instance.scholarshipId,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'target_deadline': instance.targetDeadline?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'scholarship': instance.scholarship,
      'tasks': instance.tasks,
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.planned: 'PLANNED',
  ApplicationStatus.inProgress: 'IN_PROGRESS',
  ApplicationStatus.submitted: 'SUBMITTED',
  ApplicationStatus.accepted: 'ACCEPTED',
  ApplicationStatus.rejected: 'REJECTED',
  ApplicationStatus.withdrawn: 'WITHDRAWN',
};

_$SavedScholarshipImpl _$$SavedScholarshipImplFromJson(
  Map<String, dynamic> json,
) => _$SavedScholarshipImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  scholarshipId: json['scholarship_id'] as String,
  savedAt: DateTime.parse(json['saved_at'] as String),
  scholarship: Scholarship.fromJson(
    json['scholarship'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$SavedScholarshipImplToJson(
  _$SavedScholarshipImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'scholarship_id': instance.scholarshipId,
  'saved_at': instance.savedAt.toIso8601String(),
  'scholarship': instance.scholarship,
};
