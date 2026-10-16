import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// RadarScholar Design System — Modern Intelligence SaaS (Material 3).
///
/// Inspired by Linear, Supabase, and Stripe:
/// - Deep Obsidian & Slate layered surfaces in Dark Mode (`L0 -> L1 -> L2 -> L3`)
/// - Crisp Porcelain Slate & Pure White elevated surfaces in Light Mode
/// - Plus Jakarta Sans geometric typography with tight display tracking
/// - Micro-borders (1px subtle strokes), ambient radial glows, and tactile hover states
class AppTheme {
  AppTheme._();

  // ─── Brand & Accent Tokens ──────────────────────────────────────────
  /// Primary brand anchor — Royal Cobalt Indigo (Light mode primary).
  static const Color brandPrimary = Color(0xFF2563EB);

  /// Deep indigo for gradients and rich brand surfaces.
  static const Color brandIndigo = Color(0xFF4F46E5);

  /// Vibrant electric sapphire — High-contrast Dark mode primary.
  static const Color darkPrimary = Color(0xFF38BDF8);

  /// Sky blue accent — Harmonized with the graduation cap logo mark.
  static const Color brandSkyBlue = Color(0xFF0EA5E9);

  /// Warm amber/gold for prestige indicators, deadlines, and cautions.
  static const Color brandSecondary = Color(0xFFF59E0B);

  /// Emerald green for verified sources, strong match, and active status.
  static const Color brandTertiary = Color(0xFF10B981);

  /// Semantic status colors.
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);

  /// Brand semantic aliases used across SaaS landing and auth surfaces.
  static const Color brandAccent = darkPrimary;
  static const Color brandWarning = statusWarning;
  static const Color brandDanger = statusDanger;
  static const Color brandAI = Color(0xFF818CF8);

  // ─── Dark Mode Surface Hierarchy (Obsidian Slate) ───────────────────
  /// L0: Base canvas background.
  static const Color darkBackground = Color(0xFF090D16);

  /// L1: Sidebar, navigation rail, and secondary panels.
  static const Color darkSurface = Color(0xFF0D1322);

  /// L2: Interactive cards and elevated containers.
  static const Color darkCard = Color(0xFF121B2E);

  /// L2 Hover: Subtle surface lift on pointer hover.
  static const Color darkCardHover = Color(0xFF18243D);

  /// L3: Inputs, code/metric wells, and inset pills.
  static const Color darkElevated = Color(0xFF1A2640);

  /// Micro-border for cards and dividers in dark mode.
  static const Color darkBorder = Color(0xFF1E2D47);

  /// Subtle hairline border for inner dividers.
  static const Color darkSubtleBorder = Color(0xFF172238);

  // ─── Light Mode Surface Hierarchy (Porcelain Slate) ─────────────────
  /// L0: Crisp porcelain canvas background.
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// L1: Sidebar and structural panels.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// L2: Card surface.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// L2 Hover: Subtle slate tint on hover.
  static const Color lightCardHover = Color(0xFFF1F5F9);

  /// L3: Inset wells, filter bars, and secondary containers.
  static const Color lightElevated = Color(0xFFF1F5F9);

  /// Crisp 1px slate border.
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Hairline divider border.
  static const Color lightSubtleBorder = Color(0xFFF1F5F9);

  // ─── Signature Gradients ────────────────────────────────────────────
  /// Hero background gradient — Deep Obsidian to Royal Indigo.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1536), Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  /// AI Intelligence mesh gradient — Deep Violet to Electric Cobalt.
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1D4ED8)],
  );

  /// Primary accent gradient for badges, avatars, and active indicators.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
  );

  /// Emerald verification gradient.
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
  );

  /// Amber / Gold gradient for high-prestige & urgent highlights.
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFBBF24)],
  );

  // ─── Semantic Context Helpers ───────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primaryOf(BuildContext context) =>
      isDark(context) ? darkPrimary : brandPrimary;

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color cardColorOf(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color cardHoverColorOf(BuildContext context) =>
      isDark(context) ? darkCardHover : lightCardHover;

  static Color surfaceElevatedOf(BuildContext context) =>
      isDark(context) ? darkElevated : lightElevated;

  static Color borderColorOf(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color subtleBorderOf(BuildContext context) =>
      isDark(context) ? darkSubtleBorder : lightSubtleBorder;

  static Color borderSubtleOf(BuildContext context) => borderColorOf(context);

  static Color borderStrongOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF283A5A) : const Color(0xFFCBD5E1);

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  /// Layered SaaS shadow for cards and floating panels.
  static List<BoxShadow> cardShadowOf(
    BuildContext context, {
    bool isHovered = false,
  }) {
    final dark = isDark(context);
    if (dark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: isHovered ? 0.45 : 0.28),
          blurRadius: isHovered ? 24 : 14,
          offset: Offset(0, isHovered ? 8 : 4),
        ),
        if (isHovered)
          BoxShadow(
            color: darkPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(
          0xFF0F172A,
        ).withValues(alpha: isHovered ? 0.08 : 0.035),
        blurRadius: isHovered ? 22 : 12,
        offset: Offset(0, isHovered ? 8 : 3),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Ambient glow shadow for primary CTAs and badges.
  static List<BoxShadow> glowShadowOf(Color color, {double intensity = 0.25}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ─── Light Theme ────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF1E3A8A),
      secondary: brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF78350F),
      tertiary: brandTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD1FAE5),
      onTertiaryContainer: Color(0xFF064E3B),
      error: statusDanger,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: lightElevated,
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      outlineVariant: lightBorder,
    ),
    textTheme: _buildTextTheme(Brightness.light),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: lightBackground,
      foregroundColor: Color(0xFF0F172A),
      titleTextStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Color(0xFF0F172A),
      ),
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: brandPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: statusDanger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: statusDanger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        backgroundColor: Colors.white,
        side: const BorderSide(color: lightBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brandPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightElevated,
      selectedColor: brandPrimary.withValues(alpha: 0.12),
      side: const BorderSide(color: lightBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF334155),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: lightSurface,
      labelType: NavigationRailLabelType.all,
      indicatorColor: brandPrimary.withValues(alpha: 0.12),
      selectedIconTheme: const IconThemeData(color: brandPrimary, size: 22),
      unselectedIconTheme: const IconThemeData(
        color: Color(0xFF64748B),
        size: 22,
      ),
      selectedLabelTextStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: brandPrimary,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightSurface,
      elevation: 0,
      height: 68,
      indicatorColor: brandPrimary.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF0F172A),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: lightSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: lightBorder),
      ),
    ),
  );

  // ─── Dark Theme ─────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFallbacks,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: Color(0xFF041E42),
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFBAE6FD),
      secondary: brandSecondary,
      onSecondary: Color(0xFF3E1F00),
      secondaryContainer: Color(0xFF78350F),
      onSecondaryContainer: Color(0xFFFDE68A),
      tertiary: brandTertiary,
      onTertiary: Color(0xFF022C22),
      tertiaryContainer: Color(0xFF064E3B),
      onTertiaryContainer: Color(0xFFA7F3D0),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      surface: darkSurface,
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: darkElevated,
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF334155),
      outlineVariant: darkBorder,
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: darkBackground,
      foregroundColor: Color(0xFFF8FAFC),
      titleTextStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Color(0xFFF8FAFC),
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D1424),
      hintStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: darkPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF8FAFC),
        backgroundColor: darkCard,
        side: const BorderSide(color: darkBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: darkPrimary.withValues(alpha: 0.16),
      side: const BorderSide(color: darkBorder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCBD5E1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: darkSurface,
      labelType: NavigationRailLabelType.all,
      indicatorColor: darkPrimary.withValues(alpha: 0.15),
      selectedIconTheme: const IconThemeData(color: darkPrimary, size: 22),
      unselectedIconTheme: const IconThemeData(
        color: Color(0xFF94A3B8),
        size: 22,
      ),
      selectedLabelTextStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: darkPrimary,
      ),
      unselectedLabelTextStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF94A3B8),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      elevation: 0,
      height: 68,
      indicatorColor: darkPrimary.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: darkElevated,
      contentTextStyle: const TextStyle(
        color: Color(0xFFF8FAFC),
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: darkBorder),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkCard,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: darkBorder),
      ),
    ),
  );

  // ─── Typography Scale (Plus Jakarta Sans) ───────────────────────────
  static const String _fontFamily = 'Plus Jakarta Sans';
  static const List<String> _fontFallbacks = [
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static bool get _isTestEnvironment {
    try {
      final bindingName = WidgetsBinding.instance.runtimeType.toString();
      return bindingName.contains('Test') || bindingName.contains('Automated');
    } catch (_) {
      return false;
    }
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final secondaryColor = brightness == Brightness.light
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
    final subtleColor = brightness == Brightness.light
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    final baseTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 52,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.08,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        height: 1.12,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.18,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.22,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.45,
        height: 1.28,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.32,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.35,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.05,
        height: 1.55,
        color: secondaryColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.05,
        height: 1.45,
        color: subtleColor,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: subtleColor,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        color: subtleColor,
      ),
    );

    if (_isTestEnvironment) {
      GoogleFonts.config.allowRuntimeFetching = false;
      return baseTheme;
    }

    try {
      return GoogleFonts.plusJakartaSansTextTheme(baseTheme);
    } catch (_) {
      return baseTheme;
    }
  }
}

/// Design tokens for consistent spacing throughout the app.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Page padding adapted for responsive layouts.
  static EdgeInsets pagePadding(double screenWidth) {
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 18);
    } else if (screenWidth < 1024) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 32);
    }
  }
}

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

/// Theme Mode state provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
