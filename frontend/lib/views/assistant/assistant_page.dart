import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

/// Entry point for the application-preparation assistant.
///
/// AI feedback is generated in the context of a tracked application, so this
/// page intentionally guides the user to that context instead of pretending
/// that a standalone assistant can give grounded scholarship advice.
class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Spacing.pagePadding(MediaQuery.of(context).size.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ruang Persiapan',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Gunakan AI sebagai pendamping terpercaya untuk menyiapkan berkas aplikasi berdasarkan profil dan beasiswa yang kamu lacak.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              _buildHero(context),
              const SizedBox(height: Spacing.lg),
              _buildToolGrid(context),
              const SizedBox(height: Spacing.lg),
              _buildTrustNote(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final primaryColor = AppTheme.primaryOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        gradient: AppTheme.isDark(context)
            ? const LinearGradient(
                colors: [
                  Color(0xFF0F2456),
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFF1E40AF),
                  Color(0xFF2563EB),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFBBF24),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'AI APPLICATION COPILOT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          const Text(
            'Mulai dari Application Tracker-mu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Buka detail aplikasi untuk mendapatkan review CV, bantuan motivation letter, feedback esai, atau simulasi latihan wawancara yang grounded pada konteks beasiswa incaranmu.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/applications'),
            icon: const Icon(Icons.track_changes_rounded, size: 18),
            label: const Text(
              'Buka Application Tracker',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolGrid(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    final tools = [
      (
        Icons.description_outlined,
        'Review CV',
        'Soroti pengalaman yang relevan tanpa mengarang fakta.',
        const Color(0xFF38BDF8),
      ),
      (
        Icons.edit_note_rounded,
        'Motivation Letter',
        'Susun struktur dan perkuat alasan yang berasal dari pengalamanmu.',
        const Color(0xFF818CF8),
      ),
      (
        Icons.article_outlined,
        'Feedback Esai',
        'Periksa alur, kejelasan, bukti, dan relevansi draft.',
        const Color(0xFFA78BFA),
      ),
      (
        Icons.record_voice_over_outlined,
        'Latihan Wawancara',
        'Latih pertanyaan sebagai simulasi, bukan pertanyaan resmi.',
        const Color(0xFFFBBF24),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        mainAxisExtent: 140,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark(context) ? 0.2 : 0.04,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(Spacing.md + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tool.$4.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tool.$1, color: tool.$4, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tool.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm + 2),
              Text(
                tool.$3,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustNote(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'RadarScholar tidak mengarang prestasi, pengalaman, atau persyaratan. Seluruh analisis AI grounded pada data nyata profil dan dokumen beasiswa.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
