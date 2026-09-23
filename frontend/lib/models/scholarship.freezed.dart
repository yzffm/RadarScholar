// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scholarship.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScholarshipSource _$ScholarshipSourceFromJson(Map<String, dynamic> json) {
  return _ScholarshipSource.fromJson(json);
}

/// @nodoc
mixin _$ScholarshipSource {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_name')
  String get providerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_url')
  String get sourceUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'crawl_allowed')
  bool get crawlAllowed => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ScholarshipSource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScholarshipSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScholarshipSourceCopyWith<ScholarshipSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScholarshipSourceCopyWith<$Res> {
  factory $ScholarshipSourceCopyWith(
    ScholarshipSource value,
    $Res Function(ScholarshipSource) then,
  ) = _$ScholarshipSourceCopyWithImpl<$Res, ScholarshipSource>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'provider_name') String providerName,
    @JsonKey(name: 'source_url') String sourceUrl,
    @JsonKey(name: 'crawl_allowed') bool crawlAllowed,
    bool active,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$ScholarshipSourceCopyWithImpl<$Res, $Val extends ScholarshipSource>
    implements $ScholarshipSourceCopyWith<$Res> {
  _$ScholarshipSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScholarshipSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerName = null,
    Object? sourceUrl = null,
    Object? crawlAllowed = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            providerName: null == providerName
                ? _value.providerName
                : providerName // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceUrl: null == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            crawlAllowed: null == crawlAllowed
                ? _value.crawlAllowed
                : crawlAllowed // ignore: cast_nullable_to_non_nullable
                      as bool,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$ScholarshipSourceImplCopyWith<$Res>
    implements $ScholarshipSourceCopyWith<$Res> {
  factory _$$ScholarshipSourceImplCopyWith(
    _$ScholarshipSourceImpl value,
    $Res Function(_$ScholarshipSourceImpl) then,
  ) = __$$ScholarshipSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'provider_name') String providerName,
    @JsonKey(name: 'source_url') String sourceUrl,
    @JsonKey(name: 'crawl_allowed') bool crawlAllowed,
    bool active,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$ScholarshipSourceImplCopyWithImpl<$Res>
    extends _$ScholarshipSourceCopyWithImpl<$Res, _$ScholarshipSourceImpl>
    implements _$$ScholarshipSourceImplCopyWith<$Res> {
  __$$ScholarshipSourceImplCopyWithImpl(
    _$ScholarshipSourceImpl _value,
    $Res Function(_$ScholarshipSourceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScholarshipSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerName = null,
    Object? sourceUrl = null,
    Object? crawlAllowed = null,
    Object? active = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ScholarshipSourceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        providerName: null == providerName
            ? _value.providerName
            : providerName // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceUrl: null == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        crawlAllowed: null == crawlAllowed
            ? _value.crawlAllowed
            : crawlAllowed // ignore: cast_nullable_to_non_nullable
                  as bool,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$ScholarshipSourceImpl implements _ScholarshipSource {
  const _$ScholarshipSourceImpl({
    required this.id,
    @JsonKey(name: 'provider_name') required this.providerName,
    @JsonKey(name: 'source_url') required this.sourceUrl,
    @JsonKey(name: 'crawl_allowed') this.crawlAllowed = true,
    this.active = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$ScholarshipSourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScholarshipSourceImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'provider_name')
  final String providerName;
  @override
  @JsonKey(name: 'source_url')
  final String sourceUrl;
  @override
  @JsonKey(name: 'crawl_allowed')
  final bool crawlAllowed;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ScholarshipSource(id: $id, providerName: $providerName, sourceUrl: $sourceUrl, crawlAllowed: $crawlAllowed, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScholarshipSourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.crawlAllowed, crawlAllowed) ||
                other.crawlAllowed == crawlAllowed) &&
            (identical(other.active, active) || other.active == active) &&
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
    providerName,
    sourceUrl,
    crawlAllowed,
    active,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ScholarshipSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScholarshipSourceImplCopyWith<_$ScholarshipSourceImpl> get copyWith =>
      __$$ScholarshipSourceImplCopyWithImpl<_$ScholarshipSourceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScholarshipSourceImplToJson(this);
  }
}

abstract class _ScholarshipSource implements ScholarshipSource {
  const factory _ScholarshipSource({
    required final String id,
    @JsonKey(name: 'provider_name') required final String providerName,
    @JsonKey(name: 'source_url') required final String sourceUrl,
    @JsonKey(name: 'crawl_allowed') final bool crawlAllowed,
    final bool active,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$ScholarshipSourceImpl;

  factory _ScholarshipSource.fromJson(Map<String, dynamic> json) =
      _$ScholarshipSourceImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'provider_name')
  String get providerName;
  @override
  @JsonKey(name: 'source_url')
  String get sourceUrl;
  @override
  @JsonKey(name: 'crawl_allowed')
  bool get crawlAllowed;
  @override
  bool get active;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ScholarshipSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScholarshipSourceImplCopyWith<_$ScholarshipSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScholarshipBenefit _$ScholarshipBenefitFromJson(Map<String, dynamic> json) {
  return _ScholarshipBenefit.fromJson(json);
}

/// @nodoc
mixin _$ScholarshipBenefit {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId => throw _privateConstructorUsedError;
  @JsonKey(name: 'benefit_type')
  String get benefitType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ScholarshipBenefit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScholarshipBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScholarshipBenefitCopyWith<ScholarshipBenefit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScholarshipBenefitCopyWith<$Res> {
  factory $ScholarshipBenefitCopyWith(
    ScholarshipBenefit value,
    $Res Function(ScholarshipBenefit) then,
  ) = _$ScholarshipBenefitCopyWithImpl<$Res, ScholarshipBenefit>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'benefit_type') String benefitType,
    String description,
  });
}

/// @nodoc
class _$ScholarshipBenefitCopyWithImpl<$Res, $Val extends ScholarshipBenefit>
    implements $ScholarshipBenefitCopyWith<$Res> {
  _$ScholarshipBenefitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScholarshipBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scholarshipId = null,
    Object? benefitType = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            scholarshipId: null == scholarshipId
                ? _value.scholarshipId
                : scholarshipId // ignore: cast_nullable_to_non_nullable
                      as String,
            benefitType: null == benefitType
                ? _value.benefitType
                : benefitType // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScholarshipBenefitImplCopyWith<$Res>
    implements $ScholarshipBenefitCopyWith<$Res> {
  factory _$$ScholarshipBenefitImplCopyWith(
    _$ScholarshipBenefitImpl value,
    $Res Function(_$ScholarshipBenefitImpl) then,
  ) = __$$ScholarshipBenefitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'benefit_type') String benefitType,
    String description,
  });
}

/// @nodoc
class __$$ScholarshipBenefitImplCopyWithImpl<$Res>
    extends _$ScholarshipBenefitCopyWithImpl<$Res, _$ScholarshipBenefitImpl>
    implements _$$ScholarshipBenefitImplCopyWith<$Res> {
  __$$ScholarshipBenefitImplCopyWithImpl(
    _$ScholarshipBenefitImpl _value,
    $Res Function(_$ScholarshipBenefitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScholarshipBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scholarshipId = null,
    Object? benefitType = null,
    Object? description = null,
  }) {
    return _then(
      _$ScholarshipBenefitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        scholarshipId: null == scholarshipId
            ? _value.scholarshipId
            : scholarshipId // ignore: cast_nullable_to_non_nullable
                  as String,
        benefitType: null == benefitType
            ? _value.benefitType
            : benefitType // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScholarshipBenefitImpl implements _ScholarshipBenefit {
  const _$ScholarshipBenefitImpl({
    required this.id,
    @JsonKey(name: 'scholarship_id') required this.scholarshipId,
    @JsonKey(name: 'benefit_type') required this.benefitType,
    required this.description,
  });

  factory _$ScholarshipBenefitImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScholarshipBenefitImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'scholarship_id')
  final String scholarshipId;
  @override
  @JsonKey(name: 'benefit_type')
  final String benefitType;
  @override
  final String description;

  @override
  String toString() {
    return 'ScholarshipBenefit(id: $id, scholarshipId: $scholarshipId, benefitType: $benefitType, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScholarshipBenefitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scholarshipId, scholarshipId) ||
                other.scholarshipId == scholarshipId) &&
            (identical(other.benefitType, benefitType) ||
                other.benefitType == benefitType) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, scholarshipId, benefitType, description);

  /// Create a copy of ScholarshipBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScholarshipBenefitImplCopyWith<_$ScholarshipBenefitImpl> get copyWith =>
      __$$ScholarshipBenefitImplCopyWithImpl<_$ScholarshipBenefitImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScholarshipBenefitImplToJson(this);
  }
}

abstract class _ScholarshipBenefit implements ScholarshipBenefit {
  const factory _ScholarshipBenefit({
    required final String id,
    @JsonKey(name: 'scholarship_id') required final String scholarshipId,
    @JsonKey(name: 'benefit_type') required final String benefitType,
    required final String description,
  }) = _$ScholarshipBenefitImpl;

  factory _ScholarshipBenefit.fromJson(Map<String, dynamic> json) =
      _$ScholarshipBenefitImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId;
  @override
  @JsonKey(name: 'benefit_type')
  String get benefitType;
  @override
  String get description;

  /// Create a copy of ScholarshipBenefit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScholarshipBenefitImplCopyWith<_$ScholarshipBenefitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScholarshipRequirement _$ScholarshipRequirementFromJson(
  Map<String, dynamic> json,
) {
  return _ScholarshipRequirement.fromJson(json);
}

/// @nodoc
mixin _$ScholarshipRequirement {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId => throw _privateConstructorUsedError;
  @JsonKey(name: 'requirement_type')
  String get requirementType => throw _privateConstructorUsedError;
  String get operator => throw _privateConstructorUsedError;
  dynamic get value => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ScholarshipRequirement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScholarshipRequirement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScholarshipRequirementCopyWith<ScholarshipRequirement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScholarshipRequirementCopyWith<$Res> {
  factory $ScholarshipRequirementCopyWith(
    ScholarshipRequirement value,
    $Res Function(ScholarshipRequirement) then,
  ) = _$ScholarshipRequirementCopyWithImpl<$Res, ScholarshipRequirement>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'requirement_type') String requirementType,
    String operator,
    dynamic value,
    String description,
  });
}

/// @nodoc
class _$ScholarshipRequirementCopyWithImpl<
  $Res,
  $Val extends ScholarshipRequirement
>
    implements $ScholarshipRequirementCopyWith<$Res> {
  _$ScholarshipRequirementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScholarshipRequirement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scholarshipId = null,
    Object? requirementType = null,
    Object? operator = null,
    Object? value = freezed,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            scholarshipId: null == scholarshipId
                ? _value.scholarshipId
                : scholarshipId // ignore: cast_nullable_to_non_nullable
                      as String,
            requirementType: null == requirementType
                ? _value.requirementType
                : requirementType // ignore: cast_nullable_to_non_nullable
                      as String,
            operator: null == operator
                ? _value.operator
                : operator // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScholarshipRequirementImplCopyWith<$Res>
    implements $ScholarshipRequirementCopyWith<$Res> {
  factory _$$ScholarshipRequirementImplCopyWith(
    _$ScholarshipRequirementImpl value,
    $Res Function(_$ScholarshipRequirementImpl) then,
  ) = __$$ScholarshipRequirementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'scholarship_id') String scholarshipId,
    @JsonKey(name: 'requirement_type') String requirementType,
    String operator,
    dynamic value,
    String description,
  });
}

/// @nodoc
class __$$ScholarshipRequirementImplCopyWithImpl<$Res>
    extends
        _$ScholarshipRequirementCopyWithImpl<$Res, _$ScholarshipRequirementImpl>
    implements _$$ScholarshipRequirementImplCopyWith<$Res> {
  __$$ScholarshipRequirementImplCopyWithImpl(
    _$ScholarshipRequirementImpl _value,
    $Res Function(_$ScholarshipRequirementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScholarshipRequirement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scholarshipId = null,
    Object? requirementType = null,
    Object? operator = null,
    Object? value = freezed,
    Object? description = null,
  }) {
    return _then(
      _$ScholarshipRequirementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        scholarshipId: null == scholarshipId
            ? _value.scholarshipId
            : scholarshipId // ignore: cast_nullable_to_non_nullable
                  as String,
        requirementType: null == requirementType
            ? _value.requirementType
            : requirementType // ignore: cast_nullable_to_non_nullable
                  as String,
        operator: null == operator
            ? _value.operator
            : operator // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScholarshipRequirementImpl implements _ScholarshipRequirement {
  const _$ScholarshipRequirementImpl({
    required this.id,
    @JsonKey(name: 'scholarship_id') required this.scholarshipId,
    @JsonKey(name: 'requirement_type') required this.requirementType,
    required this.operator,
    required this.value,
    required this.description,
  });

  factory _$ScholarshipRequirementImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScholarshipRequirementImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'scholarship_id')
  final String scholarshipId;
  @override
  @JsonKey(name: 'requirement_type')
  final String requirementType;
  @override
  final String operator;
  @override
  final dynamic value;
  @override
  final String description;

  @override
  String toString() {
    return 'ScholarshipRequirement(id: $id, scholarshipId: $scholarshipId, requirementType: $requirementType, operator: $operator, value: $value, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScholarshipRequirementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scholarshipId, scholarshipId) ||
                other.scholarshipId == scholarshipId) &&
            (identical(other.requirementType, requirementType) ||
                other.requirementType == requirementType) &&
            (identical(other.operator, operator) ||
                other.operator == operator) &&
            const DeepCollectionEquality().equals(other.value, value) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    scholarshipId,
    requirementType,
    operator,
    const DeepCollectionEquality().hash(value),
    description,
  );

  /// Create a copy of ScholarshipRequirement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScholarshipRequirementImplCopyWith<_$ScholarshipRequirementImpl>
  get copyWith =>
      __$$ScholarshipRequirementImplCopyWithImpl<_$ScholarshipRequirementImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScholarshipRequirementImplToJson(this);
  }
}

abstract class _ScholarshipRequirement implements ScholarshipRequirement {
  const factory _ScholarshipRequirement({
    required final String id,
    @JsonKey(name: 'scholarship_id') required final String scholarshipId,
    @JsonKey(name: 'requirement_type') required final String requirementType,
    required final String operator,
    required final dynamic value,
    required final String description,
  }) = _$ScholarshipRequirementImpl;

  factory _ScholarshipRequirement.fromJson(Map<String, dynamic> json) =
      _$ScholarshipRequirementImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'scholarship_id')
  String get scholarshipId;
  @override
  @JsonKey(name: 'requirement_type')
  String get requirementType;
  @override
  String get operator;
  @override
  dynamic get value;
  @override
  String get description;

  /// Create a copy of ScholarshipRequirement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScholarshipRequirementImplCopyWith<_$ScholarshipRequirementImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Scholarship _$ScholarshipFromJson(Map<String, dynamic> json) {
  return _Scholarship.fromJson(json);
}

/// @nodoc
mixin _$Scholarship {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_id')
  String get sourceId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  @JsonKey(name: 'application_url')
  String get applicationUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<ScholarshipBenefit> get benefits => throw _privateConstructorUsedError;
  List<ScholarshipRequirement> get requirements =>
      throw _privateConstructorUsedError;
  ScholarshipSource? get source => throw _privateConstructorUsedError;

  /// Serializes this Scholarship to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScholarshipCopyWith<Scholarship> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScholarshipCopyWith<$Res> {
  factory $ScholarshipCopyWith(
    Scholarship value,
    $Res Function(Scholarship) then,
  ) = _$ScholarshipCopyWithImpl<$Res, Scholarship>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'source_id') String sourceId,
    String title,
    String summary,
    String description,
    DateTime? deadline,
    @JsonKey(name: 'application_url') String applicationUrl,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    List<ScholarshipBenefit> benefits,
    List<ScholarshipRequirement> requirements,
    ScholarshipSource? source,
  });

  $ScholarshipSourceCopyWith<$Res>? get source;
}

/// @nodoc
class _$ScholarshipCopyWithImpl<$Res, $Val extends Scholarship>
    implements $ScholarshipCopyWith<$Res> {
  _$ScholarshipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceId = null,
    Object? title = null,
    Object? summary = null,
    Object? description = null,
    Object? deadline = freezed,
    Object? applicationUrl = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? benefits = null,
    Object? requirements = null,
    Object? source = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceId: null == sourceId
                ? _value.sourceId
                : sourceId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            deadline: freezed == deadline
                ? _value.deadline
                : deadline // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            applicationUrl: null == applicationUrl
                ? _value.applicationUrl
                : applicationUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            benefits: null == benefits
                ? _value.benefits
                : benefits // ignore: cast_nullable_to_non_nullable
                      as List<ScholarshipBenefit>,
            requirements: null == requirements
                ? _value.requirements
                : requirements // ignore: cast_nullable_to_non_nullable
                      as List<ScholarshipRequirement>,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ScholarshipSource?,
          )
          as $Val,
    );
  }

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScholarshipSourceCopyWith<$Res>? get source {
    if (_value.source == null) {
      return null;
    }

    return $ScholarshipSourceCopyWith<$Res>(_value.source!, (value) {
      return _then(_value.copyWith(source: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScholarshipImplCopyWith<$Res>
    implements $ScholarshipCopyWith<$Res> {
  factory _$$ScholarshipImplCopyWith(
    _$ScholarshipImpl value,
    $Res Function(_$ScholarshipImpl) then,
  ) = __$$ScholarshipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'source_id') String sourceId,
    String title,
    String summary,
    String description,
    DateTime? deadline,
    @JsonKey(name: 'application_url') String applicationUrl,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    List<ScholarshipBenefit> benefits,
    List<ScholarshipRequirement> requirements,
    ScholarshipSource? source,
  });

  @override
  $ScholarshipSourceCopyWith<$Res>? get source;
}

/// @nodoc
class __$$ScholarshipImplCopyWithImpl<$Res>
    extends _$ScholarshipCopyWithImpl<$Res, _$ScholarshipImpl>
    implements _$$ScholarshipImplCopyWith<$Res> {
  __$$ScholarshipImplCopyWithImpl(
    _$ScholarshipImpl _value,
    $Res Function(_$ScholarshipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceId = null,
    Object? title = null,
    Object? summary = null,
    Object? description = null,
    Object? deadline = freezed,
    Object? applicationUrl = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? benefits = null,
    Object? requirements = null,
    Object? source = freezed,
  }) {
    return _then(
      _$ScholarshipImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceId: null == sourceId
            ? _value.sourceId
            : sourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        deadline: freezed == deadline
            ? _value.deadline
            : deadline // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        applicationUrl: null == applicationUrl
            ? _value.applicationUrl
            : applicationUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        benefits: null == benefits
            ? _value._benefits
            : benefits // ignore: cast_nullable_to_non_nullable
                  as List<ScholarshipBenefit>,
        requirements: null == requirements
            ? _value._requirements
            : requirements // ignore: cast_nullable_to_non_nullable
                  as List<ScholarshipRequirement>,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ScholarshipSource?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScholarshipImpl implements _Scholarship {
  const _$ScholarshipImpl({
    required this.id,
    @JsonKey(name: 'source_id') required this.sourceId,
    required this.title,
    required this.summary,
    required this.description,
    this.deadline,
    @JsonKey(name: 'application_url') required this.applicationUrl,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    final List<ScholarshipBenefit> benefits = const [],
    final List<ScholarshipRequirement> requirements = const [],
    this.source,
  }) : _benefits = benefits,
       _requirements = requirements;

  factory _$ScholarshipImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScholarshipImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'source_id')
  final String sourceId;
  @override
  final String title;
  @override
  final String summary;
  @override
  final String description;
  @override
  final DateTime? deadline;
  @override
  @JsonKey(name: 'application_url')
  final String applicationUrl;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<ScholarshipBenefit> _benefits;
  @override
  @JsonKey()
  List<ScholarshipBenefit> get benefits {
    if (_benefits is EqualUnmodifiableListView) return _benefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benefits);
  }

  final List<ScholarshipRequirement> _requirements;
  @override
  @JsonKey()
  List<ScholarshipRequirement> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  @override
  final ScholarshipSource? source;

  @override
  String toString() {
    return 'Scholarship(id: $id, sourceId: $sourceId, title: $title, summary: $summary, description: $description, deadline: $deadline, applicationUrl: $applicationUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, benefits: $benefits, requirements: $requirements, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScholarshipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.applicationUrl, applicationUrl) ||
                other.applicationUrl == applicationUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._benefits, _benefits) &&
            const DeepCollectionEquality().equals(
              other._requirements,
              _requirements,
            ) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sourceId,
    title,
    summary,
    description,
    deadline,
    applicationUrl,
    isActive,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_benefits),
    const DeepCollectionEquality().hash(_requirements),
    source,
  );

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScholarshipImplCopyWith<_$ScholarshipImpl> get copyWith =>
      __$$ScholarshipImplCopyWithImpl<_$ScholarshipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScholarshipImplToJson(this);
  }
}

abstract class _Scholarship implements Scholarship {
  const factory _Scholarship({
    required final String id,
    @JsonKey(name: 'source_id') required final String sourceId,
    required final String title,
    required final String summary,
    required final String description,
    final DateTime? deadline,
    @JsonKey(name: 'application_url') required final String applicationUrl,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    final List<ScholarshipBenefit> benefits,
    final List<ScholarshipRequirement> requirements,
    final ScholarshipSource? source,
  }) = _$ScholarshipImpl;

  factory _Scholarship.fromJson(Map<String, dynamic> json) =
      _$ScholarshipImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'source_id')
  String get sourceId;
  @override
  String get title;
  @override
  String get summary;
  @override
  String get description;
  @override
  DateTime? get deadline;
  @override
  @JsonKey(name: 'application_url')
  String get applicationUrl;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  List<ScholarshipBenefit> get benefits;
  @override
  List<ScholarshipRequirement> get requirements;
  @override
  ScholarshipSource? get source;

  /// Create a copy of Scholarship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScholarshipImplCopyWith<_$ScholarshipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScholarshipListResponse _$ScholarshipListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ScholarshipListResponse.fromJson(json);
}

/// @nodoc
mixin _$ScholarshipListResponse {
  List<Scholarship> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_size')
  int get pageSize => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this ScholarshipListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScholarshipListResponseCopyWith<ScholarshipListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScholarshipListResponseCopyWith<$Res> {
  factory $ScholarshipListResponseCopyWith(
    ScholarshipListResponse value,
    $Res Function(ScholarshipListResponse) then,
  ) = _$ScholarshipListResponseCopyWithImpl<$Res, ScholarshipListResponse>;
  @useResult
  $Res call({
    List<Scholarship> items,
    int page,
    @JsonKey(name: 'page_size') int pageSize,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class _$ScholarshipListResponseCopyWithImpl<
  $Res,
  $Val extends ScholarshipListResponse
>
    implements $ScholarshipListResponseCopyWith<$Res> {
  _$ScholarshipListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Scholarship>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScholarshipListResponseImplCopyWith<$Res>
    implements $ScholarshipListResponseCopyWith<$Res> {
  factory _$$ScholarshipListResponseImplCopyWith(
    _$ScholarshipListResponseImpl value,
    $Res Function(_$ScholarshipListResponseImpl) then,
  ) = __$$ScholarshipListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Scholarship> items,
    int page,
    @JsonKey(name: 'page_size') int pageSize,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class __$$ScholarshipListResponseImplCopyWithImpl<$Res>
    extends
        _$ScholarshipListResponseCopyWithImpl<
          $Res,
          _$ScholarshipListResponseImpl
        >
    implements _$$ScholarshipListResponseImplCopyWith<$Res> {
  __$$ScholarshipListResponseImplCopyWithImpl(
    _$ScholarshipListResponseImpl _value,
    $Res Function(_$ScholarshipListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$ScholarshipListResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Scholarship>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScholarshipListResponseImpl implements _ScholarshipListResponse {
  const _$ScholarshipListResponseImpl({
    required final List<Scholarship> items,
    required this.page,
    @JsonKey(name: 'page_size') required this.pageSize,
    required this.total,
    @JsonKey(name: 'total_pages') required this.totalPages,
  }) : _items = items;

  factory _$ScholarshipListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScholarshipListResponseImplFromJson(json);

  final List<Scholarship> _items;
  @override
  List<Scholarship> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  @JsonKey(name: 'page_size')
  final int pageSize;
  @override
  final int total;
  @override
  @JsonKey(name: 'total_pages')
  final int totalPages;

  @override
  String toString() {
    return 'ScholarshipListResponse(items: $items, page: $page, pageSize: $pageSize, total: $total, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScholarshipListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    pageSize,
    total,
    totalPages,
  );

  /// Create a copy of ScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScholarshipListResponseImplCopyWith<_$ScholarshipListResponseImpl>
  get copyWith =>
      __$$ScholarshipListResponseImplCopyWithImpl<
        _$ScholarshipListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScholarshipListResponseImplToJson(this);
  }
}

abstract class _ScholarshipListResponse implements ScholarshipListResponse {
  const factory _ScholarshipListResponse({
    required final List<Scholarship> items,
    required final int page,
    @JsonKey(name: 'page_size') required final int pageSize,
    required final int total,
    @JsonKey(name: 'total_pages') required final int totalPages,
  }) = _$ScholarshipListResponseImpl;

  factory _ScholarshipListResponse.fromJson(Map<String, dynamic> json) =
      _$ScholarshipListResponseImpl.fromJson;

  @override
  List<Scholarship> get items;
  @override
  int get page;
  @override
  @JsonKey(name: 'page_size')
  int get pageSize;
  @override
  int get total;
  @override
  @JsonKey(name: 'total_pages')
  int get totalPages;

  /// Create a copy of ScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScholarshipListResponseImplCopyWith<_$ScholarshipListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MatchedScholarshipResponse _$MatchedScholarshipResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MatchedScholarshipResponse.fromJson(json);
}

/// @nodoc
mixin _$MatchedScholarshipResponse {
  Scholarship get scholarship => throw _privateConstructorUsedError;
  MatchResult get match => throw _privateConstructorUsedError;

  /// Serializes this MatchedScholarshipResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedScholarshipResponseCopyWith<MatchedScholarshipResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedScholarshipResponseCopyWith<$Res> {
  factory $MatchedScholarshipResponseCopyWith(
    MatchedScholarshipResponse value,
    $Res Function(MatchedScholarshipResponse) then,
  ) =
      _$MatchedScholarshipResponseCopyWithImpl<
        $Res,
        MatchedScholarshipResponse
      >;
  @useResult
  $Res call({Scholarship scholarship, MatchResult match});

  $ScholarshipCopyWith<$Res> get scholarship;
  $MatchResultCopyWith<$Res> get match;
}

/// @nodoc
class _$MatchedScholarshipResponseCopyWithImpl<
  $Res,
  $Val extends MatchedScholarshipResponse
>
    implements $MatchedScholarshipResponseCopyWith<$Res> {
  _$MatchedScholarshipResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? scholarship = null, Object? match = null}) {
    return _then(
      _value.copyWith(
            scholarship: null == scholarship
                ? _value.scholarship
                : scholarship // ignore: cast_nullable_to_non_nullable
                      as Scholarship,
            match: null == match
                ? _value.match
                : match // ignore: cast_nullable_to_non_nullable
                      as MatchResult,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScholarshipCopyWith<$Res> get scholarship {
    return $ScholarshipCopyWith<$Res>(_value.scholarship, (value) {
      return _then(_value.copyWith(scholarship: value) as $Val);
    });
  }

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchResultCopyWith<$Res> get match {
    return $MatchResultCopyWith<$Res>(_value.match, (value) {
      return _then(_value.copyWith(match: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchedScholarshipResponseImplCopyWith<$Res>
    implements $MatchedScholarshipResponseCopyWith<$Res> {
  factory _$$MatchedScholarshipResponseImplCopyWith(
    _$MatchedScholarshipResponseImpl value,
    $Res Function(_$MatchedScholarshipResponseImpl) then,
  ) = __$$MatchedScholarshipResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Scholarship scholarship, MatchResult match});

  @override
  $ScholarshipCopyWith<$Res> get scholarship;
  @override
  $MatchResultCopyWith<$Res> get match;
}

/// @nodoc
class __$$MatchedScholarshipResponseImplCopyWithImpl<$Res>
    extends
        _$MatchedScholarshipResponseCopyWithImpl<
          $Res,
          _$MatchedScholarshipResponseImpl
        >
    implements _$$MatchedScholarshipResponseImplCopyWith<$Res> {
  __$$MatchedScholarshipResponseImplCopyWithImpl(
    _$MatchedScholarshipResponseImpl _value,
    $Res Function(_$MatchedScholarshipResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? scholarship = null, Object? match = null}) {
    return _then(
      _$MatchedScholarshipResponseImpl(
        scholarship: null == scholarship
            ? _value.scholarship
            : scholarship // ignore: cast_nullable_to_non_nullable
                  as Scholarship,
        match: null == match
            ? _value.match
            : match // ignore: cast_nullable_to_non_nullable
                  as MatchResult,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedScholarshipResponseImpl implements _MatchedScholarshipResponse {
  const _$MatchedScholarshipResponseImpl({
    required this.scholarship,
    required this.match,
  });

  factory _$MatchedScholarshipResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MatchedScholarshipResponseImplFromJson(json);

  @override
  final Scholarship scholarship;
  @override
  final MatchResult match;

  @override
  String toString() {
    return 'MatchedScholarshipResponse(scholarship: $scholarship, match: $match)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedScholarshipResponseImpl &&
            (identical(other.scholarship, scholarship) ||
                other.scholarship == scholarship) &&
            (identical(other.match, match) || other.match == match));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, scholarship, match);

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedScholarshipResponseImplCopyWith<_$MatchedScholarshipResponseImpl>
  get copyWith =>
      __$$MatchedScholarshipResponseImplCopyWithImpl<
        _$MatchedScholarshipResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedScholarshipResponseImplToJson(this);
  }
}

abstract class _MatchedScholarshipResponse
    implements MatchedScholarshipResponse {
  const factory _MatchedScholarshipResponse({
    required final Scholarship scholarship,
    required final MatchResult match,
  }) = _$MatchedScholarshipResponseImpl;

  factory _MatchedScholarshipResponse.fromJson(Map<String, dynamic> json) =
      _$MatchedScholarshipResponseImpl.fromJson;

  @override
  Scholarship get scholarship;
  @override
  MatchResult get match;

  /// Create a copy of MatchedScholarshipResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedScholarshipResponseImplCopyWith<_$MatchedScholarshipResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MatchedScholarshipListResponse _$MatchedScholarshipListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MatchedScholarshipListResponse.fromJson(json);
}

/// @nodoc
mixin _$MatchedScholarshipListResponse {
  List<MatchedScholarshipResponse> get items =>
      throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_size')
  int get pageSize => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pages')
  int get totalPages => throw _privateConstructorUsedError;

  /// Serializes this MatchedScholarshipListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedScholarshipListResponseCopyWith<MatchedScholarshipListResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedScholarshipListResponseCopyWith<$Res> {
  factory $MatchedScholarshipListResponseCopyWith(
    MatchedScholarshipListResponse value,
    $Res Function(MatchedScholarshipListResponse) then,
  ) =
      _$MatchedScholarshipListResponseCopyWithImpl<
        $Res,
        MatchedScholarshipListResponse
      >;
  @useResult
  $Res call({
    List<MatchedScholarshipResponse> items,
    int page,
    @JsonKey(name: 'page_size') int pageSize,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class _$MatchedScholarshipListResponseCopyWithImpl<
  $Res,
  $Val extends MatchedScholarshipListResponse
>
    implements $MatchedScholarshipListResponseCopyWith<$Res> {
  _$MatchedScholarshipListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<MatchedScholarshipResponse>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchedScholarshipListResponseImplCopyWith<$Res>
    implements $MatchedScholarshipListResponseCopyWith<$Res> {
  factory _$$MatchedScholarshipListResponseImplCopyWith(
    _$MatchedScholarshipListResponseImpl value,
    $Res Function(_$MatchedScholarshipListResponseImpl) then,
  ) = __$$MatchedScholarshipListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MatchedScholarshipResponse> items,
    int page,
    @JsonKey(name: 'page_size') int pageSize,
    int total,
    @JsonKey(name: 'total_pages') int totalPages,
  });
}

/// @nodoc
class __$$MatchedScholarshipListResponseImplCopyWithImpl<$Res>
    extends
        _$MatchedScholarshipListResponseCopyWithImpl<
          $Res,
          _$MatchedScholarshipListResponseImpl
        >
    implements _$$MatchedScholarshipListResponseImplCopyWith<$Res> {
  __$$MatchedScholarshipListResponseImplCopyWithImpl(
    _$MatchedScholarshipListResponseImpl _value,
    $Res Function(_$MatchedScholarshipListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchedScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? pageSize = null,
    Object? total = null,
    Object? totalPages = null,
  }) {
    return _then(
      _$MatchedScholarshipListResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<MatchedScholarshipResponse>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedScholarshipListResponseImpl
    implements _MatchedScholarshipListResponse {
  const _$MatchedScholarshipListResponseImpl({
    required final List<MatchedScholarshipResponse> items,
    required this.page,
    @JsonKey(name: 'page_size') required this.pageSize,
    required this.total,
    @JsonKey(name: 'total_pages') required this.totalPages,
  }) : _items = items;

  factory _$MatchedScholarshipListResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MatchedScholarshipListResponseImplFromJson(json);

  final List<MatchedScholarshipResponse> _items;
  @override
  List<MatchedScholarshipResponse> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  @JsonKey(name: 'page_size')
  final int pageSize;
  @override
  final int total;
  @override
  @JsonKey(name: 'total_pages')
  final int totalPages;

  @override
  String toString() {
    return 'MatchedScholarshipListResponse(items: $items, page: $page, pageSize: $pageSize, total: $total, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedScholarshipListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    pageSize,
    total,
    totalPages,
  );

  /// Create a copy of MatchedScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedScholarshipListResponseImplCopyWith<
    _$MatchedScholarshipListResponseImpl
  >
  get copyWith =>
      __$$MatchedScholarshipListResponseImplCopyWithImpl<
        _$MatchedScholarshipListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedScholarshipListResponseImplToJson(this);
  }
}

abstract class _MatchedScholarshipListResponse
    implements MatchedScholarshipListResponse {
  const factory _MatchedScholarshipListResponse({
    required final List<MatchedScholarshipResponse> items,
    required final int page,
    @JsonKey(name: 'page_size') required final int pageSize,
    required final int total,
    @JsonKey(name: 'total_pages') required final int totalPages,
  }) = _$MatchedScholarshipListResponseImpl;

  factory _MatchedScholarshipListResponse.fromJson(Map<String, dynamic> json) =
      _$MatchedScholarshipListResponseImpl.fromJson;

  @override
  List<MatchedScholarshipResponse> get items;
  @override
  int get page;
  @override
  @JsonKey(name: 'page_size')
  int get pageSize;
  @override
  int get total;
  @override
  @JsonKey(name: 'total_pages')
  int get totalPages;

  /// Create a copy of MatchedScholarshipListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedScholarshipListResponseImplCopyWith<
    _$MatchedScholarshipListResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
