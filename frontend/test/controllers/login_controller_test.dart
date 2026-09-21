import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radarscholar/controllers/login_controller.dart';
import 'package:radarscholar/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';

import 'auth_controller_test.mocks.dart';

void main() {
  group('LoginController Unit Tests', () {
    test('Initial state has default empty values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(loginControllerProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.isPasswordVisible, isFalse);
      expect(state.rememberMe, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isSuccess, isFalse);
    });

    test('Validates email format properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(loginControllerProvider.notifier);

      expect(notifier.validateEmail(''), 'Email wajib diisi');
      expect(notifier.validateEmail('notanemail'), 'Format email tidak valid');
      expect(notifier.validateEmail('user@campus.ac.id'), isNull);
    });

    test('Validates password length properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(loginControllerProvider.notifier);

      expect(notifier.validatePassword(''), 'Kata sandi wajib diisi');
      expect(notifier.validatePassword('12345'), 'Kata sandi minimal 6 karakter');
      expect(notifier.validatePassword('secret123'), isNull);
    });

    test('Toggles password visibility and remember me', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(loginControllerProvider.notifier);

      notifier.togglePasswordVisibility();
      expect(container.read(loginControllerProvider).isPasswordVisible, isTrue);

      notifier.toggleRememberMe(true);
      expect(container.read(loginControllerProvider).rememberMe, isTrue);
    });

    test('Successful submission updates success state', () async {
      final mockAuthRepository = MockAuthRepository();
      
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());

      final mockUser = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      final mockResponse = AuthResponse(user: mockUser);

      when(mockAuthRepository.signInWithEmail(
        email: 'student@university.ac.id',
        password: 'validpassword',
      )).thenAnswer((_) async => mockResponse);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      // Retain provider during autoDispose lifecycle
      final sub = container.listen(loginControllerProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(loginControllerProvider.notifier);
      notifier.updateEmail('student@university.ac.id');
      notifier.updatePassword('validpassword');

      final result = await notifier.submitLogin();
      expect(result, isTrue);
      expect(container.read(loginControllerProvider).isSuccess, isTrue);
    });
  });
}
