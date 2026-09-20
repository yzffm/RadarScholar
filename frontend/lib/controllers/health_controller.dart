import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_response.dart';
import '../repositories/health_repository.dart';
import '../services/api_service.dart';

/// Provider for the shared [ApiService] instance.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for the [HealthRepository].
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(apiService: ref.watch(apiServiceProvider));
});

/// Async provider that fetches the backend health status.
///
/// Part of the Controller layer in MVC architecture.
/// Manages state and coordinates between View and Repository.
///
/// Usage in views:
/// ```dart
/// final health = ref.watch(healthControllerProvider);
/// health.when(
///   data: (response) => Text(response.status),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final healthControllerProvider =
    FutureProvider.autoDispose<HealthResponse>((ref) async {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.checkHealth();
});
