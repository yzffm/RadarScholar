import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../models/admin.dart';
import '../models/scholarship.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AdminRepository(apiService);
});

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  Future<List<ScholarshipSource>> getSources() async {
    final response = await _apiService.get('/api/v1/admin/sources');
    return (response.data as List)
        .map((e) => ScholarshipSource.fromJson(e))
        .toList();
  }

  Future<ScholarshipSource> toggleSource(String sourceId) async {
    final response = await _apiService.post('/api/v1/admin/sources/$sourceId/toggle');
    return ScholarshipSource.fromJson(response.data);
  }

  Future<CrawlRunListResponse> getCrawlRuns({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _apiService.get(
      '/api/v1/admin/crawls',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
    return CrawlRunListResponse.fromJson(response.data);
  }
}
