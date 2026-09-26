/// User profile repository for RadarScholar.
///
/// Communicates with the FastAPI backend for profile CRUD
/// via the ApiService (Dio + Auth Interceptor).
///
/// CPMK 1: Real Flutter → FastAPI API integration.
/// CPMK 4: Repository layer in MVC architecture.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/user_profile.dart';
import '../services/api_service.dart';

/// Repository for user profile API operations.
class UserProfileRepository {
  final ApiService _api;

  UserProfileRepository(this._api);

  /// Get the current user's profile.
  ///
  /// Returns null if the profile doesn't exist yet (404).
  Future<UserProfile?> getMyProfile() async {
    try {
      final response = await _api.get('/api/v1/users/me');
      if (response.statusCode == 200 && response.data != null) {
        return UserProfile.fromJson(response.data as Map<String, dynamic>);
      }
      if (response.statusCode == 404) {
        return null;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Unexpected profile response: ${response.statusCode}',
      );
    } on DioException catch (error) {
      // Only a confirmed 404 means the user has not created a profile yet.
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Create the current user's profile.
  Future<UserProfile> createMyProfile(Map<String, dynamic> data) async {
    final response = await _api.post('/api/v1/users/me', data: data);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update the current user's profile.
  Future<UserProfile> updateMyProfile(Map<String, dynamic> data) async {
    final response = await _api.put('/api/v1/users/me', data: data);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Riverpod provider for the user profile repository.
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ApiService());
});
