import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scholarship.dart';
import '../services/api_service.dart';

/// Provider for ApiService (assuming it's either provided globally or we create a new one)
/// Let's assume there's a global apiServiceProvider.
/// Let me check if there's an existing one. I will use a simple Provider.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final scholarshipRepositoryProvider = Provider<ScholarshipRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ScholarshipRepository(apiService);
});

class ScholarshipRepository {
  ScholarshipRepository(this._apiService);

  final ApiService _apiService;

  Future<ScholarshipListResponse> getScholarships({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiService.get(
      '/api/v1/scholarships',
      queryParameters: queryParams,
    );

    return ScholarshipListResponse.fromJson(response.data);
  }

  Future<Scholarship> getScholarshipDetail(String id) async {
    final response = await _apiService.get('/api/v1/scholarships/$id');
    return Scholarship.fromJson(response.data);
  }
}
