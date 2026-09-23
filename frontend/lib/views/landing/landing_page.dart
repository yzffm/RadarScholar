import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/health_controller.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../widgets/app_logo.dart';

/// RadarScholar Landing Page — Milestone 1.
///
/// Delivers an engaging, responsive showcase (CPMK 2) demonstrating
/// live backend integration (CPMK 1) and MVC separation (CPMK 4).
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(screenWidth);
    final isMobile = Responsive.isMobile(screenWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildTopNav(context, isMobile),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, screenWidth, isDesktop, isMobile),
            _buildProductFlowSection(context, screenWidth),
            _buildFeaturesSection(context, screenWidth, isDesktop, isMobile),
            _buildBackendHealthSection(context, ref, screenWidth),
            _buildFooter(context, screenWidth),
          ],
        ),
      ),
    );
  }

  // ─── Top Navigation Bar ──────────────────────────────────────────────
  PreferredSizeWidget _buildTopNav(BuildContext context, bool isMobile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: isMobile ? 16 : 32,
      title: AppLogo(
        mode: isMobile ? AppLogoMode.iconOnly : AppLogoMode.full,
        height: isMobile ? 36 : 38,
        onTap: () => context.go('/'),
      ),
      actions: [
        if (!isMobile) ...[
          TextButton(
            onPressed: () => context.go('/discovery'),
            child: const Text('Eksplorasi Beasiswa'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.go('/assistant'),
            child: const Text('Asisten AI'),
          ),
          const SizedBox(width: 16),
        ],
        FilledButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Masuk'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brandPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  ) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 36)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 64);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F5FF), Colors.white],
        ),
      ),
      child: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: _buildHeroText(context, false)),
                      const SizedBox(width: 48),
                      Expanded(flex: 5, child: _buildHeroVisual(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildHeroText(context, true),
                      const SizedBox(height: 36),
                      _buildHeroVisual(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, bool isCentered) {
    final align = isCentered ? TextAlign.center : TextAlign.start;
    final crossAlign = isCentered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: AppTheme.brandPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Scholarship Intelligence Platform',
                style: TextStyle(
                  color: AppTheme.brandPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            height: 1.2,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: Spacing.md),

        // Subtitle
        Text(
          'RadarScholar bukan sekadar direktori tautan. Kami membantu mahasiswa Indonesia mengevaluasi kriteria resmi secara deterministik, memantau tenggat waktu, dan menyusun berkas dengan pendampingan AI terpercaya.',
          textAlign: align,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
            height: 1.6,
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
              icon: const Icon(Icons.explore_rounded, size: 20),
              label: const Text('Mulai Eksplorasi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
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
              icon: const Icon(Icons.login_rounded, size: 20),
              label: const Text('Masuk ke Akun'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                side: const BorderSide(
                  color: AppTheme.brandPrimary,
                  width: 1.5,
                ),
                foregroundColor: AppTheme.brandPrimary,
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

  Widget _buildHeroVisual(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Logo Centerpiece
          AppLogo(mode: AppLogoMode.full, height: 54),
          const SizedBox(height: Spacing.lg),
          const Divider(height: 1),
          const SizedBox(height: Spacing.lg),
          // Preview Card 1: Official verified source
          _buildHeroPreviewItem(
            icon: Icons.verified_user_rounded,
            color: Colors.teal,
            title: 'Beasiswa Prestasi Djarum 2026',
            badge: 'Terkurasi Resmi',
            desc: 'Jenjang S1 • Semester 4 • Min. IPK 3.00',
          ),
          const SizedBox(height: Spacing.md),
          // Preview Card 2: Deterministic match
          _buildHeroPreviewItem(
            icon: Icons.auto_graph_rounded,
            color: AppTheme.brandPrimary,
            title: 'Beasiswa Bakti BCA Finance',
            badge: 'Sangat Relevan',
            desc: 'Bantuan UKT + Uang Saku Bulanan • Terverifikasi',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPreviewItem({
    required IconData icon,
    required Color color,
    required String title,
    required String badge,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 22),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Flow Stepper Section ───────────────────────────────────
  Widget _buildProductFlowSection(BuildContext context, double screenWidth) {
    final steps = [
      {'num': '1', 'name': 'Discover', 'desc': 'Cari sumber resmi'},
      {'num': '2', 'name': 'Understand', 'desc': 'Pahami syarat'},
      {'num': '3', 'name': 'Match', 'desc': 'Cocokkan profil'},
      {'num': '4', 'name': 'Decide', 'desc': 'Pilih target'},
      {'num': '5', 'name': 'Prepare', 'desc': 'Susun berkas & esai'},
      {'num': '6', 'name': 'Track', 'desc': 'Pantau deadline'},
      {'num': '7', 'name': 'Official Apply', 'desc': 'Kirim ke portal resmi'},
    ];

    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                'Alur Kerja RadarScholar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prinsip panduan dari penemuan hingga pendaftaran resmi di portal beasiswa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                        Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.brandPrimary,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              step['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['desc']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (!isLast) ...[
                          Container(
                            width: 32,
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.grey.shade300,
                          ),
                        ],
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
  ) {
    final pillars = [
      {
        'icon': Icons.verified_outlined,
        'color': AppTheme.brandPrimary,
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
        'color': AppTheme.brandSecondary,
        'title': 'Manajemen Berkas & Deadline',
        'desc':
            'Daftar periksa dokumen lengkap dan pengingat tanggal penutupan agar Anda tidak pernah melewatkan batas waktu pendaftaran.',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'color': const Color(0xFF6366F1),
        'title': 'Pendamping AI Berintegritas',
        'desc':
            'Bantuan perbaikan CV dan draf esai yang menjaga keaslian data pribadi Anda tanpa memfabrikasi pencapaian atau fakta palsu.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                'Mengapa RadarScholar Berbeda?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Didesain khusus untuk mahasiswa Indonesia dengan standar keandalan tinggi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                      mainAxisExtent: 160,
                    ),
                    itemCount: pillars.length,
                    itemBuilder: (context, index) {
                      final p = pillars[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (p['color'] as Color).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Icon(
                                p['icon'] as IconData,
                                color: p['color'] as Color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
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
  ) {
    final healthAsync = ref.watch(healthControllerProvider);

    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hub_outlined,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status Integrasi Backend (CPMK 1)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  healthAsync.when(
                    data: (health) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: health.isHealthy
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: health.isHealthy
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            health.isHealthy
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: health.isHealthy
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            health.isHealthy
                                ? 'FastAPI API Terhubung • v${health.version}'
                                : 'Layanan Backend Tidak Sehat: ${health.status}',
                            style: TextStyle(
                              color: health.isHealthy
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Memeriksa status API FastAPI...',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    error: (error, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Backend lokal belum aktif (jalankan uvicorn)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
                      style: TextStyle(fontSize: 12),
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

  // ─── Footer ─────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B1329),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppLogo(mode: AppLogoMode.iconOnly, height: 36),
                  Text(
                    'RadarScholar Platform',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 RadarScholar. Proyek Rekayasa Perangkat Lunak.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Milestone 1 — Design System & App Shell',
                    style: TextStyle(
                      color: AppTheme.brandSkyBlue.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
