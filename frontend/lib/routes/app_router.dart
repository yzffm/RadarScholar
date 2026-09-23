import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../views/landing/landing_page.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/auth/forgot_password_page.dart';
import '../views/shell/app_shell.dart';
import '../views/discovery/discovery_page.dart';
import '../views/saved/saved_page.dart';
import '../views/applications/applications_page.dart';
import '../views/assistant/assistant_page.dart';
import '../views/profile/profile_page.dart';
import '../views/discovery/scholarship_detail_page.dart';
import '../views/matching/recommendations_page.dart';
/// A Listenable that notifies when the auth state changes.
/// This is used to trigger GoRouter redirects without rebuilding the whole router.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AppAuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// RadarScholar Application Router using GoRouter.
///
/// Implements ShellRoute for persistent adaptive navigation across
/// destinations while keeping Landing and Login as standalone full-page routes.
/// Auth state changes trigger routing re-evaluation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isAuth = authState is AuthAuthenticated;
      
      // Determine if we are on a public auth route
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToForgot = state.matchedLocation == '/forgot-password';
      final isGoingToLanding = state.matchedLocation == '/';
      
      final isGoingToAuthRoute = isGoingToLogin || isGoingToRegister || isGoingToForgot;

      if (!isAuth && !isGoingToAuthRoute && !isGoingToLanding) {
        // Redirect to login if unauthenticated and trying to access a protected route
        return '/login';
      }

      if (isAuth && (isGoingToAuthRoute || isGoingToLanding)) {
        // Redirect to app if authenticated and trying to access auth/landing page
        return '/discovery';
      }

      return null;
    },
    routes: [
      // ─── Public Landing Page ─────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),

      // ─── Authentication ──────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ─── Persistent Application Shell ────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/discovery',
            name: 'discovery',
            builder: (context, state) => const DiscoveryPage(),
          ),
          GoRoute(
            path: '/saved',
            name: 'saved',
            builder: (context, state) => const SavedPage(),
          ),
          GoRoute(
            path: '/applications',
            name: 'applications',
            builder: (context, state) => const ApplicationsPage(),
          ),
          GoRoute(
            path: '/assistant',
            name: 'assistant',
            builder: (context, state) => const AssistantPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/scholarships/:id',
        name: 'scholarship_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ScholarshipDetailPage(scholarshipId: id);
        },
      ),
      GoRoute(
        path: '/recommendations',
        name: 'recommendations',
        builder: (context, state) => const RecommendationsPage(),
      ),
    ],
  );
});
