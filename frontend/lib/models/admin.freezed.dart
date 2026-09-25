// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CrawlRun _$CrawlRunFromJson(Map<String, dynamic> json) {
  return _CrawlRun.fromJson(json);
}

/// @nodoc
mixin _$CrawlRun {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'finished_at')
  DateTime? get finishedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'sources_attempted')
  int get sourcesAttempted => throw _privateConstructorUsedError;
  @JsonKey(name: 'sources_succeeded')
  int get sourcesSucceeded => throw _privateConstructorUsedError;
  @JsonKey(name: 'sources_failed')
  int get sourcesFailed => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarships_created')
  int get scholarshipsCreated => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarships_updated')
  int get scholarshipsUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'scholarships_skipped')
  int get scholarshipsSkipped => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_results')
  List<dynamic> get sourceResults => throw _privateConstructorUsedError;

  /// Serializes this CrawlRun to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CrawlRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrawlRunCopyWith<CrawlRun> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrawlRunCopyWith<$Res> {
  factory $CrawlRunCopyWith(CrawlRun value, $Res Function(CrawlRun) then) =
      _$CrawlRunCopyWithImpl<$Res, CrawlRun>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'started_at') DateTime startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    String status,
    @JsonKey(name: 'sources_attempted') int sourcesAttempted,
    @JsonKey(name: 'sources_succeeded') int sourcesSucceeded,
    @JsonKey(name: 'sources_failed') int sourcesFailed,
    @JsonKey(name: 'scholarships_created') int scholarshipsCreated,
    @JsonKey(name: 'scholarships_updated') int scholarshipsUpdated,
    @JsonKey(name: 'scholarships_skipped') int scholarshipsSkipped,
    List<String> errors,
    @JsonKey(name: 'source_results') List<dynamic> sourceResults,
  });
}

/// @nodoc
class _$CrawlRunCopyWithImpl<$Res, $Val extends CrawlRun>
    implements $CrawlRunCopyWith<$Res> {
  _$CrawlRunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrawlRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? status = null,
    Object? sourcesAttempted = null,
    Object? sourcesSucceeded = null,
    Object? sourcesFailed = null,
    Object? scholarshipsCreated = null,
    Object? scholarshipsUpdated = null,
    Object? scholarshipsSkipped = null,
    Object? errors = null,
    Object? sourceResults = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            finishedAt: freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            sourcesAttempted: null == sourcesAttempted
                ? _value.sourcesAttempted
                : sourcesAttempted // ignore: cast_nullable_to_non_nullable
                      as int,
            sourcesSucceeded: null == sourcesSucceeded
                ? _value.sourcesSucceeded
                : sourcesSucceeded // ignore: cast_nullable_to_non_nullable
                      as int,
            sourcesFailed: null == sourcesFailed
                ? _value.sourcesFailed
                : sourcesFailed // ignore: cast_nullable_to_non_nullable
                      as int,
            scholarshipsCreated: null == scholarshipsCreated
                ? _value.scholarshipsCreated
                : scholarshipsCreated // ignore: cast_nullable_to_non_nullable
                      as int,
            scholarshipsUpdated: null == scholarshipsUpdated
                ? _value.scholarshipsUpdated
                : scholarshipsUpdated // ignore: cast_nullable_to_non_nullable
                      as int,
            scholarshipsSkipped: null == scholarshipsSkipped
                ? _value.scholarshipsSkipped
                : scholarshipsSkipped // ignore: cast_nullable_to_non_nullable
                      as int,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sourceResults: null == sourceResults
                ? _value.sourceResults
                : sourceResults // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrawlRunImplCopyWith<$Res>
    implements $CrawlRunCopyWith<$Res> {
  factory _$$CrawlRunImplCopyWith(
    _$CrawlRunImpl value,
    $Res Function(_$CrawlRunImpl) then,
  ) = __$$CrawlRunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'started_at') DateTime startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    String status,
    @JsonKey(name: 'sources_attempted') int sourcesAttempted,
    @JsonKey(name: 'sources_succeeded') int sourcesSucceeded,
    @JsonKey(name: 'sources_failed') int sourcesFailed,
    @JsonKey(name: 'scholarships_created') int scholarshipsCreated,
    @JsonKey(name: 'scholarships_updated') int scholarshipsUpdated,
    @JsonKey(name: 'scholarships_skipped') int scholarshipsSkipped,
    List<String> errors,
    @JsonKey(name: 'source_results') List<dynamic> sourceResults,
  });
}

/// @nodoc
class __$$CrawlRunImplCopyWithImpl<$Res>
    extends _$CrawlRunCopyWithImpl<$Res, _$CrawlRunImpl>
    implements _$$CrawlRunImplCopyWith<$Res> {
  __$$CrawlRunImplCopyWithImpl(
    _$CrawlRunImpl _value,
    $Res Function(_$CrawlRunImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrawlRun
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? status = null,
    Object? sourcesAttempted = null,
    Object? sourcesSucceeded = null,
    Object? sourcesFailed = null,
    Object? scholarshipsCreated = null,
    Object? scholarshipsUpdated = null,
    Object? scholarshipsSkipped = null,
    Object? errors = null,
    Object? sourceResults = null,
  }) {
    return _then(
      _$CrawlRunImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        finishedAt: freezed == finishedAt
            ? _value.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        sourcesAttempted: null == sourcesAttempted
            ? _value.sourcesAttempted
            : sourcesAttempted // ignore: cast_nullable_to_non_nullable
                  as int,
        sourcesSucceeded: null == sourcesSucceeded
            ? _value.sourcesSucceeded
            : sourcesSucceeded // ignore: cast_nullable_to_non_nullable
                  as int,
        sourcesFailed: null == sourcesFailed
            ? _value.sourcesFailed
            : sourcesFailed // ignore: cast_nullable_to_non_nullable
                  as int,
        scholarshipsCreated: null == scholarshipsCreated
            ? _value.scholarshipsCreated
            : scholarshipsCreated // ignore: cast_nullable_to_non_nullable
                  as int,
        scholarshipsUpdated: null == scholarshipsUpdated
            ? _value.scholarshipsUpdated
            : scholarshipsUpdated // ignore: cast_nullable_to_non_nullable
                  as int,
        scholarshipsSkipped: null == scholarshipsSkipped
            ? _value.scholarshipsSkipped
            : scholarshipsSkipped // ignore: cast_nullable_to_non_nullable
                  as int,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sourceResults: null == sourceResults
            ? _value._sourceResults
            : sourceResults // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CrawlRunImpl implements _CrawlRun {
  const _$CrawlRunImpl({
    required this.id,
    @JsonKey(name: 'started_at') required this.startedAt,
    @JsonKey(name: 'finished_at') this.finishedAt,
    required this.status,
    @JsonKey(name: 'sources_attempted') required this.sourcesAttempted,
    @JsonKey(name: 'sources_succeeded') required this.sourcesSucceeded,
    @JsonKey(name: 'sources_failed') required this.sourcesFailed,
    @JsonKey(name: 'scholarships_created') required this.scholarshipsCreated,
    @JsonKey(name: 'scholarships_updated') required this.scholarshipsUpdated,
    @JsonKey(name: 'scholarships_skipped') required this.scholarshipsSkipped,
    final List<String> errors = const [],
    @JsonKey(name: 'source_results')
    final List<dynamic> sourceResults = const [],
  }) : _errors = errors,
       _sourceResults = sourceResults;

  factory _$CrawlRunImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrawlRunImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'started_at')
  final DateTime startedAt;
  @override
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;
  @override
  final String status;
  @override
  @JsonKey(name: 'sources_attempted')
  final int sourcesAttempted;
  @override
  @JsonKey(name: 'sources_succeeded')
  final int sourcesSucceeded;
  @override
  @JsonKey(name: 'sources_failed')
  final int sourcesFailed;
  @override
  @JsonKey(name: 'scholarships_created')
  final int scholarshipsCreated;
  @override
  @JsonKey(name: 'scholarships_updated')
  final int scholarshipsUpdated;
  @override
  @JsonKey(name: 'scholarships_skipped')
  final int scholarshipsSkipped;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  final List<dynamic> _sourceResults;
  @override
  @JsonKey(name: 'source_results')
  List<dynamic> get sourceResults {
    if (_sourceResults is EqualUnmodifiableListView) return _sourceResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceResults);
  }

  @override
  String toString() {
    return 'CrawlRun(id: $id, startedAt: $startedAt, finishedAt: $finishedAt, status: $status, sourcesAttempted: $sourcesAttempted, sourcesSucceeded: $sourcesSucceeded, sourcesFailed: $sourcesFailed, scholarshipsCreated: $scholarshipsCreated, scholarshipsUpdated: $scholarshipsUpdated, scholarshipsSkipped: $scholarshipsSkipped, errors: $errors, sourceResults: $sourceResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrawlRunImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sourcesAttempted, sourcesAttempted) ||
                other.sourcesAttempted == sourcesAttempted) &&
            (identical(other.sourcesSucceeded, sourcesSucceeded) ||
                other.sourcesSucceeded == sourcesSucceeded) &&
            (identical(other.sourcesFailed, sourcesFailed) ||
                other.sourcesFailed == sourcesFailed) &&
            (identical(other.scholarshipsCreated, scholarshipsCreated) ||
                other.scholarshipsCreated == scholarshipsCreated) &&
            (identical(other.scholarshipsUpdated, scholarshipsUpdated) ||
                other.scholarshipsUpdated == scholarshipsUpdated) &&
            (identical(other.scholarshipsSkipped, scholarshipsSkipped) ||
                other.scholarshipsSkipped == scholarshipsSkipped) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            const DeepCollectionEquality().equals(
              other._sourceResults,
              _sourceResults,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    startedAt,
    finishedAt,
    status,
    sourcesAttempted,
    sourcesSucceeded,
    sourcesFailed,
    scholarshipsCreated,
    scholarshipsUpdated,
    scholarshipsSkipped,
    const DeepCollectionEquality().hash(_errors),
    const DeepCollectionEquality().hash(_sourceResults),
  );

  /// Create a copy of CrawlRun
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrawlRunImplCopyWith<_$CrawlRunImpl> get copyWith =>
      __$$CrawlRunImplCopyWithImpl<_$CrawlRunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CrawlRunImplToJson(this);
  }
}

abstract class _CrawlRun implements CrawlRun {
  const factory _CrawlRun({
    required final String id,
    @JsonKey(name: 'started_at') required final DateTime startedAt,
    @JsonKey(name: 'finished_at') final DateTime? finishedAt,
    required final String status,
    @JsonKey(name: 'sources_attempted') required final int sourcesAttempted,
    @JsonKey(name: 'sources_succeeded') required final int sourcesSucceeded,
    @JsonKey(name: 'sources_failed') required final int sourcesFailed,
    @JsonKey(name: 'scholarships_created')
    required final int scholarshipsCreated,
    @JsonKey(name: 'scholarships_updated')
    required final int scholarshipsUpdated,
    @JsonKey(name: 'scholarships_skipped')
    required final int scholarshipsSkipped,
    final List<String> errors,
    @JsonKey(name: 'source_results') final List<dynamic> sourceResults,
  }) = _$CrawlRunImpl;

  factory _CrawlRun.fromJson(Map<String, dynamic> json) =
      _$CrawlRunImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'started_at')
  DateTime get startedAt;
  @override
  @JsonKey(name: 'finished_at')
  DateTime? get finishedAt;
  @override
  String get status;
  @override
  @JsonKey(name: 'sources_attempted')
  int get sourcesAttempted;
  @override
  @JsonKey(name: 'sources_succeeded')
  int get sourcesSucceeded;
  @override
  @JsonKey(name: 'sources_failed')
  int get sourcesFailed;
  @override
  @JsonKey(name: 'scholarships_created')
  int get scholarshipsCreated;
  @override
  @JsonKey(name: 'scholarships_updated')
  int get scholarshipsUpdated;
  @override
  @JsonKey(name: 'scholarships_skipped')
  int get scholarshipsSkipped;
  @override
  List<String> get errors;
  @override
  @JsonKey(name: 'source_results')
  List<dynamic> get sourceResults;

  /// Create a copy of CrawlRun
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrawlRunImplCopyWith<_$CrawlRunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CrawlRunListResponse _$CrawlRunListResponseFromJson(Map<String, dynamic> json) {
  return _CrawlRunListResponse.fromJson(json);
}

/// @nodoc
mixin _$CrawlRunListResponse {
  List<CrawlRun> get items => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get offset => throw _privateConstructorUsedError;

  /// Serializes this CrawlRunListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CrawlRunListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrawlRunListResponseCopyWith<CrawlRunListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrawlRunListResponseCopyWith<$Res> {
  factory $CrawlRunListResponseCopyWith(
    CrawlRunListResponse value,
    $Res Function(CrawlRunListResponse) then,
  ) = _$CrawlRunListResponseCopyWithImpl<$Res, CrawlRunListResponse>;
  @useResult
  $Res call({List<CrawlRun> items, int total, int limit, int offset});
}

/// @nodoc
class _$CrawlRunListResponseCopyWithImpl<
  $Res,
  $Val extends CrawlRunListResponse
>
    implements $CrawlRunListResponseCopyWith<$Res> {
  _$CrawlRunListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrawlRunListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CrawlRun>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            offset: null == offset
                ? _value.offset
                : offset // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrawlRunListResponseImplCopyWith<$Res>
    implements $CrawlRunListResponseCopyWith<$Res> {
  factory _$$CrawlRunListResponseImplCopyWith(
    _$CrawlRunListResponseImpl value,
    $Res Function(_$CrawlRunListResponseImpl) then,
  ) = __$$CrawlRunListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CrawlRun> items, int total, int limit, int offset});
}

/// @nodoc
class __$$CrawlRunListResponseImplCopyWithImpl<$Res>
    extends _$CrawlRunListResponseCopyWithImpl<$Res, _$CrawlRunListResponseImpl>
    implements _$$CrawlRunListResponseImplCopyWith<$Res> {
  __$$CrawlRunListResponseImplCopyWithImpl(
    _$CrawlRunListResponseImpl _value,
    $Res Function(_$CrawlRunListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrawlRunListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
    Object? limit = null,
    Object? offset = null,
  }) {
    return _then(
      _$CrawlRunListResponseImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CrawlRun>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        offset: null == offset
            ? _value.offset
            : offset // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CrawlRunListResponseImpl implements _CrawlRunListResponse {
  const _$CrawlRunListResponseImpl({
    required final List<CrawlRun> items,
    required this.total,
    required this.limit,
    required this.offset,
  }) : _items = items;

  factory _$CrawlRunListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrawlRunListResponseImplFromJson(json);

  final List<CrawlRun> _items;
  @override
  List<CrawlRun> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int total;
  @override
  final int limit;
  @override
  final int offset;

  @override
  String toString() {
    return 'CrawlRunListResponse(items: $items, total: $total, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrawlRunListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    total,
    limit,
    offset,
  );

  /// Create a copy of CrawlRunListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrawlRunListResponseImplCopyWith<_$CrawlRunListResponseImpl>
  get copyWith =>
      __$$CrawlRunListResponseImplCopyWithImpl<_$CrawlRunListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CrawlRunListResponseImplToJson(this);
  }
}

abstract class _CrawlRunListResponse implements CrawlRunListResponse {
  const factory _CrawlRunListResponse({
    required final List<CrawlRun> items,
    required final int total,
    required final int limit,
    required final int offset,
  }) = _$CrawlRunListResponseImpl;

  factory _CrawlRunListResponse.fromJson(Map<String, dynamic> json) =
      _$CrawlRunListResponseImpl.fromJson;

  @override
  List<CrawlRun> get items;
  @override
  int get total;
  @override
  int get limit;
  @override
  int get offset;

  /// Create a copy of CrawlRunListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrawlRunListResponseImplCopyWith<_$CrawlRunListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
