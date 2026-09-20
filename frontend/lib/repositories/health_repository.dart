import '../models/health_response.dart';
import '../services/api_service.dart';

/// Repository for backend health check operations.
///
/// Part of the Repository layer — sits between Controller and Service.
/// Translates raw API responses into domain models.
class HealthRepository {
  const HealthRepository({required this.apiService});

  final ApiService apiService;

  /// Checks backend health by calling GET /health.
  ///
  /// Returns a [HealthResponse] on success.
  /// Throws on network or server errors.
  Future<HealthResponse> checkHealth() async {
    final response = await apiService.get<Map<String, dynamic>>('/health');
    return HealthResponse.fromJson(response.data!);
  }
}
