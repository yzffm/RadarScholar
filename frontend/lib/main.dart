import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase_config.dart';
import 'core/theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase before running the app.
  // Returns false if credentials aren't configured (dev mode).
  await initSupabase();

  runApp(const ProviderScope(child: RadarScholarApp()));
}

/// Root application widget for RadarScholar.
class RadarScholarApp extends ConsumerWidget {
  const RadarScholarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'RadarScholar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
