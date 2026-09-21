/// Dio authentication interceptor for RadarScholar.
///
/// Automatically attaches the Supabase access token (JWT) to
/// every API request as `Authorization: Bearer <token>`.
///
/// Handles 401 responses by notifying the auth state.
library;

import 'package:dio/dio.dart';

import '../core/supabase_config.dart';

/// Interceptor that attaches Supabase JWT to outgoing requests.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Attach JWT token if available
    final token = supabaseClient?.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Let 401 errors propagate — the UI layer handles sign-out
    handler.next(err);
  }
}
