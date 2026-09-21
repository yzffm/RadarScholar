import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radarscholar/controllers/auth_controller.dart';
import 'package:radarscholar/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthController', () {
    test('initial state is AuthUnauthenticated when no user', () {
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());

      final container = makeContainer();
      final state = container.read(authControllerProvider);

      expect(state, isA<AuthUnauthenticated>());
    });

    test('initial state is AuthAuthenticated when user exists', () {
      final mockUser = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      when(mockAuthRepository.currentUser).thenReturn(mockUser);
      when(mockAuthRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());

      final container = makeContainer();
      final state = container.read(authControllerProvider);

      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.id, '123');
    });

    test('signInWithEmail success', () async {
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());
      
      final mockUser = User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      final mockResponse = AuthResponse(
        user: mockUser,
      );

      when(mockAuthRepository.signInWithEmail(email: 'test@ui.ac.id', password: 'password123'))
          .thenAnswer((_) async => mockResponse);

      final container = makeContainer();
      final controller = container.read(authControllerProvider.notifier);

      final result = await controller.signInWithEmail('test@ui.ac.id', 'password123');

      expect(result, true);
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
    });

    test('signInWithEmail failure', () async {
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.onAuthStateChange).thenAnswer((_) => const Stream.empty());
      
      when(mockAuthRepository.signInWithEmail(email: 'test@ui.ac.id', password: 'wrong'))
          .thenThrow(const AuthException('Invalid login credentials'));

      final container = makeContainer();
      final controller = container.read(authControllerProvider.notifier);

      final result = await controller.signInWithEmail('test@ui.ac.id', 'wrong');

      expect(result, false);
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).message, 'Email atau kata sandi salah.');
    });
  });
}
