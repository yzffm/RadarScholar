/// Supabase configuration for RadarScholar.
///
/// Initializes the Supabase client with URL and anon key
/// from compile-time environment variables.
///
/// Security (agents.md §12):
/// - Only the ANON key is used client-side (public, rate-limited).
/// - The SERVICE_ROLE key is NEVER exposed to Flutter.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

/// Initialize Supabase before running the app.
///
/// Must be called in `main()` before `runApp()`.
/// Falls back gracefully if credentials are not configured.
Future<bool> initSupabase() async {
  final url = AppConfig.supabaseUrl;
  final anonKey = AppConfig.supabaseAnonKey;

  if (url.isEmpty || anonKey.isEmpty) {
    // Supabase not configured — auth features will be unavailable.
    // This allows development without Supabase credentials.
    return false;
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  return true;
}

/// Convenience accessor for the Supabase client.
///
/// Returns null if Supabase is not initialized.
SupabaseClient? get supabaseClient {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
