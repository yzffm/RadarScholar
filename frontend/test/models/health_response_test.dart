import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/models/health_response.dart';

void main() {
  group('HealthResponse', () {
    test('fromJson creates valid HealthResponse', () {
      final json = {'status': 'ok', 'version': '0.1.0'};
      final response = HealthResponse.fromJson(json);

      expect(response.status, 'ok');
      expect(response.version, '0.1.0');
      expect(response.isHealthy, isTrue);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final response = HealthResponse.fromJson(json);

      expect(response.status, 'unknown');
      expect(response.version, 'unknown');
      expect(response.isHealthy, isFalse);
    });

    test('isHealthy returns false for non-ok status', () {
      final response = HealthResponse(status: 'error', version: '0.1.0');
      expect(response.isHealthy, isFalse);
    });

    test('toJson produces correct map', () {
      const response = HealthResponse(status: 'ok', version: '0.1.0');
      final json = response.toJson();

      expect(json['status'], 'ok');
      expect(json['version'], '0.1.0');
    });
  });
}
