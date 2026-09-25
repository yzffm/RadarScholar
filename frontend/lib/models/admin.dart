// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin.freezed.dart';
part 'admin.g.dart';

@freezed
class CrawlRun with _$CrawlRun {
  const factory CrawlRun({
    required String id,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'finished_at') DateTime? finishedAt,
    required String status,
    @JsonKey(name: 'sources_attempted') required int sourcesAttempted,
    @JsonKey(name: 'sources_succeeded') required int sourcesSucceeded,
    @JsonKey(name: 'sources_failed') required int sourcesFailed,
    @JsonKey(name: 'scholarships_created') required int scholarshipsCreated,
    @JsonKey(name: 'scholarships_updated') required int scholarshipsUpdated,
    @JsonKey(name: 'scholarships_skipped') required int scholarshipsSkipped,
    @Default([]) List<String> errors,
    @JsonKey(name: 'source_results') @Default([]) List<dynamic> sourceResults,
  }) = _CrawlRun;

  factory CrawlRun.fromJson(Map<String, dynamic> json) => _$CrawlRunFromJson(json);
}

@freezed
class CrawlRunListResponse with _$CrawlRunListResponse {
  const factory CrawlRunListResponse({
    required List<CrawlRun> items,
    required int total,
    required int limit,
    required int offset,
  }) = _CrawlRunListResponse;

  factory CrawlRunListResponse.fromJson(Map<String, dynamic> json) =>
      _$CrawlRunListResponseFromJson(json);
}
