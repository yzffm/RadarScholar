/// Authentication state controller for RadarScholar.
///
/// Manages the global auth state using Riverpod, providing
/// a reactive auth state stream across the entire app.
///
/// Follows CPMK 4 (MVC) — Controller layer between views and repository.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

/// Represents the authentication state of the application.
sealed class AppAuthState {
  const AppAuthState();
}

/// Initial state — hasn't determined auth status yet.
class AuthInitial extends AppAuthState {
  const AuthInitial();
}

/// User is authenticated.
class AuthAuthenticated extends AppAuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

/// User is not authenticated.
class AuthUnauthenticated extends AppAuthState {
  const AuthUnauthenticated();
}

/// Auth operation in progress.
class AuthLoading extends AppAuthState {
  const AuthLoading();
}

/// Auth error occurred.
class AuthError extends AppAuthState {
  final String message;
  const AuthError(this.message);
}

/// Riverpod StateNotifier for global auth state management.
class AuthController extends StateNotifier<AppAuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthController(this._authRepository) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Check if already authenticated
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      state = AuthAuthenticated(currentUser);
    } else {
      state = const AuthUnauthenticated();
    }

    // Listen for auth state changes
    _authSubscription = _authRepository.onAuthStateChange?.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            state = AuthAuthenticated(session!.user);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = const AuthUnauthenticated();
          break;
        case AuthChangeEvent.passwordRecovery:
          // Password recovery handled separately
          break;
        case AuthChangeEvent.initialSession:
          if (session?.user != null) {
            state = AuthAuthenticated(session!.user);
          } else {
            state = const AuthUnauthenticated();
          }
          break;
        default:
          break;
      }
    });
  }

  /// Sign in with email and password.
  Future<bool> signInWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = AuthAuthenticated(response.user!);
        return true;
      }
      state = const AuthError('Login gagal. Silakan coba lagi.');
      return false;
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      state = const AuthError('Terjadi kesalahan. Silakan coba lagi.');
      return false;
    }
  }

  /// Register with email and password.
  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = const AuthLoading();
    try {
      final response = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (response.user != null) {
        // If email confirmation is required, user won't have a session yet
        if (response.session != null) {
          state = AuthAuthenticated(response.user!);
        } else {
          state = const AuthUnauthenticated();
        }
        return true;
      }
      state = const AuthError('Pendaftaran gagal. Silakan coba lagi.');
      return false;
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      state = const AuthError('Terjadi kesalahan. Silakan coba lagi.');
      return false;
    }
  }

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final result = await _authRepository.signInWithGoogle();
      // OAuth redirects the browser — state will be updated via the stream.
      return result;
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      state = const AuthError('Terjadi kesalahan saat login dengan Google.');
      return false;
    }
  }

  /// Send password reset magic link.
  Future<bool> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      state = AuthError(_mapAuthError(e.message));
      return false;
    } catch (e) {
      state = const AuthError('Gagal mengirim link pemulihan.');
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthUnauthenticated();
  }

  /// Map Supabase error messages to user-friendly Indonesian messages.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Email atau kata sandi salah.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Periksa inbox email Anda.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already registered')) {
      return 'Email sudah terdaftar. Silakan login atau gunakan email lain.';
    }
    if (lower.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }
    return 'Terjadi kesalahan: $message';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Global auth state provider.
final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthController(authRepo);
});

/// Convenience provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState is AuthAuthenticated;
});

/// Convenience provider for getting the current user.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});
