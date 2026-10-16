import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/health_controller.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Modern Intelligence SaaS Landing Page.
///
/// Fully supports Dark & Light mode, responsive Desktop/Tablet/Mobile layouts
/// (CPMK 2), and live FastAPI health telemetry (CPMK 1).
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(screenWidth);
    final isMobile = Responsive.isMobile(screenWidth);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildTopNav(context, ref, isMobile, isDark),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(
              context,
              screenWidth,
              isDesktop,
              isMobile,
              isDark,
            ),
            _buildProductFlowSection(context, screenWidth, isDark),
            _buildFeaturesSection(
              context,
              screenWidth,
              isDesktop,
              isMobile,
              isDark,
            ),
            _buildBackendHealthSection(context, ref, screenWidth, isDark),
            _buildFooter(context, screenWidth, isDark),
          ],
        ),
      ),
    );
  }

  // ─── Top Navigation Bar ──────────────────────────────────────────────
  PreferredSizeWidget _buildTopNav(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    bool isDark,
  ) {
    final borderColor = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return AppBar(
      backgroundColor: isDark
          ? AppTheme.darkBackground.withValues(alpha: 0.92)
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
            onPressed: () => context.go('/discovery'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'Eksplorasi Beasiswa',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => context.go('/recommendations'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'AI Matcher',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () => context.go('/assistant'),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text(
              'Asisten AI',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 12),
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
        FilledButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login_rounded, size: 17),
          label: const Text('Masuk'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brandPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 16 : 32),
      ],
    );
  }

  // ─── Hero Section ───────────────────────────────────────────────────
  Widget _buildHeroSection(
    BuildContext context,
    double screenWidth,
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
                colors: [Color(0xFF0B1428), Color(0xFF090D16)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
              ),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtleOf(context)),
        ),
      ),
      child: Stack(
        children: [
          // Subtle ambient radial glow
          Positioned(
            top: -120,
            right: isDesktop ? 80 : -60,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.brandPrimary.withValues(
                        alpha: isDark ? 0.18 : 0.10,
                      ),
                      AppTheme.brandAccent.withValues(
                        alpha: isDark ? 0.06 : 0.03,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
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
                            child: _buildHeroText(context, false, isDark),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 5,
                            child: _buildHeroVisual(context, isDark),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildHeroText(context, true, isDark),
                          const SizedBox(height: 36),
                          _buildHeroVisual(context, isDark),
                        ],
                      ),
              ),
            ),
          ),
        ],
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
        // Intelligence Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.32 : 0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.brandTertiary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandTertiary.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Scholarship Intelligence Platform',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // Headline
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

        // Subtitle
        Text(
          'RadarScholar bukan sekadar direktori tautan. Kami membantu mahasiswa Indonesia mengevaluasi kriteria resmi secara deterministik, memantau tenggat waktu, dan menyusun berkas dengan pendampingan AI terpercaya.',
          textAlign: align,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textSecondary,
            height: 1.65,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: Spacing.xl),

        // CTAs
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/discovery'),
              icon: const Icon(Icons.explore_rounded, size: 19),
              label: const Text('Mulai Eksplorasi'),
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
              icon: const Icon(Icons.login_rounded, size: 19),
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
        const SizedBox(height: Spacing.lg),

        // Trust telemetry bar
        Wrap(
          spacing: 20,
          runSpacing: 8,
          alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildTrustMetric(
              context,
              icon: Icons.verified_rounded,
              label: '100% Sumber Resmi Terkurasi',
              color: AppTheme.brandTertiary,
            ),
            _buildTrustMetric(
              context,
              icon: Icons.rule_rounded,
              label: 'Mesin Aturan Deterministik',
              color: accentColor,
            ),
            _buildTrustMetric(
              context,
              icon: Icons.shield_outlined,
              label: 'Bebas Halusinasi Syarat',
              color: AppTheme.brandAI,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroVisual(BuildContext context, bool isDark) {
    final cardBg = AppTheme.cardColorOf(context);
    final elevatedBg = AppTheme.surfaceElevatedOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final borderStrong = AppTheme.borderStrongOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppTheme.cardShadowOf(context),
        border: Border.all(color: borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top window chrome + live indicator
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: elevatedBg,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: AppTheme.brandAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RADAR ENGINE v2.4',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Center(child: AppLogo(mode: AppLogoMode.full, height: 46)),
          const SizedBox(height: Spacing.lg),
          Divider(height: 1, color: borderSubtle),
          const SizedBox(height: Spacing.md),
          Text(
            'TELEMETRI INTELIJENSI BEASISWA',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: textMuted,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildHeroPreviewItem(
            context: context,
            icon: Icons.verified_user_rounded,
            color: AppTheme.brandTertiary,
            title: 'Sumber resmi, lebih terpercaya',
            badge: 'Source-first',
            desc:
                'Lihat asal data, status verifikasi, dan deadline dengan jelas.',
          ),
          const SizedBox(height: Spacing.sm),
          _buildHeroPreviewItem(
            context: context,
            icon: Icons.auto_graph_rounded,
            color: isDark ? AppTheme.brandAccent : AppTheme.brandPrimary,
            title: 'Match yang bisa dijelaskan',
            badge: 'Deterministik',
            desc: 'Pahami kenapa peluang tertentu relevan dengan profilmu.',
          ),
          const SizedBox(height: Spacing.sm),
          _buildHeroPreviewItem(
            context: context,
            icon: Icons.auto_awesome_rounded,
            color: AppTheme.brandAI,
            title: 'Pendamping Persiapan Berintegritas',
            badge: 'Zero-Fabrication',
            desc:
                'Review CV, motivasi esai, dan checklist berkas sesuai fakta.',
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: elevatedBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppTheme.brandTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Evaluasi kriteria IPK, Jenjang, Semester & Dokumen secara objektif',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPreviewItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String badge,
    required String desc,
  }) {
    final surfaceBg = AppTheme.surfaceOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: color.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: color, size: 20),
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
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: color.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11.5, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Flow Stepper Section ───────────────────────────────────
  Widget _buildProductFlowSection(
    BuildContext context,
    double screenWidth,
    bool isDark,
  ) {
    final steps = [
      {'num': '1', 'name': 'Discover', 'desc': 'Cari sumber resmi'},
      {'num': '2', 'name': 'Understand', 'desc': 'Pahami syarat'},
      {'num': '3', 'name': 'Match', 'desc': 'Cocokkan profil'},
      {'num': '4', 'name': 'Decide', 'desc': 'Pilih target'},
      {'num': '5', 'name': 'Prepare', 'desc': 'Susun berkas & esai'},
      {'num': '6', 'name': 'Track', 'desc': 'Pantau deadline'},
      {'num': '7', 'name': 'Official Apply', 'desc': 'Kirim ke portal resmi'},
    ];

    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final cardBg = AppTheme.cardColorOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(bottom: BorderSide(color: borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
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
                  '7-STAGE WORKFLOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppTheme.brandAccent
                        : AppTheme.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Alur Kerja RadarScholar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prinsip panduan dari penemuan hingga pendaftaran resmi di portal beasiswa',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: Spacing.xl),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: steps.map((step) {
                    final isLast = step == steps.last;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 132,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: borderSubtle),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.brandPrimary,
                                      Color(0xFF1D4ED8),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.brandPrimary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    step['num']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                step['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                step['desc']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 24,
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: AppTheme.borderStrongOf(context),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Features Grid Section ──────────────────────────────────────────
  Widget _buildFeaturesSection(
    BuildContext context,
    double screenWidth,
    bool isDesktop,
    bool isMobile,
    bool isDark,
  ) {
    final pillars = [
      {
        'icon': Icons.verified_outlined,
        'color': isDark ? AppTheme.brandAccent : AppTheme.brandPrimary,
        'title': 'Sumber Resmi Terkurasi',
        'desc':
            'Informasi bersumber langsung dari portal resmi (BCA, Djarum, LPDP, dll) dengan atribusi tautan asli dan tanggal verifikasi.',
      },
      {
        'icon': Icons.rule_rounded,
        'color': AppTheme.brandTertiary,
        'title': 'Pencocokan Deterministik',
        'desc':
            'Kriteria objektif (IPK, semester, jenjang) dihitung secara pasti tanpa skor probabilitas palsu. Relevansi disampaikan secara kualitatif dan transparan.',
      },
      {
        'icon': Icons.checklist_rounded,
        'color': AppTheme.brandWarning,
        'title': 'Manajemen Berkas & Deadline',
        'desc':
            'Daftar periksa dokumen lengkap dan pengingat tanggal penutupan agar Anda tidak pernah melewatkan batas waktu pendaftaran.',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'color': AppTheme.brandAI,
        'title': 'Pendamping AI Berintegritas',
        'desc':
            'Bantuan perbaikan CV dan draf esai yang menjaga keaslian data pribadi Anda tanpa memfabrikasi pencapaian atau fakta palsu.',
      },
    ];

    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 68),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
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
                'Didesain khusus untuk mahasiswa Indonesia dengan standar keandalan tinggi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
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
                      final color = p['color'] as Color;
                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: borderSubtle),
                          boxShadow: AppTheme.cardShadowOf(context),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Icon(
                                p['icon'] as IconData,
                                color: color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      p['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                        height: 1.45,
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
  Widget _buildBackendHealthSection(
    BuildContext context,
    WidgetRef ref,
    double screenWidth,
    bool isDark,
  ) {
    final healthAsync = ref.watch(healthControllerProvider);
    final cardBg = AppTheme.cardColorOf(context);
    final borderSubtle = AppTheme.borderSubtleOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        border: Border(top: BorderSide(color: borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: borderSubtle),
              boxShadow: AppTheme.cardShadowOf(context),
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
                      size: 20,
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
                const SizedBox(height: 14),
                healthAsync.when(
                  data: (health) {
                    final statusColor = health.isHealthy
                        ? AppTheme.brandTertiary
                        : AppTheme.brandDanger;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.32),
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
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            health.isHealthy
                                ? 'FastAPI API Terhubung • v${health.version}'
                                : 'Layanan Backend Tidak Sehat: ${health.status}',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Memeriksa status API FastAPI...',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                  error: (error, _) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.brandWarning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppTheme.brandWarning.withValues(alpha: 0.32),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: AppTheme.brandWarning,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Backend lokal belum aktif (jalankan uvicorn)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brandWarning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => ref.invalidate(healthControllerProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
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
  Widget _buildFooter(BuildContext context, double screenWidth, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF060911) : const Color(0xFF090D16),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  const AppLogo(mode: AppLogoMode.iconOnly, height: 34),
                  Text(
                    'RadarScholar Intelligence Platform',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '© 2026 RadarScholar. Proyek Rekayasa Perangkat Lunak.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Sumber resmi. Keputusan yang lebih terarah.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
