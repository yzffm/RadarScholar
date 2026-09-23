// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CriterionEvaluation _$CriterionEvaluationFromJson(Map<String, dynamic> json) {
  return _CriterionEvaluation.fromJson(json);
}

/// @nodoc
mixin _$CriterionEvaluation {
  String get requirementType => throw _privateConstructorUsedError;
  String get operator => throw _privateConstructorUsedError;
  dynamic get requiredValue => throw _privateConstructorUsedError;
  dynamic get actualValue => throw _privateConstructorUsedError;
  CriterionState get state => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this CriterionEvaluation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CriterionEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CriterionEvaluationCopyWith<CriterionEvaluation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CriterionEvaluationCopyWith<$Res> {
  factory $CriterionEvaluationCopyWith(
    CriterionEvaluation value,
    $Res Function(CriterionEvaluation) then,
  ) = _$CriterionEvaluationCopyWithImpl<$Res, CriterionEvaluation>;
  @useResult
  $Res call({
    String requirementType,
    String operator,
    dynamic requiredValue,
    dynamic actualValue,
    CriterionState state,
    String explanation,
  });
}

/// @nodoc
class _$CriterionEvaluationCopyWithImpl<$Res, $Val extends CriterionEvaluation>
    implements $CriterionEvaluationCopyWith<$Res> {
  _$CriterionEvaluationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CriterionEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requirementType = null,
    Object? operator = null,
    Object? requiredValue = freezed,
    Object? actualValue = freezed,
    Object? state = null,
    Object? explanation = null,
  }) {
    return _then(
      _value.copyWith(
            requirementType: null == requirementType
                ? _value.requirementType
                : requirementType // ignore: cast_nullable_to_non_nullable
                      as String,
            operator: null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                      as String,
            requiredValue: freezed == requiredValue
                ? _value.requiredValue
                : requiredValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            actualValue: freezed == actualValue
                ? _value.actualValue
                : actualValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as CriterionState,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CriterionEvaluationImplCopyWith<$Res>
    implements $CriterionEvaluationCopyWith<$Res> {
  factory _$$CriterionEvaluationImplCopyWith(
    _$CriterionEvaluationImpl value,
    $Res Function(_$CriterionEvaluationImpl) then,
  ) = __$$CriterionEvaluationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String requirementType,
    String operator,
    dynamic requiredValue,
    dynamic actualValue,
    CriterionState state,
    String explanation,
  });
}

/// @nodoc
class __$$CriterionEvaluationImplCopyWithImpl<$Res>
    extends _$CriterionEvaluationCopyWithImpl<$Res, _$CriterionEvaluationImpl>
    implements _$$CriterionEvaluationImplCopyWith<$Res> {
  __$$CriterionEvaluationImplCopyWithImpl(
    _$CriterionEvaluationImpl _value,
    $Res Function(_$CriterionEvaluationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CriterionEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requirementType = null,
    Object? operator = null,
    Object? requiredValue = freezed,
    Object? actualValue = freezed,
    Object? state = null,
    Object? explanation = null,
  }) {
    return _then(
      _$CriterionEvaluationImpl(
        requirementType: null == requirementType
            ? _value.requirementType
            : requirementType // ignore: cast_nullable_to_non_nullable
                  as String,
        operator: null == operator
            ? _value.operator
            : operator // ignore: cast_nullable_to_non_nullable
                  as String,
        requiredValue: freezed == requiredValue
            ? _value.requiredValue
            : requiredValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        actualValue: freezed == actualValue
            ? _value.actualValue
            : actualValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as CriterionState,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CriterionEvaluationImpl implements _CriterionEvaluation {
  const _$CriterionEvaluationImpl({
    required this.requirementType,
    required this.operator,
    required this.requiredValue,
    this.actualValue,
    required this.state,
    required this.explanation,
  });

  factory _$CriterionEvaluationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CriterionEvaluationImplFromJson(json);

  @override
  final String requirementType;
  @override
  final String operator;
  @override
  final dynamic requiredValue;
  @override
  final dynamic actualValue;
  @override
  final CriterionState state;
  @override
  final String explanation;

  @override
  String toString() {
    return 'CriterionEvaluation(requirementType: $requirementType, operator: $operator, requiredValue: $requiredValue, actualValue: $actualValue, state: $state, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CriterionEvaluationImpl &&
            (identical(other.requirementType, requirementType) ||
                other.requirementType == requirementType) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(
              other.requiredValue,
              requiredValue,
            ) &&
            const DeepCollectionEquality().equals(
              other.actualValue,
              actualValue,
            ) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    requirementType,
    operator,
    const DeepCollectionEquality().hash(requiredValue),
    const DeepCollectionEquality().hash(actualValue),
    state,
    explanation,
  );

  /// Create a copy of CriterionEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CriterionEvaluationImplCopyWith<_$CriterionEvaluationImpl> get copyWith =>
      __$$CriterionEvaluationImplCopyWithImpl<_$CriterionEvaluationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CriterionEvaluationImplToJson(this);
  }
}

abstract class _CriterionEvaluation implements CriterionEvaluation {
  const factory _CriterionEvaluation({
    required final String requirementType,
    required final String operator,
    required final dynamic requiredValue,
    final dynamic actualValue,
    required final CriterionState state,
    required final String explanation,
  }) = _$CriterionEvaluationImpl;

  factory _CriterionEvaluation.fromJson(Map<String, dynamic> json) =
      _$CriterionEvaluationImpl.fromJson;

  @override
  String get requirementType;
  @override
  String get operator;
  @override
  dynamic get requiredValue;
  @override
  dynamic get actualValue;
  @override
  CriterionState get state;
  @override
  String get explanation;

  /// Create a copy of CriterionEvaluation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CriterionEvaluationImplCopyWith<_$CriterionEvaluationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchResult _$MatchResultFromJson(Map<String, dynamic> json) {
  return _MatchResult.fromJson(json);
}

/// @nodoc
mixin _$MatchResult {
  RelevanceTier get relevance => throw _privateConstructorUsedError;
  List<CriterionEvaluation> get criterionEvaluations =>
      throw _privateConstructorUsedError;
  int get matchedCount => throw _privateConstructorUsedError;
  int get notMatchedCount => throw _privateConstructorUsedError;
  int get unknownCount => throw _privateConstructorUsedError;
  int get needsVerificationCount => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this MatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchResultCopyWith<MatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchResultCopyWith<$Res> {
  factory $MatchResultCopyWith(
    MatchResult value,
    $Res Function(MatchResult) then,
  ) = _$MatchResultCopyWithImpl<$Res, MatchResult>;
  @useResult
  $Res call({
    RelevanceTier relevance,
    List<CriterionEvaluation> criterionEvaluations,
    int matchedCount,
    int notMatchedCount,
    int unknownCount,
    int needsVerificationCount,
    String explanation,
  });
}

/// @nodoc
class _$MatchResultCopyWithImpl<$Res, $Val extends MatchResult>
    implements $MatchResultCopyWith<$Res> {
  _$MatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? relevance = null,
    Object? criterionEvaluations = null,
    Object? matchedCount = null,
    Object? notMatchedCount = null,
    Object? unknownCount = null,
    Object? needsVerificationCount = null,
    Object? explanation = null,
  }) {
    return _then(
      _value.copyWith(
            relevance: null == relevance
                ? _value.relevance
                : relevance // ignore: cast_nullable_to_non_nullable
                      as RelevanceTier,
            criterionEvaluations: null == criterionEvaluations
                ? _value.criterionEvaluations
                : criterionEvaluations // ignore: cast_nullable_to_non_nullable
                      as List<CriterionEvaluation>,
            matchedCount: null == matchedCount
                ? _value.matchedCount
                : matchedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            notMatchedCount: null == notMatchedCount
                ? _value.notMatchedCount
                : notMatchedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            unknownCount: null == unknownCount
                ? _value.unknownCount
                : unknownCount // ignore: cast_nullable_to_non_nullable
                      as int,
            needsVerificationCount: null == needsVerificationCount
                ? _value.needsVerificationCount
                : needsVerificationCount // ignore: cast_nullable_to_non_nullable
                      as int,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchResultImplCopyWith<$Res>
    implements $MatchResultCopyWith<$Res> {
  factory _$$MatchResultImplCopyWith(
    _$MatchResultImpl value,
    $Res Function(_$MatchResultImpl) then,
  ) = __$$MatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RelevanceTier relevance,
    List<CriterionEvaluation> criterionEvaluations,
    int matchedCount,
    int notMatchedCount,
    int unknownCount,
    int needsVerificationCount,
    String explanation,
  });
}

/// @nodoc
class __$$MatchResultImplCopyWithImpl<$Res>
    extends _$MatchResultCopyWithImpl<$Res, _$MatchResultImpl>
    implements _$$MatchResultImplCopyWith<$Res> {
  __$$MatchResultImplCopyWithImpl(
    _$MatchResultImpl _value,
    $Res Function(_$MatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? relevance = null,
    Object? criterionEvaluations = null,
    Object? matchedCount = null,
    Object? notMatchedCount = null,
    Object? unknownCount = null,
    Object? needsVerificationCount = null,
    Object? explanation = null,
  }) {
    return _then(
      _$MatchResultImpl(
        relevance: null == relevance
            ? _value.relevance
            : relevance // ignore: cast_nullable_to_non_nullable
                  as RelevanceTier,
        criterionEvaluations: null == criterionEvaluations
            ? _value._criterionEvaluations
            : criterionEvaluations // ignore: cast_nullable_to_non_nullable
                  as List<CriterionEvaluation>,
        matchedCount: null == matchedCount
            ? _value.matchedCount
            : matchedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        notMatchedCount: null == notMatchedCount
            ? _value.notMatchedCount
            : notMatchedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        unknownCount: null == unknownCount
            ? _value.unknownCount
            : unknownCount // ignore: cast_nullable_to_non_nullable
                  as int,
        needsVerificationCount: null == needsVerificationCount
            ? _value.needsVerificationCount
            : needsVerificationCount // ignore: cast_nullable_to_non_nullable
                  as int,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchResultImpl implements _MatchResult {
  const _$MatchResultImpl({
    required this.relevance,
    required final List<CriterionEvaluation> criterionEvaluations,
    required this.matchedCount,
    required this.notMatchedCount,
    required this.unknownCount,
    required this.needsVerificationCount,
    required this.explanation,
  }) : _criterionEvaluations = criterionEvaluations;

  factory _$MatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchResultImplFromJson(json);

  @override
  final RelevanceTier relevance;
  final List<CriterionEvaluation> _criterionEvaluations;
  @override
  List<CriterionEvaluation> get criterionEvaluations {
    if (_criterionEvaluations is EqualUnmodifiableListView)
      return _criterionEvaluations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_criterionEvaluations);
  }

  @override
  final int matchedCount;
  @override
  final int notMatchedCount;
  @override
  final int unknownCount;
  @override
  final int needsVerificationCount;
  @override
  final String explanation;

  @override
  String toString() {
    return 'MatchResult(relevance: $relevance, criterionEvaluations: $criterionEvaluations, matchedCount: $matchedCount, notMatchedCount: $notMatchedCount, unknownCount: $unknownCount, needsVerificationCount: $needsVerificationCount, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchResultImpl &&
            (identical(other.relevance, relevance) ||
                other.relevance == relevance) &&
            const DeepCollectionEquality().equals(
              other._criterionEvaluations,
              _criterionEvaluations,
            ) &&
            (identical(other.matchedCount, matchedCount) ||
                other.matchedCount == matchedCount) &&
            (identical(other.notMatchedCount, notMatchedCount) ||
                other.notMatchedCount == notMatchedCount) &&
            (identical(other.unknownCount, unknownCount) ||
                other.unknownCount == unknownCount) &&
            (identical(other.needsVerificationCount, needsVerificationCount) ||
                other.needsVerificationCount == needsVerificationCount) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    relevance,
    const DeepCollectionEquality().hash(_criterionEvaluations),
    matchedCount,
    notMatchedCount,
    unknownCount,
    needsVerificationCount,
    explanation,
  );

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      __$$MatchResultImplCopyWithImpl<_$MatchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchResultImplToJson(this);
  }
}

abstract class _MatchResult implements MatchResult {
  const factory _MatchResult({
    required final RelevanceTier relevance,
    required final List<CriterionEvaluation> criterionEvaluations,
    required final int matchedCount,
    required final int notMatchedCount,
    required final int unknownCount,
    required final int needsVerificationCount,
    required final String explanation,
  }) = _$MatchResultImpl;

  factory _MatchResult.fromJson(Map<String, dynamic> json) =
      _$MatchResultImpl.fromJson;

  @override
  RelevanceTier get relevance;
  @override
  List<CriterionEvaluation> get criterionEvaluations;
  @override
  int get matchedCount;
  @override
  int get notMatchedCount;
  @override
  int get unknownCount;
  @override
  int get needsVerificationCount;
  @override
  String get explanation;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
