import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_explanation.dart';
import '../services/api_service.dart';
import 'scholarship_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(apiServiceProvider));
});

class AiRepository {
  final ApiService _apiService;

  AiRepository(this._apiService);

  Future<MatchExplanation> getScholarshipAiExplanation(
    String scholarshipId,
  ) async {
    try {
      final response = await _apiService.get(
        '/scholarships/$scholarshipId/ai-explanation',
      );
      return MatchExplanation.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'Profil pengguna belum dilengkapi.',
        );
      }
      if (e.response?.statusCode == 503) {
        throw Exception(
          e.response?.data['detail'] ?? 'Penjelasan AI sedang tidak tersedia.',
        );
      }
      throw Exception('Gagal mendapatkan penjelasan AI: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
