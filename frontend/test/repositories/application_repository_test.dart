import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/repositories/application_repository.dart';
import 'package:radarscholar/services/api_service.dart';

class RecordingApiService extends ApiService {
  RecordingApiService() : super(dio: Dio());

  String? lastPath;
  String? lastMethod;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastMethod = 'GET';
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: <dynamic>[] as T,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastMethod = 'POST';
    throw StateError('not needed for this contract test');
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastMethod = 'DELETE';
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 204,
    );
  }
}

void main() {
  test('saved scholarship list uses the backend route contract', () async {
    final api = RecordingApiService();
    final repository = ApplicationRepository(api);

    await repository.getSavedScholarships();

    expect(api.lastMethod, 'GET');
    expect(api.lastPath, '/api/v1/saved-scholarships');
  });

  test('unsave uses the scholarship route contract', () async {
    final api = RecordingApiService();
    final repository = ApplicationRepository(api);

    await repository.unsaveScholarship('scholarship-id');

    expect(api.lastMethod, 'DELETE');
    expect(api.lastPath, '/api/v1/scholarships/scholarship-id/save');
  });
}
