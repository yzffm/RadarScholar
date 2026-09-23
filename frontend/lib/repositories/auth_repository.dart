/// Authentication repository for RadarScholar.
///
/// Wraps Supabase Auth SDK calls following the MVC Repository pattern (CPMK 4).
/// All Supabase-specific logic is isolated here, making the auth controller
/// and views independent of the auth provider implementation.
///
/// Security (agents.md §12):
/// - Uses Supabase Auth exclusively — no custom password storage.
/// - Passwords are never stored, returned, or logged by RadarScholar.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_config.dart';

/// Authentication repository wrapping Supabase Auth SDK.
class AuthRepository {
  AuthRepository();

  SupabaseClient? get _client => supabaseClient;

  /// Whether Supabase is configured and available.
  bool get isConfigured => _client != null;

  /// Get the current authenticated user, or null.
  User? get currentUser => _client?.auth.currentUser;

  /// Get the current session's access token (JWT).
  String? get accessToken => _client?.auth.currentSession?.accessToken;

  /// Stream of auth state changes.
  Stream<AuthState>? get onAuthStateChange => _client?.auth.onAuthStateChange;

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw AuthException('Layanan autentikasi belum dikonfigurasi.');
    }

    return client.auth.signInWithPassword(email: email, password: password);
  }

  /// Register with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final client = _client;
    if (client == null) {
      throw AuthException('Layanan autentikasi belum dikonfigurasi.');
    }

    return client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
  }

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw AuthException('Layanan autentikasi belum dikonfigurasi.');
    }

    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: null, // Uses default for web
    );
  }

  /// Send a password reset magic link to the email.
  Future<void> resetPassword(String email) async {
    final client = _client;
    if (client == null) {
      throw AuthException('Layanan autentikasi belum dikonfigurasi.');
    }

    await client.auth.resetPasswordForEmail(email);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}

/// Riverpod provider for the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
