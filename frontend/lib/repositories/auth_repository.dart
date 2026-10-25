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

import 'package:flutter/foundation.dart' show kIsWeb;
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

  /// Sign in (or sign up) with Google OAuth via Supabase.
  ///
  /// On web this redirects the whole browser to Google and back to the app
  /// origin (PKCE flow); the session is then restored by `Supabase.initialize`
  /// and surfaced through [onAuthStateChange]. The returned bool only tells
  /// whether the redirect was launched, not whether the user is signed in.
  ///
  /// The redirect origin must be listed under Supabase → Authentication →
  /// URL Configuration → Redirect URLs.
  Future<bool> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw AuthException('Layanan autentikasi belum dikonfigurasi.');
    }

    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      // Web: return to the app origin (works for localhost and production).
      // Mobile: null falls back to the project's Site URL until a deep link
      // is configured.
      redirectTo: kIsWeb ? Uri.base.origin : null,
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
