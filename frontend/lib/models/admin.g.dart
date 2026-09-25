// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CrawlRunImpl _$$CrawlRunImplFromJson(Map<String, dynamic> json) =>
    _$CrawlRunImpl(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      status: json['status'] as String,
      sourcesAttempted: (json['sources_attempted'] as num).toInt(),
      sourcesSucceeded: (json['sources_succeeded'] as num).toInt(),
      sourcesFailed: (json['sources_failed'] as num).toInt(),
      scholarshipsCreated: (json['scholarships_created'] as num).toInt(),
      scholarshipsUpdated: (json['scholarships_updated'] as num).toInt(),
      scholarshipsSkipped: (json['scholarships_skipped'] as num).toInt(),
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sourceResults: json['source_results'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$CrawlRunImplToJson(_$CrawlRunImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'started_at': instance.startedAt.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
      'status': instance.status,
      'sources_attempted': instance.sourcesAttempted,
      'sources_succeeded': instance.sourcesSucceeded,
      'sources_failed': instance.sourcesFailed,
      'scholarships_created': instance.scholarshipsCreated,
      'scholarships_updated': instance.scholarshipsUpdated,
      'scholarships_skipped': instance.scholarshipsSkipped,
      'errors': instance.errors,
      'source_results': instance.sourceResults,
    };

_$CrawlRunListResponseImpl _$$CrawlRunListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CrawlRunListResponseImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => CrawlRun.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
);

Map<String, dynamic> _$$CrawlRunListResponseImplToJson(
  _$CrawlRunListResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
};
