import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/interactive_3d_name_card.dart';
import '../../widgets/interactive_3d_tilt_card.dart';

/// ============================================================================
/// KONFIGURASI PROFIL CREATOR (MUDAH DIEDIT KAPAN SAJA)
/// ============================================================================
/// Ubah konstanta di bawah ini untuk menyesuaikan detail akademik, bio, atau
/// tautan portofolio Anda tanpa perlu mengubah kode UI 3D di bawahnya.
class CreatorProfileConfig {
  CreatorProfileConfig._();

  static const String fullName = 'Yusuf Arrosyid';
  static const String handle = '@yzffm';
  static const String badgeId = 'RS-ARCH-2026 // YZFFM';
  static const String roleTitle = 'Full-Stack & AI Systems Engineer';
  static const String projectRole = 'Creator & Lead Architect — RadarScholar';
  static const String institution = 'Pemrograman Berbasis Platform (PBP)';
  static const String location = 'Indonesia';
  static const String email = 'yusufarrosyid08@gmail.com';
  static const String githubUrl = 'https://github.com/yzffm';
  static const String avatarAsset = 'assets/images/creator_avatar_3d.jpg';

  static const String headline =
      'Merancang Platform Intelijensi Beasiswa yang Jujur, Deterministik, dan Berpihak pada Mahasiswa.';

  static const String bioParagraph1 =
      'Halo! Saya Yusuf Arrosyid (@yzffm), perancang dan pengembang utama di balik RadarScholar. Proyek ini lahir dari pengamatan bahwa mahasiswa sering kali kesulitan membedakan antara informasi beasiswa yang masih valid dengan sekadar kumpulan tautan kedaluwarsa.';

  static const String bioParagraph2 =
      'Melalui pendekatan Pemrograman Berbasis Platform modern, saya membangun RadarScholar dengan prinsip "Source-First & Zero-Fabrication": kelayakan objektif dihitung secara deterministik oleh mesin aturan, sementara AI hadir sebagai pendamping persiapan berkas yang berintegritas.';

  static const List<
    ({String category, String tech, String detail, Color color})
  >
  techMatrix = [
    (
      category: 'FRONTEND & 3D UI',
      tech: 'Flutter Web & Android • Material 3 • Custom 3D Matrix/Canvas',
      detail: 'Arsitektur MVC reaktif berbasis Riverpod, GoRouter, & Dio',
      color: AppTheme.brandAccent,
    ),
    (
      category: 'BACKEND & ENGINE',
      tech: 'Python • FastAPI • SQLAlchemy 2.x • Alembic',
      detail:
          'Modular monolith dengan mesin pencocokan deterministik (T = 0.0)',
      color: AppTheme.brandPrimary,
    ),
    (
      category: 'DATA & SECURITY',
      tech: 'PostgreSQL • Supabase • JWT Ownership Guard',
      detail: 'Skema ternormalisasi, autentikasi aman, dan atribusi sumber',
      color: AppTheme.brandTertiary,
    ),
    (
      category: 'AI & CRAWLER PIPELINE',
      tech: 'Gemini (Primary) • Groq (Fallback) • Curated Crawler',
      detail:
          'Ekstraksi terstruktur bebas halusinasi & pemantauan portal resmi',
      color: AppTheme.brandAI,
    ),
  ];
}

/// Node in the 3D System Architecture Constellation on the About Me page.
class _ArchNode3d {
  final String code;
  final String shortTitle;
  final String name;
  final String layer;
  final String description;
  final String cpmkTag;
  final String assetPath;
  final Color color;
  final IconData icon;
  final double theta;
  final double phi;

  const _ArchNode3d({
    required this.code,
    required this.shortTitle,
    required this.name,
    required this.layer,
    required this.description,
    required this.cpmkTag,
    required this.assetPath,
    required this.color,
    required this.icon,
    required this.theta,
    required this.phi,
  });
}

/// Interactive 3D "About Me" / Creator Profile Page (`/about`).
///
/// Features:
/// 1. Interactive 3D Holographic Developer ID Badge (with pointer tilt, specular
///    shader glare, and front/back card flip).
/// 2. Real-time 3D System Architecture Orbital Constellation Canvas showcasing
///    the central 3D RadarScholar logo core and floating 3D engineering modules.
/// 3. 3D Visual Asset Bento Grid connecting the creator's engineering principles
///    with RadarScholar's core Scholarship Intelligence values.
class AboutMePage extends ConsumerStatefulWidget {
  const AboutMePage({super.key});

  @override
  ConsumerState<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends ConsumerState<AboutMePage> {
  bool _isBadgeFlipped = false;
  int _selectedArchNode = 0;

  static const List<_ArchNode3d> _archNodes = [
    _ArchNode3d(
      code: 'MOD-01',
      shortTitle: 'Flutter 3D UI',
      name: 'Flutter Responsive & 3D UI',
      layer: 'PRESENTATION LAYER (VIEW)',
      description:
          'Antarmuka adaptif Desktop/Tablet/Mobile dengan kanvas 3D interaktif dan komponen daftar dinamis ListView.builder.',
      cpmkTag: 'CPMK 2, 5 & 6',
      assetPath: 'assets/images/radarscholar_logo_3d.png',
      color: AppTheme.brandAccent,
      icon: Icons.devices_rounded,
      theta: 0.15,
      phi: -0.36,
    ),
    _ArchNode3d(
      code: 'MOD-02',
      shortTitle: 'Riverpod MVC',
      name: 'Riverpod MVC Controllers',
      layer: 'STATE & CONTROLLER LAYER',
      description:
          'Pemisahan tegas antara Model (Freezed/JSON), View (Flutter UI), dan Controller (Riverpod Notifier) tanpa logika bisnis di widget.',
      cpmkTag: 'CPMK 4 (MVC)',
      assetPath: 'assets/images/pillar_deadline_tracker.png',
      color: AppTheme.brandPrimary,
      icon: Icons.account_tree_rounded,
      theta: 1.20,
      phi: 0.36,
    ),
    _ArchNode3d(
      code: 'MOD-03',
      shortTitle: 'FastAPI REST',
      name: 'FastAPI REST Integration',
      layer: 'BACKEND API GATEWAY',
      description:
          'Integrasi langsung Flutter ke FastAPI melalui Dio client dengan validasi skema Pydantic dan proteksi kepemilikan data.',
      cpmkTag: 'CPMK 1 (API)',
      assetPath: 'assets/images/pillar_verified_source.png',
      color: AppTheme.brandTertiary,
      icon: Icons.hub_rounded,
      theta: 2.25,
      phi: -0.28,
    ),
    _ArchNode3d(
      code: 'MOD-04',
      shortTitle: 'Rule Engine',
      name: 'Deterministic Rule Engine',
      layer: 'ELIGIBILITY INTELLIGENCE',
      description:
          'Mesin aturan Python yang mengevaluasi syarat objektif (IPK, jenjang, semester) secara eksak tanpa klaim probabilitas palsu.',
      cpmkTag: 'T=0.0 EXACT',
      assetPath: 'assets/images/pillar_deterministic_match.png',
      color: AppTheme.brandSecondary,
      icon: Icons.rule_rounded,
      theta: 3.30,
      phi: 0.34,
    ),
    _ArchNode3d(
      code: 'MOD-05',
      shortTitle: 'Grounded AI',
      name: 'Grounded AI Abstraction',
      layer: 'GEMINI PRIMARY / GROQ FALLBACK',
      description:
          'Abstraksi AIProvider dengan failover otomatis untuk penjelasan kecocokan dan asistensi berkas tanpa memfabrikasi prestasi.',
      cpmkTag: 'ZERO FABRICATION',
      assetPath: 'assets/images/pillar_ai_assistant.png',
      color: AppTheme.brandAI,
      icon: Icons.auto_awesome_rounded,
      theta: 4.35,
      phi: -0.38,
    ),
    _ArchNode3d(
      code: 'MOD-06',
      shortTitle: 'Source Crawler',
      name: 'Curated Source Telemetry',
      layer: 'ETHICAL CRAWLER & SUPABASE DB',
      description:
          'Registri sumber beasiswa terkurasi dengan pelacakan waktu verifikasi, atribusi URL resmi, dan kepatuhan akses.',
      cpmkTag: 'SOURCE-FIRST',
      assetPath: 'assets/images/pillar_verified_source.png',
      color: AppTheme.brandSkyBlue,
      icon: Icons.verified_user_rounded,
      theta: 5.40,
      phi: 0.18,
    ),
  ];

  Future<void> _launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tautan: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(screenWidth);
    final isMobile = Responsive.isMobile(screenWidth);
    final isDark = AppTheme.isDark(context);

    // Check if rendered inside AppShell or standalone
    bool showStandaloneHeader = true;
    try {
      showStandaloneHeader = GoRouterState.of(context).uri.path == '/about';
    } catch (_) {
      showStandaloneHeader = true;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: showStandaloneHeader
          ? _buildTopBar(context, isMobile, isDark)
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroCreatorSection(context, isDesktop, isMobile, isDark),
            _buildArchitecture3dSection(context, isDesktop, isMobile, isDark),
            _buildEngineeringValuesSection(
              context,
              isDesktop,
              isMobile,
              isDark,
            ),
            _buildFooterBanner(context, isMobile, isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(
    BuildContext context,
    bool isMobile,
    bool isDark,
  ) {
    final borderColor = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return AppBar(
      backgroundColor: isDark
          ? AppTheme.darkBackground.withValues(alpha: 0.94)
          : Colors.white.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: isMobile ? 16 : 32,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: borderColor),
      ),
      title: AppLogo(
        mode: isMobile ? AppLogoMode.iconOnly : AppLogoMode.full,
        height: isMobile ? 34 : 36,
        onTap: () => context.go('/'),
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'Beranda',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => context.go('/discovery'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'Eksplorasi Beasiswa',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 12),
        ],
        IconButton(
          tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
          onPressed: () {
            final current = ref.read(themeModeProvider);
            ref.read(themeModeProvider.notifier).state =
                current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          },
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceElevatedOf(context),
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 18,
            color: isDark ? AppTheme.brandWarning : textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: () => context.go('/discovery'),
          icon: const Icon(Icons.explore_rounded, size: 17),
          label: Text(isMobile ? 'Aplikasi' : 'Buka Workspace'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 16 : 32),
      ],
    );
  }

  // ─── 1. Hero Creator Bio & Interactive 3D Hologram ID Card ───────────
  Widget _buildHeroCreatorSection(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 36)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 64);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B1428), Color(0xFF090D16)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
              ),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtleOf(context)),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildCreatorBioColumn(context, isDark),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 5,
                        child: _buildInteractive3dIdBadge(context, isDark),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInteractive3dIdBadge(context, isDark),
                      const SizedBox(height: 36),
                      _buildCreatorBioColumn(context, isDark),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorBioColumn(BuildContext context, bool isDark) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final accentColor = isDark ? AppTheme.brandAccent : AppTheme.brandPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal_rounded, size: 15, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'ABOUT THE ARCHITECT // ${CreatorProfileConfig.handle.toUpperCase()}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),

        Text(
          CreatorProfileConfig.fullName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${CreatorProfileConfig.roleTitle} • ${CreatorProfileConfig.projectRole}',
          style: TextStyle(
            color: accentColor,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          CreatorProfileConfig.headline,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          CreatorProfileConfig.bioParagraph1,
          style: TextStyle(color: textSecondary, fontSize: 14.5, height: 1.65),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          CreatorProfileConfig.bioParagraph2,
          style: TextStyle(color: textSecondary, fontSize: 14.5, height: 1.65),
        ),
        const SizedBox(height: Spacing.xl),

        // Contact & Social CTAs
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () =>
                  _launchExternal('mailto:${CreatorProfileConfig.email}'),
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text(CreatorProfileConfig.email),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _launchExternal(CreatorProfileConfig.githubUrl),
              icon: const Icon(Icons.code_rounded, size: 18),
              label: const Text('GitHub @yzffm'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.cardColorOf(context),
                foregroundColor: textPrimary,
                side: BorderSide(color: AppTheme.borderStrongOf(context)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _isBadgeFlipped = !_isBadgeFlipped),
              icon: const Icon(Icons.threed_rotation_rounded, size: 18),
              label: Text(
                _isBadgeFlipped ? 'Lihat Sisi Depan 3D' : 'Putar Kartu 3D ID',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.45)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractive3dIdBadge(BuildContext context, bool isDark) {
    return Column(
      children: [
        Interactive3dNameCard(
          isFlipped: _isBadgeFlipped,
          onFlipChanged: (val) => setState(() => _isBadgeFlipped = val),
          onTap: () => setState(() => _isBadgeFlipped = !_isBadgeFlipped),
          glowColor: _isBadgeFlipped
              ? AppTheme.brandTertiary
              : AppTheme.brandAccent,
          backgroundColor: const Color(0xFF0B111E),
          borderColor: const Color(0xFF283A5A),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          front: _buildBadgeFrontHologram(context),
          back: _buildBadgeBackSpec(context),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drag_indicator_rounded,
              size: 14,
              color: AppTheme.textMutedOf(context),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Geser mouse untuk memutar kartu 3D • Klik kartu atau tombol untuk membalik',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMutedOf(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeFrontHologram(BuildContext context) {
    return Column(
      key: const ValueKey('badge_front'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top security lanyard header
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.brandAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(
                    color: AppTheme.brandAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: AppTheme.brandAccent,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        CreatorProfileConfig.badgeId,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.brandAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.brandTertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '3D HOLOGRAM ID',
                style: TextStyle(
                  color: AppTheme.brandTertiary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3D Render Emblem Centerpiece
        Center(
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: AppTheme.brandAccent.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                CreatorProfileConfig.avatarAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.radar_rounded,
                    size: 64,
                    color: AppTheme.brandAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Creator Identity
        Center(
          child: Column(
            children: [
              const Text(
                CreatorProfileConfig.fullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                CreatorProfileConfig.projectRole,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.brandAccent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CreatorProfileConfig.institution,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
        const SizedBox(height: 14),

        // Telemetry Metadata Row (MadeInEvolve / Oryzo style)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildBadgeMetaItem('HANDLE', CreatorProfileConfig.handle),
            _buildBadgeMetaItem('ENGINE', 'DETERMINISTIC + AI'),
            _buildBadgeMetaItem('STATUS', 'ACTIVE ARCHITECT'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeBackSpec(BuildContext context) {
    return Column(
      key: const ValueKey('badge_back'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.memory_rounded,
              color: AppTheme.brandTertiary,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ENGINEERING TELEMETRY MATRIX',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.brandTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.brandTertiary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VERIFIED // 3D ID',
                style: TextStyle(
                  color: AppTheme.brandTertiary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Biometric & Architect Photo Credential Badge (Dual-sided photo)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131D33),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppTheme.brandTertiary.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.brandTertiary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandTertiary.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    CreatorProfileConfig.avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person_rounded,
                      color: AppTheme.brandTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 13,
                          color: AppTheme.brandTertiary,
                        ),
                        const SizedBox(width: 4),
                        const Flexible(
                          child: Text(
                            'SECURITY CREDENTIAL // BACK',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.brandTertiary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      CreatorProfileConfig.fullName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CreatorProfileConfig.roleTitle} • ${CreatorProfileConfig.handle}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...CreatorProfileConfig.techMatrix.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131D33),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: item.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: TextStyle(
                      color: item.color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.tech,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.detail,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ─── 2. Real-Time 3D System Architecture Constellation ───────────────
  Widget _buildArchitecture3dSection(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final activeNode = _archNodes[_selectedArchNode];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(bottom: BorderSide(color: borderSubtle)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Text(
                  'INTERACTIVE 3D SYSTEM CONSTELLATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppTheme.brandAccent
                        : AppTheme.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Arsitektur RadarScholar dalam Ruang 3D',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Putar konstelasi 3D di bawah ini atau pilih modul untuk melihat bagaimana arsitektur sistem dirancang secara end-to-end.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _Architecture3dCanvas(
                            nodes: _archNodes,
                            selectedIndex: _selectedArchNode,
                            onSelectNode: (idx) =>
                                setState(() => _selectedArchNode = idx),
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 5,
                          child: _buildArchModuleSelectorList(
                            context,
                            activeNode,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _Architecture3dCanvas(
                          nodes: _archNodes,
                          selectedIndex: _selectedArchNode,
                          onSelectNode: (idx) =>
                              setState(() => _selectedArchNode = idx),
                        ),
                        const SizedBox(height: 20),
                        _buildArchModuleSelectorList(context, activeNode),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchModuleSelectorList(
    BuildContext context,
    _ArchNode3d activeNode,
  ) {
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Column(
      children: List.generate(_archNodes.length, (i) {
        final node = _archNodes[i];
        final selected = i == _selectedArchNode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => setState(() => _selectedArchNode = i),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? node.color.withValues(alpha: 0.12) : cardBg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected ? node.color : borderSubtle,
                  width: selected ? 1.4 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: node.color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(node.icon, color: node.color, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${node.code} • ${node.layer}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: node.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: node.color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                node.cpmkTag,
                                style: TextStyle(
                                  color: node.color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          node.name,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(height: 4),
                          Text(
                            node.description,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── 3. 3D Visual Assets & Core Product Values Bento Grid ────────────
  Widget _buildEngineeringValuesSection(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    final valueCards = [
      (
        asset: 'assets/images/pillar_verified_source.png',
        tag: 'PRINSIP 01 // SOURCE-FIRST',
        title: 'Kebenaran Data di Atas Segalanya',
        desc:
            'Tidak ada informasi beasiswa yang dikarang. Semua berasal dari portal terkurasi dengan cap waktu verifikasi transparan.',
        color: AppTheme.brandTertiary,
      ),
      (
        asset: 'assets/images/pillar_deterministic_match.png',
        tag: 'PRINSIP 02 // DETERMINISTIC ENGINE',
        title: 'Aturan Objektif Tanpa Tebakan AI',
        desc:
            'Kelayakan IPK, jenjang, dan semester dievaluasi secara matematis (T = 0.0) agar mahasiswa mendapat kepastian yang jujur.',
        color: AppTheme.brandAccent,
      ),
      (
        asset: 'assets/images/pillar_deadline_tracker.png',
        tag: 'PRINSIP 03 // END-TO-END WORKFLOW',
        title: 'Dari Penemuan hingga Pengajuan Resmi',
        desc:
            'Menjaga alur Discover -> Understand -> Match -> Decide -> Prepare -> Track -> Apply tetap fokus dan terstruktur.',
        color: AppTheme.brandSecondary,
      ),
      (
        asset: 'assets/images/pillar_ai_assistant.png',
        tag: 'PRINSIP 04 // ETHICAL AI COACHING',
        title: 'Pendamping AI Tanpa Fabrikasi',
        desc:
            'AI membantu menyempurnakan struktur CV dan esai berdasarkan pengalaman asli mahasiswa, bukan menciptakan riwayat palsu.',
        color: AppTheme.brandAI,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              Text(
                'Filosofi Desain & Rekayasa RadarScholar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Setiap visual 3D di bawah ini merepresentasikan pilar utama yang kami jaga dalam membangun platform ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 820 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      mainAxisExtent: 210,
                    ),
                    itemCount: valueCards.length,
                    itemBuilder: (context, index) {
                      final card = valueCards[index];
                      return Interactive3dTiltCard(
                        glowColor: card.color,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 112,
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFF090D16),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color: card.color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg - 1,
                                ),
                                child: Image.asset(
                                  card.asset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.auto_awesome_rounded,
                                    color: card.color,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.tag,
                                    style: TextStyle(
                                      color: card.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    card.title,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    card.desc,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12.5,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBanner(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF060911),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(mode: AppLogoMode.iconOnly, height: 32),
                  const SizedBox(width: 12),
                  Text(
                    'RadarScholar • Engineered by ${CreatorProfileConfig.fullName} (${CreatorProfileConfig.handle})',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/discovery'),
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: const Text('Jelajahi Beasiswa Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive 3D System Architecture Constellation Canvas for AboutMePage.
class _Architecture3dCanvas extends StatefulWidget {
  final List<_ArchNode3d> nodes;
  final int selectedIndex;
  final ValueChanged<int> onSelectNode;

  const _Architecture3dCanvas({
    required this.nodes,
    required this.selectedIndex,
    required this.onSelectNode,
  });

  @override
  State<_Architecture3dCanvas> createState() => _Architecture3dCanvasState();
}

class _Architecture3dCanvasState extends State<_Architecture3dCanvas> {
  double _rotY = 0.35;
  double _rotX = -0.18;
  double _targetRotY = 0.35;
  double _targetRotX = -0.18;
  double _pulsePhase = 0.0;
  bool _isDragging = false;
  Timer? _timer;
  List<({int index, Offset pos, double z, double scale})> _projected = const [];

  bool get _isFlutterTest {
    if (kIsWeb) return false;
    try {
      final b = WidgetsBinding.instance.runtimeType.toString();
      return b.contains('TestWidgetsFlutterBinding') ||
          b.contains('AutomatedTestWidgetsFlutterBinding');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_isFlutterTest) {
      _timer = Timer.periodic(const Duration(milliseconds: 32), (_) {
        if (!mounted) return;
        setState(() {
          _pulsePhase = (_pulsePhase + 0.045) % (math.pi * 2);
          if (!_isDragging) {
            _targetRotY += 0.006;
          }
          _rotY += (_targetRotY - _rotY) * 0.14;
          _rotX += (_targetRotX - _rotX) * 0.14;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant _Architecture3dCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final n = widget.nodes[widget.selectedIndex];
      _targetRotY = -n.theta + math.pi * 0.5;
      _targetRotX = (-n.phi * 0.55).clamp(-0.6, 0.6);
      if (_isFlutterTest) {
        _rotY = _targetRotY;
        _rotX = _targetRotX;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeNode = widget.nodes[widget.selectedIndex];

    return Container(
      height: 495,
      decoration: BoxDecoration(
        color: const Color(0xFF0A101D),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: activeNode.color.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: activeNode.color.withValues(alpha: 0.16),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl - 1),
        child: Stack(
          children: [
            // 1. Interactive 3D Orbit + Central 3D RadarScholar Logo + 6 Floating Module Badges
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final center = Offset(size.width * 0.5, size.height * 0.42);
                  _projected = _projectNodes(size, center);

                  final backNodes = _projected.where((p) => p.z < 0).toList()
                    ..sort((a, b) => a.z.compareTo(b.z));
                  final frontNodes = _projected.where((p) => p.z >= 0).toList()
                    ..sort((a, b) => a.z.compareTo(b.z));

                  const centerLogoSize = 98.0;

                  return MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    onHover: (e) {
                      final nx = ((e.localPosition.dx / size.width) * 2 - 1)
                          .clamp(-1.0, 1.0);
                      final ny = ((e.localPosition.dy / size.height) * 2 - 1)
                          .clamp(-1.0, 1.0);
                      setState(() {
                        _targetRotX = (-ny * 0.35).clamp(-0.6, 0.6);
                        if (_isFlutterTest) {
                          _rotX = _targetRotX;
                        }
                      });
                      if (nx.abs() > 0.01) {
                        _targetRotY += nx * 0.006;
                      }
                    },
                    onExit: (_) => setState(() => _isDragging = false),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) {
                        setState(() {
                          _isDragging = true;
                          _targetRotY += d.delta.dx * 0.012;
                          _targetRotX = (_targetRotX - d.delta.dy * 0.010)
                              .clamp(-0.65, 0.65);
                          if (_isFlutterTest) {
                            _rotY = _targetRotY;
                            _rotX = _targetRotX;
                          }
                        });
                      },
                      onPanEnd: (_) => setState(() => _isDragging = false),
                      onTapUp: (d) {
                        for (final p in _projected) {
                          if ((p.pos - d.localPosition).distance < 48) {
                            widget.onSelectNode(p.index);
                            return;
                          }
                        }
                        widget.onSelectNode(
                          (widget.selectedIndex + 1) % widget.nodes.length,
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1A. 3D Orbital Rings & Data-Flow Beams
                          Positioned.fill(
                            child: CustomPaint(
                              size: size,
                              painter: _ArchConstellationPainter(
                                center: center,
                                nodes: widget.nodes,
                                projected: _projected,
                                selectedIndex: widget.selectedIndex,
                                rotX: _rotX,
                                rotY: _rotY,
                                pulsePhase: _pulsePhase,
                              ),
                            ),
                          ),

                          // 1B. Back-hemisphere floating 3D module badges
                          for (final p in backNodes)
                            _buildFloatingArchBadge(p, size, isFront: false),

                          // 1C. Central 3D RadarScholar Core Logo at (0,0,0)
                          Positioned(
                            left: center.dx - centerLogoSize / 2,
                            top: center.dy - centerLogoSize / 2,
                            child: IgnorePointer(
                              child: _buildCentral3dLogoCore(
                                size: centerLogoSize,
                                activeColor: activeNode.color,
                              ),
                            ),
                          ),

                          // 1D. Front-hemisphere floating 3D module badges
                          for (final p in frontNodes)
                            _buildFloatingArchBadge(p, size, isFront: true),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Top Telemetry Header
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121B2E).withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                          color: activeNode.color.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: activeNode.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '3D ARCHITECTURE ORBIT // ${activeNode.code}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: activeNode.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121B2E).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      'PUTAR 3D / KLIK MODUL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Bottom Active Module Inspection Panel
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10192B).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: activeNode.color.withValues(alpha: 0.42),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: activeNode.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: activeNode.color.withValues(alpha: 0.45),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md - 1),
                        child: Image.asset(
                          activeNode.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            activeNode.icon,
                            color: activeNode.color,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${activeNode.code} • ${activeNode.name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: activeNode.color.withValues(
                                    alpha: 0.18,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activeNode.cpmkTag,
                                  style: TextStyle(
                                    color: activeNode.color,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            activeNode.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentral3dLogoCore({
    required double size,
    required Color activeColor,
  }) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateX(_rotX * 0.45)
      ..rotateY(_rotY * 0.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.25, -0.3),
                radius: 0.9,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF0F172A),
                  Color(0xFF090D16),
                ],
              ),
              border: Border.all(
                color: AppTheme.brandAccent.withValues(alpha: 0.65),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.30),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/radarscholar_logo_3d.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/logo_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.school_rounded,
                      color: AppTheme.brandAccent,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1325).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppTheme.brandAccent.withValues(alpha: 0.45),
            ),
          ),
          child: const Text(
            'RADARSCHOLAR CORE',
            style: TextStyle(
              color: AppTheme.brandAccent,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingArchBadge(
    ({int index, Offset pos, double z, double scale}) p,
    Size canvasSize, {
    required bool isFront,
  }) {
    final node = widget.nodes[p.index];
    final selected = p.index == widget.selectedIndex;
    const badgeWidth = 144.0;
    const badgeHeight = 48.0;

    final clampedLeft = (p.pos.dx - badgeWidth / 2)
        .clamp(10.0, math.max(10.0, canvasSize.width - badgeWidth - 10.0))
        .toDouble();
    final clampedTop = (p.pos.dy - badgeHeight / 2)
        .clamp(52.0, math.max(52.0, canvasSize.height - badgeHeight - 104.0))
        .toDouble();

    final depthScale = (0.80 + ((p.z + 1.0) * 0.14)).clamp(0.76, 1.06);
    final depthOpacity = selected
        ? 1.0
        : (isFront ? 0.95 : 0.60).clamp(0.48, 1.0);

    return Positioned(
      left: clampedLeft,
      top: clampedTop,
      child: Opacity(
        opacity: depthOpacity,
        child: Transform.scale(
          scale: selected ? 1.06 : depthScale,
          child: GestureDetector(
            onTap: () => widget.onSelectNode(p.index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: badgeWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [
                          const Color(0xFF172542),
                          node.color.withValues(alpha: 0.30),
                        ]
                      : [
                          const Color(0xFF0E172A).withValues(alpha: 0.92),
                          const Color(0xFF131F38).withValues(alpha: 0.86),
                        ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected
                      ? node.color
                      : node.color.withValues(alpha: isFront ? 0.45 : 0.25),
                  width: selected ? 1.6 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? node.color.withValues(alpha: 0.38)
                        : Colors.black.withValues(alpha: 0.35),
                    blurRadius: selected ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.3),
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          node.color.withValues(alpha: 0.35),
                          const Color(0xFF090D16),
                        ],
                      ),
                      border: Border.all(
                        color: node.color.withValues(alpha: 0.65),
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            node.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                          Container(
                            color: const Color(
                              0xFF090D16,
                            ).withValues(alpha: 0.32),
                            alignment: Alignment.center,
                            child: Icon(
                              node.icon,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          node.shortTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          node.cpmkTag,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: node.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<({int index, Offset pos, double z, double scale})> _projectNodes(
    Size size,
    Offset center,
  ) {
    final rx = size.width * 0.34;
    final ry = size.height * 0.22;
    final rz = math.min(size.width, size.height) * 0.26;
    const fov = 460.0;

    return List.generate(widget.nodes.length, (i) {
      final n = widget.nodes[i];
      final x0 = math.cos(n.phi) * math.cos(n.theta);
      final y0 = math.sin(n.phi);
      final z0 = math.cos(n.phi) * math.sin(n.theta);

      final x1 = x0 * math.cos(_rotY) + z0 * math.sin(_rotY);
      final z1 = -x0 * math.sin(_rotY) + z0 * math.cos(_rotY);
      final y2 = y0 * math.cos(_rotX) - z1 * math.sin(_rotX);
      final z2 = y0 * math.sin(_rotX) + z1 * math.cos(_rotX);

      final scale = fov / (fov - z2 * rz);
      return (
        index: i,
        pos: Offset(
          center.dx + (x1 * rx) * scale,
          center.dy + (y2 * ry) * scale,
        ),
        z: z2.clamp(-1.0, 1.0),
        scale: scale,
      );
    });
  }
}

class _ArchConstellationPainter extends CustomPainter {
  final Offset center;
  final List<_ArchNode3d> nodes;
  final List<({int index, Offset pos, double z, double scale})> projected;
  final int selectedIndex;
  final double rotX;
  final double rotY;
  final double pulsePhase;

  const _ArchConstellationPainter({
    required this.center,
    required this.nodes,
    required this.projected,
    required this.selectedIndex,
    required this.rotX,
    required this.rotY,
    required this.pulsePhase,
  });

  Offset _project3d(
    double x,
    double y,
    double z,
    double rx,
    double ry,
    double rz,
  ) {
    final x1 = x * math.cos(rotY) + z * math.sin(rotY);
    final z1 = -x * math.sin(rotY) + z * math.cos(rotY);
    final y2 = y * math.cos(rotX) - z1 * math.sin(rotX);
    final z2 = y * math.sin(rotX) + z1 * math.cos(rotX);
    const fov = 460.0;
    final s = fov / (fov - z2 * rz);
    return Offset(center.dx + x1 * rx * s, center.dy + y2 * ry * s);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final activeColor = nodes[selectedIndex].color;
    final rx = size.width * 0.34;
    final ry = size.height * 0.22;
    final rz = math.min(size.width, size.height) * 0.26;

    // 1. Subtle technical grid & radial aura
    final shader = RadialGradient(
      colors: [activeColor.withValues(alpha: 0.22), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));
    canvas.drawCircle(center, size.width * 0.45, Paint()..shader = shader);

    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.045)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. 3D tilted orbital rings around the central RadarScholar logo
    _drawOrbitalRing(
      canvas,
      rx: rx,
      ry: ry,
      rz: rz,
      tiltX: 0.24,
      tiltZ: -0.14,
      color: AppTheme.brandAccent.withValues(alpha: 0.26),
      strokeWidth: 1.2,
    );
    _drawOrbitalRing(
      canvas,
      rx: rx * 0.78,
      ry: ry * 0.78,
      rz: rz * 0.8,
      tiltX: -0.42,
      tiltZ: 0.30,
      color: activeColor.withValues(alpha: 0.22),
      strokeWidth: 1.0,
    );

    // 3. Connect adjacent architecture layers and radial beams to central 3D logo
    for (int i = 0; i < projected.length; i++) {
      final next = projected[(i + 1) % projected.length];
      canvas.drawLine(
        projected[i].pos,
        next.pos,
        Paint()
          ..color = AppTheme.brandAccent.withValues(alpha: 0.16)
          ..strokeWidth = 1.0,
      );

      final isSelected = i == selectedIndex;
      canvas.drawLine(
        center,
        projected[i].pos,
        Paint()
          ..color = nodes[i].color.withValues(
            alpha: isSelected ? 0.65 : (projected[i].z >= 0 ? 0.26 : 0.12),
          )
          ..strokeWidth = isSelected ? 2.0 : 1.0,
      );

      if (isSelected) {
        final t = (pulsePhase / (math.pi * 2)) % 1.0;
        final pulsePos = Offset.lerp(center, projected[i].pos, t)!;
        canvas.drawCircle(
          pulsePos,
          4.5,
          Paint()
            ..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(pulsePos, 2.5, Paint()..color = nodes[i].color);
      }
    }
  }

  void _drawOrbitalRing(
    Canvas canvas, {
    required double rx,
    required double ry,
    required double rz,
    required double tiltX,
    required double tiltZ,
    required Color color,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    const steps = 60;
    for (int i = 0; i <= steps; i++) {
      final a = (i / steps) * math.pi * 2;
      double x = math.cos(a);
      double y = 0.0;
      double z = math.sin(a);

      final y1 = y * math.cos(tiltX) - z * math.sin(tiltX);
      final z1 = y * math.sin(tiltX) + z * math.cos(tiltX);
      final x2 = x * math.cos(tiltZ) - y1 * math.sin(tiltZ);
      final y2 = x * math.sin(tiltZ) + y1 * math.cos(tiltZ);

      final pt = _project3d(x2, y2, z1, rx, ry, rz);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArchConstellationPainter oldDelegate) =>
      oldDelegate.rotX != rotX ||
      oldDelegate.rotY != rotY ||
      oldDelegate.pulsePhase != pulsePhase ||
      oldDelegate.selectedIndex != selectedIndex;
}
