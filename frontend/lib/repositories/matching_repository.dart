import 'package:dio/dio.dart';
import 'package:radarscholar/models/scholarship.dart';
import 'package:radarscholar/services/api_service.dart';

class MatchingRepository {
  final ApiService _apiService;

  MatchingRepository(this._apiService);

  Future<MatchedScholarshipListResponse> getMatchedScholarships({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    try {
      final response = await _apiService.get(
        '/api/v1/scholarships/matched',
        queryParameters: queryParameters,
      );

      return MatchedScholarshipListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'Profil pengguna belum dilengkapi.',
        );
      }
      throw Exception('Failed to get matched scholarships: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<MatchedScholarshipResponse> getMatchDetail(
    String scholarshipId,
  ) async {
    try {
      final response = await _apiService.get(
        '/api/v1/scholarships/$scholarshipId/match',
      );
      return MatchedScholarshipResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'Profil pengguna belum dilengkapi.',
        );
      }
      throw Exception('Failed to get match details: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
