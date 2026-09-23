/// Health check response model from the FastAPI backend.
///
/// Part of the Model layer in MVC architecture.
/// Represents the response from GET /health endpoint.
class HealthResponse {
  const HealthResponse({required this.status, required this.version});

  /// Server health status (e.g., "ok").
  final String status;

  /// Backend API version.
  final String version;

  /// Creates a [HealthResponse] from a JSON map.
  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String? ?? 'unknown',
      version: json['version'] as String? ?? 'unknown',
    );
  }

  /// Converts this response to a JSON map.
  Map<String, dynamic> toJson() {
    return {'status': status, 'version': version};
  }

  /// Whether the server reports healthy status.
  bool get isHealthy => status == 'ok';
}
