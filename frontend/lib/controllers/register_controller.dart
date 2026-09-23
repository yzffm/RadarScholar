/// Registration form controller for RadarScholar.
///
/// Manages registration form state, validation, and submission
/// via Supabase Auth. CPMK 4: Controller layer.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Form state for the Registration Page.
class RegisterFormState {
  final String displayName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final bool needsEmailConfirmation;

  const RegisterFormState({
    this.displayName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.needsEmailConfirmation = false,
  });

  RegisterFormState copyWith({
    String? displayName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool? needsEmailConfirmation,
  }) {
    return RegisterFormState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      needsEmailConfirmation:
          needsEmailConfirmation ?? this.needsEmailConfirmation,
    );
  }
}

/// Riverpod StateNotifier for managing Registration Form state.
class RegisterNotifier extends StateNotifier<RegisterFormState> {
  final Ref _ref;

  RegisterNotifier(this._ref) : super(const RegisterFormState());

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name.trim(), errorMessage: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email.trim(), errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void updateConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != state.password) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  /// Submit registration via Supabase Auth.
  Future<bool> submitRegister() async {
    final nameError = validateDisplayName(state.displayName);
    final emailError = validateEmail(state.email);
    final passwordError = validatePassword(state.password);
    final confirmError = validateConfirmPassword(state.confirmPassword);

    if (nameError != null) {
      state = state.copyWith(errorMessage: nameError);
      return false;
    }
    if (emailError != null) {
      state = state.copyWith(errorMessage: emailError);
      return false;
    }
    if (passwordError != null) {
      state = state.copyWith(errorMessage: passwordError);
      return false;
    }
    if (confirmError != null) {
      state = state.copyWith(errorMessage: confirmError);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final authController = _ref.read(authControllerProvider.notifier);
    final success = await authController.signUpWithEmail(
      state.email,
      state.password,
      displayName: state.displayName,
    );

    if (!mounted) return false;

    if (success) {
      // Check if email confirmation is needed
      final authState = _ref.read(authControllerProvider);
      final needsConfirmation = authState is AuthUnauthenticated;

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        needsEmailConfirmation: needsConfirmation,
      );
      return true;
    }

    final authState = _ref.read(authControllerProvider);
    final errorMsg = authState is AuthError
        ? authState.message
        : 'Pendaftaran gagal. Silakan coba lagi.';

    state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    return false;
  }
}

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterNotifier, RegisterFormState>((
      ref,
    ) {
      return RegisterNotifier(ref);
    });
