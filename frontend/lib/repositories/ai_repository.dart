import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_explanation.dart';
import '../models/ai_assistant.dart';
import '../services/api_service.dart';

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
      throw Exception(
        safeApiErrorMessage(
          e,
          fallback: 'Penjelasan AI sedang tidak tersedia.',
        ),
      );
    } catch (_) {
      throw Exception('Penjelasan AI sedang tidak tersedia.');
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
      throw Exception(
        safeApiErrorMessage(
          e,
          fallback:
              'Layanan AI saat ini tidak tersedia. Silakan coba lagi nanti.',
        ),
      );
    } catch (_) {
      throw Exception(
        'Layanan AI saat ini tidak tersedia. Silakan coba lagi nanti.',
      );
    }
  }
}
