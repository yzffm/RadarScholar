import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/health_controller.dart';
import '../../widgets/responsive_layout.dart';

/// Landing page for RadarScholar.
///
/// Part of the View layer in MVC architecture.
/// Demonstrates:
/// - CPMK 1: API integration (health check to FastAPI)
/// - CPMK 2: Responsive layout (desktop/tablet/mobile)
/// - CPMK 4: MVC separation (View consumes Controller)
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RadarScholar'),
      ),
      body: ResponsiveLayout(
        mobile: (context) => _LandingContent(
          crossAxisCount: 1,
          horizontalPadding: 16,
        ),
        tablet: (context) => _LandingContent(
          crossAxisCount: 2,
          horizontalPadding: 32,
        ),
        desktop: (context) => _LandingContent(
          crossAxisCount: 3,
          horizontalPadding: 64,
        ),
      ),
    );
  }
}

/// Inner content of the landing page.
///
/// Adapts layout based on responsive parameters passed from [LandingPage].
class _LandingContent extends ConsumerWidget {
  const _LandingContent({
    required this.crossAxisCount,
    required this.horizontalPadding,
  });

  final int crossAxisCount;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final healthAsync = ref.watch(healthControllerProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // --- Hero Section ---
          Icon(
            Icons.school_rounded,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'RadarScholar',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Scholarship Intelligence Platform',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // --- Backend Connectivity Check (CPMK 1 evidence) ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Backend Connection',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  healthAsync.when(
                    data: (health) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          health.isHealthy
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: health.isHealthy
                              ? Colors.green
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          health.isHealthy
                              ? 'Connected (v${health.version})'
                              : 'Unhealthy: ${health.status}',
                        ),
                      ],
                    ),
                    loading: () => const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Checking backend...'),
                      ],
                    ),
                    error: (error, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Backend unavailable',
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(healthControllerProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- Product Flow Overview ---
          Text(
            'Discover → Understand → Match → Prepare → Track → Apply',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'M0 — Project Foundation',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
