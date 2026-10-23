import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radarscholar/controllers/profile_controller.dart';
import 'package:radarscholar/models/user_profile.dart';
import 'package:radarscholar/repositories/user_profile_repository.dart';
import 'package:radarscholar/services/api_service.dart';
import 'package:radarscholar/views/profile/profile_page.dart';

Response<T> response<T>({int? statusCode, T? data}) {
  return Response<T>(
    requestOptions: RequestOptions(path: '/api/v1/users/me'),
    statusCode: statusCode,
    data: data,
  );
}

class FakeApiService extends ApiService {
  FakeApiService(this.getResponse);

  final Response<dynamic> Function() getResponse;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return getResponse() as Response<T>;
  }
}

class CountingProfileRepository extends UserProfileRepository {
  CountingProfileRepository() : super(ApiService());

  int createCalls = 0;

  @override
  Future<UserProfile?> getMyProfile() async {
    throw StateError('backend unavailable');
  }

  @override
  Future<UserProfile> createMyProfile(Map<String, dynamic> data) async {
    createCalls++;
    throw StateError('create should not be called');
  }
}

void main() {
  group('UserProfileRepository', () {
    test('returns null only for a 404 response', () async {
      final repository = UserProfileRepository(
        FakeApiService(() => response(statusCode: 404)),
      );

      expect(await repository.getMyProfile(), isNull);
    });

    test('rethrows non-404 Dio failures', () async {
      final repository = UserProfileRepository(
        FakeApiService(
          () => throw DioException(
            requestOptions: RequestOptions(path: '/api/v1/users/me'),
            response: response(statusCode: 500),
          ),
        ),
      );

      expect(repository.getMyProfile, throwsA(isA<DioException>()));
    });

    test('treats a non-404 response as an error', () async {
      final repository = UserProfileRepository(
        FakeApiService(() => response(statusCode: 500)),
      );

      expect(repository.getMyProfile, throwsA(isA<DioException>()));
    });
  });

  test('does not create a profile after a failed profile fetch', () async {
    final repository = CountingProfileRepository();
    final controller = ProfileController(repository);

    await controller.fetchProfile();
    final saved = await controller.saveProfile(<String, dynamic>{});

    expect(saved, isFalse);
    expect(repository.createCalls, 0);
    expect(controller.state, isA<ProfileError>());
  });

  test('UserProfile fromJson, toJson, and copyWith preserve nationality', () {
    final profile = UserProfile.fromJson({
      'id': 'u-1',
      'email': 'student@example.com',
      'nationality': 'Indonesia',
      'university': 'Universitas Gadjah Mada',
      'created_at': '2026-10-20T00:00:00Z',
      'updated_at': '2026-10-20T00:00:00Z',
    });

    expect(profile.nationality, 'Indonesia');
    expect(profile.toJson()['nationality'], 'Indonesia');

    final updated = profile.copyWith(nationality: 'Lainnya');
    expect(updated.nationality, 'Lainnya');
    expect(updated.toJson()['nationality'], 'Lainnya');
  });

  testWidgets(
    'ProfilePage displays nationality in read mode and form dropdown',
    (tester) async {
      final loadedProfile = UserProfile(
        id: 'u-1',
        email: 'student@example.com',
        nationality: 'Indonesia',
        university: 'Universitas Gadjah Mada',
        createdAt: DateTime.utc(2026, 10, 20),
        updatedAt: DateTime.utc(2026, 10, 20),
      );

      final repo = _LoadedProfileRepository(loadedProfile);
      final controller = ProfileController(repo);
      await controller.fetchProfile();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kewarganegaraan'), findsOneWidget);
      expect(find.text('Indonesia'), findsOneWidget);
    },
  );
}

class _LoadedProfileRepository extends UserProfileRepository {
  _LoadedProfileRepository(this._profile) : super(ApiService());

  final UserProfile _profile;

  @override
  Future<UserProfile?> getMyProfile() async => _profile;
}
