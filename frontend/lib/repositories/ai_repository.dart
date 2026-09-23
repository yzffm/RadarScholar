import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_explanation.dart';
import '../models/ai_assistant.dart';
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
        '/api/v1/scholarships/$scholarshipId/ai-explanation',
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

  Future<AssistantResponse> getAssistantFeedback(
    String applicationId,
    AssistantRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        '/api/v1/applications/$applicationId/ai-assistant',
        data: request.toJson(),
      );
      return AssistantResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'Profil pengguna belum dilengkapi.',
        );
      }
      if (e.response?.statusCode == 404) {
        throw Exception(
          e.response?.data['detail'] ?? 'Aplikasi tidak ditemukan.',
        );
      }
      if (e.response?.statusCode == 503) {
        throw Exception(
          e.response?.data['detail'] ??
              'Layanan AI saat ini tidak tersedia. Silakan coba lagi nanti.',
        );
      }
      throw Exception(
        'Gagal mendapatkan umpan balik AI: ${e.response?.data['detail'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga: $e');
    }
  }
}
