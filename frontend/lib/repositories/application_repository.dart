import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radarscholar/models/application.dart';
import '../services/api_service.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final apiService =
      ApiService(); // or fetch from a provider if it exists globally
  return ApplicationRepository(apiService);
});

class ApplicationRepository {
  final ApiService _apiService;

  ApplicationRepository(this._apiService);

  // --- Saved Scholarships ---

  Future<List<SavedScholarship>> getSavedScholarships() async {
    final response = await _apiService.get(
      '/api/v1/applications/saved-scholarships',
    );
    return (response.data as List)
        .map((e) => SavedScholarship.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SavedScholarship> saveScholarship(String scholarshipId) async {
    final response = await _apiService.post(
      '/api/v1/applications/scholarships/$scholarshipId/save',
    );
    return SavedScholarship.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> unsaveScholarship(String scholarshipId) async {
    await _apiService.delete(
      '/api/v1/applications/scholarships/$scholarshipId/save',
    );
  }

  // --- Applications ---

  Future<List<Application>> getApplications() async {
    final response = await _apiService.get('/api/v1/applications/');
    return (response.data as List)
        .map((e) => Application.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Application> createApplication({
    required String scholarshipId,
    DateTime? targetDeadline,
    String? notes,
  }) async {
    final response = await _apiService.post(
      '/api/v1/applications/',
      data: {
        'scholarship_id': scholarshipId,
        if (targetDeadline != null)
          'target_deadline': targetDeadline.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> getApplication(String applicationId) async {
    final response = await _apiService.get(
      '/api/v1/applications/$applicationId',
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Application> updateApplication({
    required String applicationId,
    ApplicationStatus? status,
    DateTime? targetDeadline,
    String? notes,
  }) async {
    // Map status enum to string
    String? statusStr;
    if (status != null) {
      statusStr = status
          .toString()
          .split('.')
          .last
          .replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)}')
          .toUpperCase();
    }

    final response = await _apiService.patch(
      '/api/v1/applications/$applicationId',
      data: {
        if (statusStr != null) 'status': statusStr,
        if (targetDeadline != null)
          'target_deadline': targetDeadline.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    return Application.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteApplication(String applicationId) async {
    await _apiService.delete('/api/v1/applications/$applicationId');
  }

  // --- Application Tasks ---

  Future<ApplicationTask> addTask({
    required String applicationId,
    required String title,
    DateTime? dueDate,
  }) async {
    final response = await _apiService.post(
      '/api/v1/applications/$applicationId/tasks',
      data: {
        'title': title,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      },
    );
    return ApplicationTask.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ApplicationTask> updateTask({
    required String applicationId,
    required String taskId,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
  }) async {
    final response = await _apiService.patch(
      '/api/v1/applications/$applicationId/tasks/$taskId',
      data: {
        if (title != null) 'title': title,
        if (isCompleted != null) 'is_completed': isCompleted,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      },
    );
    return ApplicationTask.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask({
    required String applicationId,
    required String taskId,
  }) async {
    await _apiService.delete(
      '/api/v1/applications/$applicationId/tasks/$taskId',
    );
  }
}
