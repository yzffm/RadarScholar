import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../controllers/health_controller.dart';
import '../../controllers/scholarship_controller.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/scholarship.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Landing Page — Professional, Simple, Elegant, and Modern.
///
/// Key UX & Architectural Principles:
/// 1. Hero section right side is strictly a clean, minimalist visual composition
///    using brand assets and icons only (zero data clutter or fake evaluations).
/// 2. All internal workspace routes require authentication; unauthenticated
///    visitors can preview real active scholarships fetched directly from the
///    FastAPI backend (`GET /api/v1/scholarships?status=active`) and are guided
///    to `/login` or `/register` to evaluate personal eligibility.
/// 3. Zero hardcoded scholarship data.
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(scholarshipControllerProvider.notifier)
          .fetchScholarships(refresh: true, status: 'active');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(screenWidth);
    final isMobile = Responsive.isMobile(screenWidth);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildTopNav(context, isMobile, isDark),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, isDesktop, isMobile, isDark),
            _buildDatabasePreviewSection(context, isDesktop, isMobile, isDark),
            _buildWorkflowSection(context, isDark),
            _buildFeaturesSection(context, isDark),
            _buildBackendHealthSection(context, isDark),
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  // ─── Top Navigation Bar ──────────────────────────────────────────────
  PreferredSizeWidget _buildTopNav(
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
          : Colors.white.withValues(alpha: 0.96),
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
            onPressed: () => context.go('/about'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'Tentang Kami',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 8),
        ] else ...[
          IconButton(
            tooltip: 'Tentang Kami',
            onPressed: () => context.go('/about'),
            icon: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: textSecondary,
            ),
          ),
        ],
        // Theme toggle button
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
        if (!isMobile) ...[
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text(
              'Masuk',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 8),
        ],
        FilledButton(
          onPressed: () => context.go(isMobile ? '/login' : '/register'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Text(
            isMobile ? 'Masuk' : 'Daftar',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ),
        SizedBox(width: isMobile ? 16 : 32),
      ],
    );
  }

  // ─── Hero Section: Clean Typography + Pure Visual/Icon Composition ────
  Widget _buildHeroSection(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 40)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 76);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0C1526), Color(0xFF090D16)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF1F5F9), Color(0xFFF8FAFC)],
              ),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtleOf(context)),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildHeroText(context, false, isDark),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 5,
                        child: _buildHeroVisualShowcase(context, isDark),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildHeroText(context, true, isDark),
                      const SizedBox(height: 40),
                      _buildHeroVisualShowcase(context, isDark),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, bool isCentered, bool isDark) {
    final align = isCentered ? TextAlign.center : TextAlign.start;
    final crossAlign = isCentered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final accentColor = isDark ? AppTheme.brandAccent : AppTheme.brandPrimary;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.30 : 0.20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.brandTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Scholarship Intelligence Platform',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Text(
          'Temukan Beasiswa yang Benar-benar Relevan untuk Masa Depanmu.',
          textAlign: align,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Evaluasi kriteria beasiswa resmi berdasarkan profil akademik Anda, pantau tenggat pendaftaran, dan susun berkas bersama asisten AI yang berintegritas.',
          textAlign: align,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textSecondary,
            height: 1.65,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/register'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Mulai Sekarang'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Masuk ke Akun'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                backgroundColor: AppTheme.cardColorOf(context),
                side: BorderSide(
                  color: AppTheme.borderStrongOf(context),
                  width: 1.2,
                ),
                foregroundColor: textPrimary,
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

  /// Pure visual composition using only brand assets and minimalist icons.
  /// Contains zero text rows or data tables so the Hero remains calm and elegant.
  Widget _buildHeroVisualShowcase(BuildContext context, bool isDark) {
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final borderStrong = AppTheme.borderStrongOf(context);

    return SizedBox(
      height: 360,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Soft Ambient Glow
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.brandPrimary.withValues(
                        alpha: isDark ? 0.22 : 0.10,
                      ),
                      AppTheme.brandAccent.withValues(
                        alpha: isDark ? 0.08 : 0.04,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 2. Clean Concentric Architectural Rings & Axis Lines
              Positioned.fill(
                child: CustomPaint(
                  painter: _HeroMinimalistRingsPainter(
                    ringColor: borderStrong.withValues(
                      alpha: isDark ? 0.45 : 0.65,
                    ),
                    accentColor: AppTheme.brandPrimary.withValues(
                      alpha: isDark ? 0.32 : 0.20,
                    ),
                  ),
                ),
              ),

              // 3. Central Elevated Brand Emblem Card
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(
                      alpha: isDark ? 0.40 : 0.22,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandPrimary.withValues(
                        alpha: isDark ? 0.24 : 0.10,
                      ),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: AppLogo.icon(height: 76),
              ),

              // 4. Four Symmetrical Minimalist Icon Nodes (Pure Icons, Zero Data)
              Positioned(
                top: 28,
                left: 36,
                child: _buildMinimalIconBadge(
                  cardBg: cardBg,
                  borderColor: borderSubtle,
                  icon: Icons.verified_outlined,
                  iconColor: AppTheme.brandTertiary,
                  isDark: isDark,
                ),
              ),
              Positioned(
                top: 28,
                right: 36,
                child: _buildMinimalIconBadge(
                  cardBg: cardBg,
                  borderColor: borderSubtle,
                  icon: Icons.tune_rounded,
                  iconColor: AppTheme.brandPrimary,
                  isDark: isDark,
                ),
              ),
              Positioned(
                bottom: 28,
                left: 36,
                child: _buildMinimalIconBadge(
                  cardBg: cardBg,
                  borderColor: borderSubtle,
                  icon: Icons.auto_awesome_outlined,
                  iconColor: AppTheme.brandAI,
                  isDark: isDark,
                ),
              ),
              Positioned(
                bottom: 28,
                right: 36,
                child: _buildMinimalIconBadge(
                  cardBg: cardBg,
                  borderColor: borderSubtle,
                  icon: Icons.event_available_outlined,
                  iconColor: AppTheme.brandWarning,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalIconBadge({
    required Color cardBg,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  // ─── Real Database Preview Section (100% Backend-Driven, Redirects to Login) ───
  Widget _buildDatabasePreviewSection(
    BuildContext context,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final discoveryState = ref.watch(scholarshipControllerProvider);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);

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
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Text(
                'Beasiswa Aktif di Database',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pratinjau langsung dari database portal resmi. Masuk ke akun Anda untuk melihat detail syarat dan mengevaluasi kecocokan profil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildDatabasePreviewContent(
                context,
                discoveryState,
                isDesktop,
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatabasePreviewContent(
    BuildContext context,
    ScholarshipDiscoveryState state,
    bool isDesktop,
    bool isDark,
  ) {
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    if (state is ScholarshipDiscoveryInitial ||
        state is ScholarshipDiscoveryLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(height: 14),
            Text(
              'Memuat data beasiswa aktif dari database...',
              style: TextStyle(color: textSecondary, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    if (state is ScholarshipDiscoveryError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: borderSubtle),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, color: textSecondary, size: 28),
            const SizedBox(height: 10),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(scholarshipControllerProvider.notifier)
                    .fetchScholarships(refresh: true, status: 'active');
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Muat Ulang dari Server'),
            ),
          ],
        ),
      );
    }

    if (state is ScholarshipDiscoveryEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: borderSubtle),
        ),
        child: Text(
          'Belum ada beasiswa aktif yang tersedia di database saat ini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary, fontSize: 13.5),
        ),
      );
    }

    final items = (state as ScholarshipDiscoverySuccess).scholarships
        .take(3)
        .toList();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isThreeCol = constraints.maxWidth >= 900;
            if (isThreeCol) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 20),
                    Expanded(
                      child: _buildLiveScholarshipCard(
                        context,
                        items[i],
                        isDark,
                      ),
                    ),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _buildLiveScholarshipCard(context, items[i], isDark),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.lock_open_rounded, size: 17),
          label: const Text(
            'Masuk untuk Melihat Seluruh Beasiswa & Evaluasi Kecocokan Profil',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveScholarshipCard(
    BuildContext context,
    Scholarship scholarship,
    bool isDark,
  ) {
    final cardBg = AppTheme.cardColorOf(context);
    final surfaceElevated = AppTheme.surfaceElevatedOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    final deadlineLabel = scholarship.deadline != null
        ? 'Tenggat: ${DateFormat('dd MMM yyyy').format(scholarship.deadline!)}'
        : 'Tenggat belum ditentukan';

    final statusLabel = scholarship.isActive ? 'Aktif' : 'Ditutup';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/login'),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: borderSubtle),
            boxShadow: AppTheme.cardShadowOf(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.brandTertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: AppTheme.brandTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                scholarship.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scholarship.source?.providerName ??
                    'Portal Resmi Terverifikasi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        deadlineLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logical UX Workflow Section ─────────────────────────────────────
  Widget _buildWorkflowSection(BuildContext context, bool isDark) {
    final steps = [
      (
        num: '01',
        title: 'Buat Akun & Profil Akademik',
        desc:
            'Lengkapi jenjang studi, jurusan, semester, dan IPK Anda sebagai dasar evaluasi kelayakan.',
      ),
      (
        num: '02',
        title: 'Eksplorasi Sumber Resmi',
        desc:
            'Telusuri beasiswa aktif dari portal resmi lengkap dengan rincian syarat dan tautan aslinya.',
      ),
      (
        num: '03',
        title: 'Evaluasi Kecocokan Objektif',
        desc:
            'Sistem membandingkan profil akademik Anda terhadap kriteria beasiswa secara deterministik.',
      ),
      (
        num: '04',
        title: 'Siapkan Berkas & Daftar',
        desc:
            'Pantau checklist dokumen, rapikan esai bersama asisten AI, lalu daftar di portal resmi.',
      ),
    ];

    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final cardBg = AppTheme.cardColorOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Text(
                'Cara Kerja RadarScholar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alur yang terarah mulai dari pengisian profil hingga pengajuan di situs resmi penyelenggara',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 900
                      ? 4
                      : (constraints.maxWidth >= 600 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      mainAxisExtent: 176,
                    ),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.brandPrimary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                step.num,
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.brandAccent
                                      : AppTheme.brandPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.title,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                step.desc,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12.5,
                                  height: 1.45,
                                ),
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

  // ─── Core Pillars Section (Clean Standard Cards) ─────────────────────
  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    final pillars = [
      (
        icon: Icons.verified_outlined,
        color: AppTheme.brandTertiary,
        title: 'Sumber Resmi Terkurasi',
        desc:
            'Informasi bersumber dari registri portal resmi dengan atribusi tautan asli dan catatan waktu verifikasi.',
      ),
      (
        icon: Icons.rule_rounded,
        color: isDark ? AppTheme.brandAccent : AppTheme.brandPrimary,
        title: 'Pencocokan Deterministik',
        desc:
            'Kriteria objektif dihitung secara pasti berdasarkan profil Anda tanpa skor probabilitas yang menyesatkan.',
      ),
      (
        icon: Icons.checklist_rounded,
        color: AppTheme.brandWarning,
        title: 'Manajemen Berkas & Tenggat',
        desc:
            'Daftar periksa dokumen dan pemantauan jadwal penutupan agar persiapan lamaran Anda tetap terorganisir.',
      ),
      (
        icon: Icons.auto_awesome_rounded,
        color: AppTheme.brandAI,
        title: 'Pendamping AI Berintegritas',
        desc:
            'Bantuan peninjauan CV dan struktur esai yang menjaga keaslian riwayat akademik Anda tanpa fabrikasi fakta.',
      ),
    ];

    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Text(
                'Mengapa RadarScholar Berbeda?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dirancang dengan fokus pada keakuratan sumber, transparansi kriteria, dan kemandirian pendaftar',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 840 ? 2 : 1;
                  final cardBg = AppTheme.cardColorOf(context);
                  final borderSubtle = AppTheme.borderSubtleOf(context);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      mainAxisExtent: 168,
                    ),
                    itemCount: pillars.length,
                    itemBuilder: (context, index) {
                      final p = pillars[index];
                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: borderSubtle),
                          boxShadow: AppTheme.cardShadowOf(context),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: p.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Icon(p.icon, color: p.color, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      p.desc,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: textSecondary,
                                        height: 1.5,
                                      ),
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

  // ─── Backend Connectivity Card (CPMK 1 Evidence) ─────────────────────
  Widget _buildBackendHealthSection(BuildContext context, bool isDark) {
    final healthAsync = ref.watch(healthControllerProvider);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(top: BorderSide(color: borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      color: isDark
                          ? AppTheme.brandAccent
                          : AppTheme.brandPrimary,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status Integrasi Backend (CPMK 1)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                healthAsync.when(
                  data: (health) {
                    final statusColor = health.isHealthy
                        ? AppTheme.brandTertiary
                        : AppTheme.brandDanger;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            health.isHealthy
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            health.isHealthy
                                ? 'FastAPI API Terhubung • v${health.version}'
                                : 'Layanan Backend Tidak Sehat: ${health.status}',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Memeriksa status API FastAPI...',
                        style: TextStyle(fontSize: 12.5, color: textSecondary),
                      ),
                    ],
                  ),
                  error: (error, _) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.brandWarning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppTheme.brandWarning.withValues(alpha: 0.30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: AppTheme.brandWarning,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Backend lokal belum aktif (jalankan uvicorn)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brandWarning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => ref.invalidate(healthControllerProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text(
                    'Perbarui Status',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context, bool isDark) {
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        border: Border(top: BorderSide(color: borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(mode: AppLogoMode.iconOnly, height: 28),
                  const SizedBox(width: 10),
                  Text(
                    '© 2026 RadarScholar',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/about'),
                child: Text(
                  'Tentang Pembuat',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws clean, minimal concentric rings and diagonal connector lines for the
/// pure visual Hero showcase without any heavy dark background.
class _HeroMinimalistRingsPainter extends CustomPainter {
  final Color ringColor;
  final Color accentColor;

  const _HeroMinimalistRingsPainter({
    required this.ringColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    final outerPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final innerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final outerRadius = (size.shortestSide * 0.44).clamp(90.0, 165.0);
    final innerRadius = outerRadius * 0.66;

    canvas.drawCircle(center, outerRadius, outerPaint);
    canvas.drawCircle(center, innerRadius, innerPaint);

    // Subtle connector lines from center toward the 4 corner icon badges
    final linePaint = Paint()
      ..color = ringColor.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    final dx = size.width * 0.30;
    final dy = size.height * 0.32;
    canvas.drawLine(center, Offset(center.dx - dx, center.dy - dy), linePaint);
    canvas.drawLine(center, Offset(center.dx + dx, center.dy - dy), linePaint);
    canvas.drawLine(center, Offset(center.dx - dx, center.dy + dy), linePaint);
    canvas.drawLine(center, Offset(center.dx + dx, center.dy + dy), linePaint);
  }

  @override
  bool shouldRepaint(covariant _HeroMinimalistRingsPainter old) {
    return old.ringColor != ringColor || old.accentColor != accentColor;
  }
}
