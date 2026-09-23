// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApplicationTask _$ApplicationTaskFromJson(Map<String, dynamic> json) {
  return _ApplicationTask.fromJson(json);
}

/// @nodoc
mixin _$ApplicationTask {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'application_id')
  String get applicationId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime? get dueDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ApplicationTask to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApplicationTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApplicationTaskCopyWith<ApplicationTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationTaskCopyWith<$Res> {
  factory $ApplicationTaskCopyWith(
    ApplicationTask value,
    $Res Function(ApplicationTask) then,
  ) = _$ApplicationTaskCopyWithImpl<$Res, ApplicationTask>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'application_id') String applicationId,
    String title,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$ApplicationTaskCopyWithImpl<$Res, $Val extends ApplicationTask>
    implements $ApplicationTaskCopyWith<$Res> {
  _$ApplicationTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApplicationTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? applicationId = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? dueDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            applicationId: null == applicationId
                ? _value.applicationId
                : applicationId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApplicationTaskImplCopyWith<$Res>
    implements $ApplicationTaskCopyWith<$Res> {
  factory _$$ApplicationTaskImplCopyWith(
    _$ApplicationTaskImpl value,
    $Res Function(_$ApplicationTaskImpl) then,
  ) = __$$ApplicationTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'application_id') String applicationId,
    String title,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$ApplicationTaskImplCopyWithImpl<$Res>
    extends _$ApplicationTaskCopyWithImpl<$Res, _$ApplicationTaskImpl>
    implements _$$ApplicationTaskImplCopyWith<$Res> {
  __$$ApplicationTaskImplCopyWithImpl(
    _$ApplicationTaskImpl _value,
    $Res Function(_$ApplicationTaskImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApplicationTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? applicationId = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? dueDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ApplicationTaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        applicationId: null == applicationId
            ? _value.applicationId
            : applicationId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApplicationTaskImpl implements _ApplicationTask {
  const _$ApplicationTaskImpl({
    required this.id,
    @JsonKey(name: 'application_id') required this.applicationId,
    required this.title,
    @JsonKey(name: 'is_completed') this.isCompleted = false,
    @JsonKey(name: 'due_date') this.dueDate,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$ApplicationTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApplicationTaskImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'application_id')
  final String applicationId;
  @override
  final String title;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ApplicationTask(id: $id, applicationId: $applicationId, title: $title, isCompleted: $isCompleted, dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplicationTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.applicationId, applicationId) ||
                other.applicationId == applicationId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    applicationId,
    title,
    isCompleted,
    dueDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ApplicationTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplicationTaskImplCopyWith<_$ApplicationTaskImpl> get copyWith =>
      __$$ApplicationTaskImplCopyWithImpl<_$ApplicationTaskImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApplicationTaskImplToJson(this);
  }
}

abstract class _ApplicationTask implements ApplicationTask {
  const factory _ApplicationTask({
    required final String id,
    @JsonKey(name: 'application_id') required final String applicationId,
    required final String title,
    @JsonKey(name: 'is_completed') final bool isCompleted,
    @JsonKey(name: 'due_date') final DateTime? dueDate,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$ApplicationTaskImpl;

  factory _ApplicationTask.fromJson(Map<String, dynamic> json) =
      _$ApplicationTaskImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'application_id')
  String get applicationId;
  @override
  String get title;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @override
  @JsonKey(name: 'due_date')
  DateTime? get dueDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ApplicationTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApplicationTaskImplCopyWith<_$ApplicationTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Application _$ApplicationFromJson(Map<String, dynamic> json) {
  return _Application.fromJson(json);
}

/// @nodoc
mixin _$Application {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId => throw _privateConstructorUsedError;
  ApplicationStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_deadline')
  DateTime? get targetDeadline => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Scholarship get scholarship => throw _privateConstructorUsedError;
  List<ApplicationTask> get tasks => throw _privateConstructorUsedError;

  /// Serializes this Application to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApplicationCopyWith<Application> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApplicationCopyWith<$Res> {
  factory $ApplicationCopyWith(
    Application value,
    $Res Function(Application) then,
  ) = _$ApplicationCopyWithImpl<$Res, Application>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    ApplicationStatus status,
    @JsonKey(name: 'target_deadline') DateTime? targetDeadline,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    Scholarship scholarship,
    List<ApplicationTask> tasks,
  });

  $ScholarshipCopyWith<$Res> get scholarship;
}

/// @nodoc
class _$ApplicationCopyWithImpl<$Res, $Val extends Application>
    implements $ApplicationCopyWith<$Res> {
  _$ApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scholarshipId = null,
    Object? status = null,
    Object? targetDeadline = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? scholarship = null,
    Object? tasks = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            scholarshipId: null == scholarshipId
                ? _value.scholarshipId
                : scholarshipId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ApplicationStatus,
            targetDeadline: freezed == targetDeadline
                ? _value.targetDeadline
                : targetDeadline // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            scholarship: null == scholarship
                ? _value.scholarship
                : scholarship // ignore: cast_nullable_to_non_nullable
                      as Scholarship,
            tasks: null == tasks
                ? _value.tasks
                : tasks // ignore: cast_nullable_to_non_nullable
                      as List<ApplicationTask>,
          )
          as $Val,
    );
  }

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScholarshipCopyWith<$Res> get scholarship {
    return $ScholarshipCopyWith<$Res>(_value.scholarship, (value) {
      return _then(_value.copyWith(scholarship: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApplicationImplCopyWith<$Res>
    implements $ApplicationCopyWith<$Res> {
  factory _$$ApplicationImplCopyWith(
    _$ApplicationImpl value,
    $Res Function(_$ApplicationImpl) then,
  ) = __$$ApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    ApplicationStatus status,
    @JsonKey(name: 'target_deadline') DateTime? targetDeadline,
    String? notes,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    Scholarship scholarship,
    List<ApplicationTask> tasks,
  });

  @override
  $ScholarshipCopyWith<$Res> get scholarship;
}

/// @nodoc
class __$$ApplicationImplCopyWithImpl<$Res>
    extends _$ApplicationCopyWithImpl<$Res, _$ApplicationImpl>
    implements _$$ApplicationImplCopyWith<$Res> {
  __$$ApplicationImplCopyWithImpl(
    _$ApplicationImpl _value,
    $Res Function(_$ApplicationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scholarshipId = null,
    Object? status = null,
    Object? targetDeadline = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? scholarship = null,
    Object? tasks = null,
  }) {
    return _then(
      _$ApplicationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        scholarshipId: null == scholarshipId
            ? _value.scholarshipId
            : scholarshipId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ApplicationStatus,
        targetDeadline: freezed == targetDeadline
            ? _value.targetDeadline
            : targetDeadline // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        scholarship: null == scholarship
            ? _value.scholarship
            : scholarship // ignore: cast_nullable_to_non_nullable
                  as Scholarship,
        tasks: null == tasks
            ? _value._tasks
            : tasks // ignore: cast_nullable_to_non_nullable
                  as List<ApplicationTask>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApplicationImpl extends _Application {
  const _$ApplicationImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'scholarship_id') required this.scholarshipId,
    required this.status,
    @JsonKey(name: 'target_deadline') this.targetDeadline,
    this.notes,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    required this.scholarship,
    final List<ApplicationTask> tasks = const [],
  }) : _tasks = tasks,
       super._();

  factory _$ApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApplicationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'scholarship_id')
  final String scholarshipId;
  @override
  final ApplicationStatus status;
  @override
  @JsonKey(name: 'target_deadline')
  final DateTime? targetDeadline;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  final Scholarship scholarship;
  final List<ApplicationTask> _tasks;
  @override
  @JsonKey()
  List<ApplicationTask> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'Application(id: $id, userId: $userId, scholarshipId: $scholarshipId, status: $status, targetDeadline: $targetDeadline, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, scholarship: $scholarship, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.scholarshipId, scholarshipId) ||
                other.scholarshipId == scholarshipId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.targetDeadline, targetDeadline) ||
                other.targetDeadline == targetDeadline) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.scholarship, scholarship) ||
                other.scholarship == scholarship) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    scholarshipId,
    status,
    targetDeadline,
    notes,
    createdAt,
    updatedAt,
    scholarship,
    const DeepCollectionEquality().hash(_tasks),
  );

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApplicationImplCopyWith<_$ApplicationImpl> get copyWith =>
      __$$ApplicationImplCopyWithImpl<_$ApplicationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApplicationImplToJson(this);
  }
}

abstract class _Application extends Application {
  const factory _Application({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'scholarship_id') required final String scholarshipId,
    required final ApplicationStatus status,
    @JsonKey(name: 'target_deadline') final DateTime? targetDeadline,
    final String? notes,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    required final Scholarship scholarship,
    final List<ApplicationTask> tasks,
  }) = _$ApplicationImpl;
  const _Application._() : super._();

  factory _Application.fromJson(Map<String, dynamic> json) =
      _$ApplicationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId;
  @override
  ApplicationStatus get status;
  @override
  @JsonKey(name: 'target_deadline')
  DateTime? get targetDeadline;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  Scholarship get scholarship;
  @override
  List<ApplicationTask> get tasks;

  /// Create a copy of Application
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApplicationImplCopyWith<_$ApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavedScholarship _$SavedScholarshipFromJson(Map<String, dynamic> json) {
  return _SavedScholarship.fromJson(json);
}

/// @nodoc
mixin _$SavedScholarship {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId => throw _privateConstructorUsedError;
  @JsonKey(name: 'saved_at')
  DateTime get savedAt => throw _privateConstructorUsedError;
  Scholarship get scholarship => throw _privateConstructorUsedError;

  /// Serializes this SavedScholarship to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedScholarshipCopyWith<SavedScholarship> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedScholarshipCopyWith<$Res> {
  factory $SavedScholarshipCopyWith(
    SavedScholarship value,
    $Res Function(SavedScholarship) then,
  ) = _$SavedScholarshipCopyWithImpl<$Res, SavedScholarship>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'saved_at') DateTime savedAt,
    Scholarship scholarship,
  });

  $ScholarshipCopyWith<$Res> get scholarship;
}

/// @nodoc
class _$SavedScholarshipCopyWithImpl<$Res, $Val extends SavedScholarship>
    implements $SavedScholarshipCopyWith<$Res> {
  _$SavedScholarshipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scholarshipId = null,
    Object? savedAt = null,
    Object? scholarship = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            scholarshipId: null == scholarshipId
                ? _value.scholarshipId
                : scholarshipId // ignore: cast_nullable_to_non_nullable
                      as String,
            savedAt: null == savedAt
                ? _value.savedAt
                : savedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            scholarship: null == scholarship
                ? _value.scholarship
                : scholarship // ignore: cast_nullable_to_non_nullable
                      as Scholarship,
          )
          as $Val,
    );
  }

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScholarshipCopyWith<$Res> get scholarship {
    return $ScholarshipCopyWith<$Res>(_value.scholarship, (value) {
      return _then(_value.copyWith(scholarship: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SavedScholarshipImplCopyWith<$Res>
    implements $SavedScholarshipCopyWith<$Res> {
  factory _$$SavedScholarshipImplCopyWith(
    _$SavedScholarshipImpl value,
    $Res Function(_$SavedScholarshipImpl) then,
  ) = __$$SavedScholarshipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'saved_at') DateTime savedAt,
    Scholarship scholarship,
  });

  @override
  $ScholarshipCopyWith<$Res> get scholarship;
}

/// @nodoc
class __$$SavedScholarshipImplCopyWithImpl<$Res>
    extends _$SavedScholarshipCopyWithImpl<$Res, _$SavedScholarshipImpl>
    implements _$$SavedScholarshipImplCopyWith<$Res> {
  __$$SavedScholarshipImplCopyWithImpl(
    _$SavedScholarshipImpl _value,
    $Res Function(_$SavedScholarshipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scholarshipId = null,
    Object? savedAt = null,
    Object? scholarship = null,
  }) {
    return _then(
      _$SavedScholarshipImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        scholarshipId: null == scholarshipId
            ? _value.scholarshipId
            : scholarshipId // ignore: cast_nullable_to_non_nullable
                  as String,
        savedAt: null == savedAt
            ? _value.savedAt
            : savedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        scholarship: null == scholarship
            ? _value.scholarship
            : scholarship // ignore: cast_nullable_to_non_nullable
                  as Scholarship,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedScholarshipImpl implements _SavedScholarship {
  const _$SavedScholarshipImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'scholarship_id') required this.scholarshipId,
    @JsonKey(name: 'saved_at') required this.savedAt,
    required this.scholarship,
  });

  factory _$SavedScholarshipImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedScholarshipImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'scholarship_id')
  final String scholarshipId;
  @override
  @JsonKey(name: 'saved_at')
  final DateTime savedAt;
  @override
  final Scholarship scholarship;

  @override
  String toString() {
    return 'SavedScholarship(id: $id, userId: $userId, scholarshipId: $scholarshipId, savedAt: $savedAt, scholarship: $scholarship)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedScholarshipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.scholarshipId, scholarshipId) ||
                other.scholarshipId == scholarshipId) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt) &&
            (identical(other.scholarship, scholarship) ||
                other.scholarship == scholarship));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, scholarshipId, savedAt, scholarship);

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedScholarshipImplCopyWith<_$SavedScholarshipImpl> get copyWith =>
      __$$SavedScholarshipImplCopyWithImpl<_$SavedScholarshipImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedScholarshipImplToJson(this);
  }
}

abstract class _SavedScholarship implements SavedScholarship {
  const factory _SavedScholarship({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'scholarship_id') required final String scholarshipId,
    @JsonKey(name: 'saved_at') required final DateTime savedAt,
    required final Scholarship scholarship,
  }) = _$SavedScholarshipImpl;

  factory _SavedScholarship.fromJson(Map<String, dynamic> json) =
      _$SavedScholarshipImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId;
  @override
  @JsonKey(name: 'saved_at')
  DateTime get savedAt;
  @override
  Scholarship get scholarship;

  /// Create a copy of SavedScholarship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedScholarshipImplCopyWith<_$SavedScholarshipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
