// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scholarship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScholarshipSourceImpl _$$ScholarshipSourceImplFromJson(
  Map<String, dynamic> json,
) => _$ScholarshipSourceImpl(
  id: json['id'] as String,
  providerName: json['provider_name'] as String,
  sourceUrl: json['source_url'] as String,
  crawlAllowed: json['crawl_allowed'] as bool? ?? true,
  active: json['active'] as bool? ?? true,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$ScholarshipSourceImplToJson(
  _$ScholarshipSourceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'provider_name': instance.providerName,
  'source_url': instance.sourceUrl,
  'crawl_allowed': instance.crawlAllowed,
  'active': instance.active,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

_$ScholarshipBenefitImpl _$$ScholarshipBenefitImplFromJson(
  Map<String, dynamic> json,
) => _$ScholarshipBenefitImpl(
  id: json['id'] as String,
  scholarshipId: json['scholarship_id'] as String,
  benefitType: json['benefit_type'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$$ScholarshipBenefitImplToJson(
  _$ScholarshipBenefitImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'scholarship_id': instance.scholarshipId,
  'benefit_type': instance.benefitType,
  'description': instance.description,
};

_$ScholarshipRequirementImpl _$$ScholarshipRequirementImplFromJson(
  Map<String, dynamic> json,
) => _$ScholarshipRequirementImpl(
  id: json['id'] as String,
  scholarshipId: json['scholarship_id'] as String,
  requirementType: json['requirement_type'] as String,
  operator: json['operator'] as String,
  value: json['value'],
  description: json['description'] as String,
);

Map<String, dynamic> _$$ScholarshipRequirementImplToJson(
  _$ScholarshipRequirementImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'scholarship_id': instance.scholarshipId,
  'requirement_type': instance.requirementType,
  'operator': instance.operator,
  'value': instance.value,
  'description': instance.description,
};

_$ScholarshipImpl _$$ScholarshipImplFromJson(Map<String, dynamic> json) =>
    _$ScholarshipImpl(
      id: json['id'] as String,
      sourceId: json['source_id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      description: json['description'] as String,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      applicationUrl: json['application_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      benefits:
          (json['benefits'] as List<dynamic>?)
              ?.map(
                (e) => ScholarshipBenefit.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      requirements:
          (json['requirements'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ScholarshipRequirement.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      source: json['source'] == null
          ? null
          : ScholarshipSource.fromJson(json['source'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ScholarshipImplToJson(_$ScholarshipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.sourceId,
      'title': instance.title,
      'summary': instance.summary,
      'description': instance.description,
      'deadline': instance.deadline?.toIso8601String(),
      'application_url': instance.applicationUrl,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'benefits': instance.benefits,
      'requirements': instance.requirements,
      'source': instance.source,
    };

_$ScholarshipListResponseImpl _$$ScholarshipListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ScholarshipListResponseImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => Scholarship.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
);

Map<String, dynamic> _$$ScholarshipListResponseImplToJson(
  _$ScholarshipListResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'page_size': instance.pageSize,
  'total': instance.total,
  'total_pages': instance.totalPages,
};

_$MatchedScholarshipResponseImpl _$$MatchedScholarshipResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MatchedScholarshipResponseImpl(
  scholarship: Scholarship.fromJson(
    json['scholarship'] as Map<String, dynamic>,
  ),
  match: MatchResult.fromJson(json['match'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MatchedScholarshipResponseImplToJson(
  _$MatchedScholarshipResponseImpl instance,
) => <String, dynamic>{
  'scholarship': instance.scholarship,
  'match': instance.match,
};

_$MatchedScholarshipListResponseImpl
_$$MatchedScholarshipListResponseImplFromJson(Map<String, dynamic> json) =>
    _$MatchedScholarshipListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map(
            (e) =>
                MatchedScholarshipResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchedScholarshipListResponseImplToJson(
  _$MatchedScholarshipListResponseImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'page_size': instance.pageSize,
  'total': instance.total,
  'total_pages': instance.totalPages,
};
