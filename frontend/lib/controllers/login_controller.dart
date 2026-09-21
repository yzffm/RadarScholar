/// Login form controller for RadarScholar.
///
/// Manages email/password form state, validation, and submission.
/// In M2: Connected to Supabase Auth via AuthController.
///
/// CPMK 4: Controller layer between LoginPage (View) and AuthController.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Form state for the Login Page.
class LoginFormState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? rememberMe,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Riverpod StateNotifier for managing Login Form state & actions.
class LoginNotifier extends StateNotifier<LoginFormState> {
  final Ref _ref;

  LoginNotifier(this._ref) : super(const LoginFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email.trim(), errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  /// Submit email/password login via Supabase Auth.
  Future<bool> submitLogin() async {
    final emailError = validateEmail(state.email);
    final passwordError = validatePassword(state.password);

    if (emailError != null) {
      state = state.copyWith(errorMessage: emailError);
      return false;
    }
    if (passwordError != null) {
      state = state.copyWith(errorMessage: passwordError);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final authController = _ref.read(authControllerProvider.notifier);
    final success = await authController.signInWithEmail(
      state.email,
      state.password,
    );

    if (!mounted) return false;

    if (success) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    }

    // Get error from auth state
    final authState = _ref.read(authControllerProvider);
    final errorMsg = authState is AuthError
        ? authState.message
        : 'Login gagal. Silakan coba lagi.';

    state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    return false;
  }

  /// Sign in with Google OAuth via Supabase.
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final authController = _ref.read(authControllerProvider.notifier);
    final success = await authController.signInWithGoogle();

    if (!mounted) return false;

    if (success) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    }

    final authState = _ref.read(authControllerProvider);
    final errorMsg = authState is AuthError
        ? authState.message
        : 'Login Google gagal. Silakan coba lagi.';

    state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    return false;
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginFormState>((ref) {
  return LoginNotifier(ref);
});
