// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_explanation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchExplanation _$MatchExplanationFromJson(Map<String, dynamic> json) {
  return _MatchExplanation.fromJson(json);
}

/// @nodoc
mixin _$MatchExplanation {
  String get summary => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get weaknesses => throw _privateConstructorUsedError;
  List<String> get unknowns => throw _privateConstructorUsedError;

  /// Serializes this MatchExplanation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchExplanation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchExplanationCopyWith<MatchExplanation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchExplanationCopyWith<$Res> {
  factory $MatchExplanationCopyWith(
    MatchExplanation value,
    $Res Function(MatchExplanation) then,
  ) = _$MatchExplanationCopyWithImpl<$Res, MatchExplanation>;
  @useResult
  $Res call({
    String summary,
    List<String> strengths,
    List<String> weaknesses,
    List<String> unknowns,
  });
}

/// @nodoc
class _$MatchExplanationCopyWithImpl<$Res, $Val extends MatchExplanation>
    implements $MatchExplanationCopyWith<$Res> {
  _$MatchExplanationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchExplanation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? unknowns = null,
  }) {
    return _then(
      _value.copyWith(
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            weaknesses: null == weaknesses
                ? _value.weaknesses
                : weaknesses // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            unknowns: null == unknowns
                ? _value.unknowns
                : unknowns // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchExplanationImplCopyWith<$Res>
    implements $MatchExplanationCopyWith<$Res> {
  factory _$$MatchExplanationImplCopyWith(
    _$MatchExplanationImpl value,
    $Res Function(_$MatchExplanationImpl) then,
  ) = __$$MatchExplanationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String summary,
    List<String> strengths,
    List<String> weaknesses,
    List<String> unknowns,
  });
}

/// @nodoc
class __$$MatchExplanationImplCopyWithImpl<$Res>
    extends _$MatchExplanationCopyWithImpl<$Res, _$MatchExplanationImpl>
    implements _$$MatchExplanationImplCopyWith<$Res> {
  __$$MatchExplanationImplCopyWithImpl(
    _$MatchExplanationImpl _value,
    $Res Function(_$MatchExplanationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchExplanation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? unknowns = null,
  }) {
    return _then(
      _$MatchExplanationImpl(
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        weaknesses: null == weaknesses
            ? _value._weaknesses
            : weaknesses // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        unknowns: null == unknowns
            ? _value._unknowns
            : unknowns // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchExplanationImpl implements _MatchExplanation {
  const _$MatchExplanationImpl({
    required this.summary,
    final List<String> strengths = const [],
    final List<String> weaknesses = const [],
    final List<String> unknowns = const [],
  }) : _strengths = strengths,
       _weaknesses = weaknesses,
       _unknowns = unknowns;

  factory _$MatchExplanationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchExplanationImplFromJson(json);

  @override
  final String summary;
  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _weaknesses;
  @override
  @JsonKey()
  List<String> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  final List<String> _unknowns;
  @override
  @JsonKey()
  List<String> get unknowns {
    if (_unknowns is EqualUnmodifiableListView) return _unknowns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unknowns);
  }

  @override
  String toString() {
    return 'MatchExplanation(summary: $summary, strengths: $strengths, weaknesses: $weaknesses, unknowns: $unknowns)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchExplanationImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._weaknesses,
              _weaknesses,
            ) &&
            const DeepCollectionEquality().equals(other._unknowns, _unknowns));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    summary,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_weaknesses),
    const DeepCollectionEquality().hash(_unknowns),
  );

  /// Create a copy of MatchExplanation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchExplanationImplCopyWith<_$MatchExplanationImpl> get copyWith =>
      __$$MatchExplanationImplCopyWithImpl<_$MatchExplanationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchExplanationImplToJson(this);
  }
}

abstract class _MatchExplanation implements MatchExplanation {
  const factory _MatchExplanation({
    required final String summary,
    final List<String> strengths,
    final List<String> weaknesses,
    final List<String> unknowns,
  }) = _$MatchExplanationImpl;

  factory _MatchExplanation.fromJson(Map<String, dynamic> json) =
      _$MatchExplanationImpl.fromJson;

  @override
  String get summary;
  @override
  List<String> get strengths;
  @override
  List<String> get weaknesses;
  @override
  List<String> get unknowns;

  /// Create a copy of MatchExplanation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchExplanationImplCopyWith<_$MatchExplanationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
