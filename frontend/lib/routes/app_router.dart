import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../views/landing/landing_page.dart';

/// Application router using GoRouter.
///
/// Defines all routes for RadarScholar.
/// Routes are listed to match the Technical Docs § 11 suggested routes.
/// Only the landing route is active in M0; others will be added per milestone.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
    ],
  );
});
