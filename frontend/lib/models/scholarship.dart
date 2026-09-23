// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:radarscholar/models/match_result.dart';

part 'scholarship.freezed.dart';
part 'scholarship.g.dart';

@freezed
class ScholarshipSource with _$ScholarshipSource {
  const factory ScholarshipSource({
    required String id,
    @JsonKey(name: 'provider_name') required String providerName,
    @JsonKey(name: 'source_url') required String sourceUrl,
    @JsonKey(name: 'crawl_allowed') @Default(true) bool crawlAllowed,
    @Default(true) bool active,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ScholarshipSource;

  factory ScholarshipSource.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipSourceFromJson(json);
}

@freezed
class ScholarshipBenefit with _$ScholarshipBenefit {
  const factory ScholarshipBenefit({
    required String id,
    @JsonKey(name: 'scholarship_id') required String scholarshipId,
    @JsonKey(name: 'benefit_type') required String benefitType,
    required String description,
  }) = _ScholarshipBenefit;

  factory ScholarshipBenefit.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipBenefitFromJson(json);
}

@freezed
class ScholarshipRequirement with _$ScholarshipRequirement {
  const factory ScholarshipRequirement({
    required String id,
    @JsonKey(name: 'scholarship_id') required String scholarshipId,
    @JsonKey(name: 'requirement_type') required String requirementType,
    required String operator,
    required dynamic value,
    required String description,
  }) = _ScholarshipRequirement;

  factory ScholarshipRequirement.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipRequirementFromJson(json);
}

@freezed
class Scholarship with _$Scholarship {
  const factory Scholarship({
    required String id,
    @JsonKey(name: 'source_id') required String sourceId,
    required String title,
    required String summary,
    required String description,
    DateTime? deadline,
    @JsonKey(name: 'application_url') required String applicationUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<ScholarshipBenefit> benefits,
    @Default([]) List<ScholarshipRequirement> requirements,
    ScholarshipSource? source,
  }) = _Scholarship;

  factory Scholarship.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipFromJson(json);
}

@freezed
class ScholarshipListResponse with _$ScholarshipListResponse {
  const factory ScholarshipListResponse({
    required List<Scholarship> items,
    required int page,
    @JsonKey(name: 'page_size') required int pageSize,
    required int total,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _ScholarshipListResponse;

  factory ScholarshipListResponse.fromJson(Map<String, dynamic> json) =>
      _$ScholarshipListResponseFromJson(json);
}

@freezed
class MatchedScholarshipResponse with _$MatchedScholarshipResponse {
  const factory MatchedScholarshipResponse({
    required Scholarship scholarship,
    required MatchResult match,
  }) = _MatchedScholarshipResponse;

  factory MatchedScholarshipResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchedScholarshipResponseFromJson(json);
}

@freezed
class MatchedScholarshipListResponse with _$MatchedScholarshipListResponse {
  const factory MatchedScholarshipListResponse({
    required List<MatchedScholarshipResponse> items,
    required int page,
    @JsonKey(name: 'page_size') required int pageSize,
    required int total,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _MatchedScholarshipListResponse;

  factory MatchedScholarshipListResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchedScholarshipListResponseFromJson(json);
}
