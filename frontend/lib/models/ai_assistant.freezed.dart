// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_assistant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssistantRequest _$AssistantRequestFromJson(Map<String, dynamic> json) {
  return _AssistantRequest.fromJson(json);
}

/// @nodoc
mixin _$AssistantRequest {
  @JsonKey(name: 'task_type')
  AssistantTaskType get taskType => throw _privateConstructorUsedError;
  @JsonKey(name: 'draft_text')
  String? get draftText => throw _privateConstructorUsedError;

  /// Serializes this AssistantRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantRequestCopyWith<AssistantRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantRequestCopyWith<$Res> {
  factory $AssistantRequestCopyWith(
    AssistantRequest value,
    $Res Function(AssistantRequest) then,
  ) = _$AssistantRequestCopyWithImpl<$Res, AssistantRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'task_type') AssistantTaskType taskType,
    @JsonKey(name: 'draft_text') String? draftText,
  });
}

/// @nodoc
class _$AssistantRequestCopyWithImpl<$Res, $Val extends AssistantRequest>
    implements $AssistantRequestCopyWith<$Res> {
  _$AssistantRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? taskType = null, Object? draftText = freezed}) {
    return _then(
      _value.copyWith(
            taskType: null == taskType
                ? _value.taskType
                : taskType // ignore: cast_nullable_to_non_nullable
                      as AssistantTaskType,
            draftText: freezed == draftText
                ? _value.draftText
                : draftText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssistantRequestImplCopyWith<$Res>
    implements $AssistantRequestCopyWith<$Res> {
  factory _$$AssistantRequestImplCopyWith(
    _$AssistantRequestImpl value,
    $Res Function(_$AssistantRequestImpl) then,
  ) = __$$AssistantRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'task_type') AssistantTaskType taskType,
    @JsonKey(name: 'draft_text') String? draftText,
  });
}

/// @nodoc
class __$$AssistantRequestImplCopyWithImpl<$Res>
    extends _$AssistantRequestCopyWithImpl<$Res, _$AssistantRequestImpl>
    implements _$$AssistantRequestImplCopyWith<$Res> {
  __$$AssistantRequestImplCopyWithImpl(
    _$AssistantRequestImpl _value,
    $Res Function(_$AssistantRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssistantRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? taskType = null, Object? draftText = freezed}) {
    return _then(
      _$AssistantRequestImpl(
        taskType: null == taskType
            ? _value.taskType
            : taskType // ignore: cast_nullable_to_non_nullable
                  as AssistantTaskType,
        draftText: freezed == draftText
            ? _value.draftText
            : draftText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantRequestImpl implements _AssistantRequest {
  const _$AssistantRequestImpl({
    @JsonKey(name: 'task_type') required this.taskType,
    @JsonKey(name: 'draft_text') this.draftText,
  });

  factory _$AssistantRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantRequestImplFromJson(json);

  @override
  @JsonKey(name: 'task_type')
  final AssistantTaskType taskType;
  @override
  @JsonKey(name: 'draft_text')
  final String? draftText;

  @override
  String toString() {
    return 'AssistantRequest(taskType: $taskType, draftText: $draftText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantRequestImpl &&
            (identical(other.taskType, taskType) ||
                other.taskType == taskType) &&
            (identical(other.draftText, draftText) ||
                other.draftText == draftText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, taskType, draftText);

  /// Create a copy of AssistantRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantRequestImplCopyWith<_$AssistantRequestImpl> get copyWith =>
      __$$AssistantRequestImplCopyWithImpl<_$AssistantRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantRequestImplToJson(this);
  }
}

abstract class _AssistantRequest implements AssistantRequest {
  const factory _AssistantRequest({
    @JsonKey(name: 'task_type') required final AssistantTaskType taskType,
    @JsonKey(name: 'draft_text') final String? draftText,
  }) = _$AssistantRequestImpl;

  factory _AssistantRequest.fromJson(Map<String, dynamic> json) =
      _$AssistantRequestImpl.fromJson;

  @override
  @JsonKey(name: 'task_type')
  AssistantTaskType get taskType;
  @override
  @JsonKey(name: 'draft_text')
  String? get draftText;

  /// Create a copy of AssistantRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantRequestImplCopyWith<_$AssistantRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AssistantResponse _$AssistantResponseFromJson(Map<String, dynamic> json) {
  return _AssistantResponse.fromJson(json);
}

/// @nodoc
mixin _$AssistantResponse {
  String get feedback => throw _privateConstructorUsedError;
  @JsonKey(name: 'actionable_tips')
  List<String> get actionableTips => throw _privateConstructorUsedError;

  /// Serializes this AssistantResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssistantResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssistantResponseCopyWith<AssistantResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssistantResponseCopyWith<$Res> {
  factory $AssistantResponseCopyWith(
    AssistantResponse value,
    $Res Function(AssistantResponse) then,
  ) = _$AssistantResponseCopyWithImpl<$Res, AssistantResponse>;
  @useResult
  $Res call({
    String feedback,
    @JsonKey(name: 'actionable_tips') List<String> actionableTips,
  });
}

/// @nodoc
class _$AssistantResponseCopyWithImpl<$Res, $Val extends AssistantResponse>
    implements $AssistantResponseCopyWith<$Res> {
  _$AssistantResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssistantResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? feedback = null, Object? actionableTips = null}) {
    return _then(
      _value.copyWith(
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String,
            actionableTips: null == actionableTips
                ? _value.actionableTips
                : actionableTips // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssistantResponseImplCopyWith<$Res>
    implements $AssistantResponseCopyWith<$Res> {
  factory _$$AssistantResponseImplCopyWith(
    _$AssistantResponseImpl value,
    $Res Function(_$AssistantResponseImpl) then,
  ) = __$$AssistantResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String feedback,
    @JsonKey(name: 'actionable_tips') List<String> actionableTips,
  });
}

/// @nodoc
class __$$AssistantResponseImplCopyWithImpl<$Res>
    extends _$AssistantResponseCopyWithImpl<$Res, _$AssistantResponseImpl>
    implements _$$AssistantResponseImplCopyWith<$Res> {
  __$$AssistantResponseImplCopyWithImpl(
    _$AssistantResponseImpl _value,
    $Res Function(_$AssistantResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssistantResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? feedback = null, Object? actionableTips = null}) {
    return _then(
      _$AssistantResponseImpl(
        feedback: null == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String,
        actionableTips: null == actionableTips
            ? _value._actionableTips
            : actionableTips // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssistantResponseImpl implements _AssistantResponse {
  const _$AssistantResponseImpl({
    required this.feedback,
    @JsonKey(name: 'actionable_tips')
    final List<String> actionableTips = const [],
  }) : _actionableTips = actionableTips;

  factory _$AssistantResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssistantResponseImplFromJson(json);

  @override
  final String feedback;
  final List<String> _actionableTips;
  @override
  @JsonKey(name: 'actionable_tips')
  List<String> get actionableTips {
    if (_actionableTips is EqualUnmodifiableListView) return _actionableTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionableTips);
  }

  @override
  String toString() {
    return 'AssistantResponse(feedback: $feedback, actionableTips: $actionableTips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssistantResponseImpl &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            const DeepCollectionEquality().equals(
              other._actionableTips,
              _actionableTips,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    feedback,
    const DeepCollectionEquality().hash(_actionableTips),
  );

  /// Create a copy of AssistantResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssistantResponseImplCopyWith<_$AssistantResponseImpl> get copyWith =>
      __$$AssistantResponseImplCopyWithImpl<_$AssistantResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssistantResponseImplToJson(this);
  }
}

abstract class _AssistantResponse implements AssistantResponse {
  const factory _AssistantResponse({
    required final String feedback,
    @JsonKey(name: 'actionable_tips') final List<String> actionableTips,
  }) = _$AssistantResponseImpl;

  factory _AssistantResponse.fromJson(Map<String, dynamic> json) =
      _$AssistantResponseImpl.fromJson;

  @override
  String get feedback;
  @override
  @JsonKey(name: 'actionable_tips')
  List<String> get actionableTips;

  /// Create a copy of AssistantResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssistantResponseImplCopyWith<_$AssistantResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
