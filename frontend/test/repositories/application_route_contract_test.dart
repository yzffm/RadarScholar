import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/repositories/application_repository.dart';
import 'package:radarscholar/services/api_service.dart';

class RecordingApplicationApi extends ApiService {
  RecordingApplicationApi() : super(dio: Dio());

  String? path;
  String? method;

  @override
  Future<Response<T>> get<T>(
    String requestPath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    path = requestPath;
    method = 'GET';
    return Response<T>(
      requestOptions: RequestOptions(path: requestPath),
      data: <dynamic>[] as T,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String requestPath, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    path = requestPath;
    method = 'POST';
    throw StateError('not needed for this contract test');
  }
}

void main() {
  test(
    'application list uses the backend route without trailing slash',
    () async {
      final api = RecordingApplicationApi();
      final repository = ApplicationRepository(api);

      await repository.getApplications();

      expect(api.method, 'GET');
      expect(api.path, '/api/v1/applications');
    },
  );
}
