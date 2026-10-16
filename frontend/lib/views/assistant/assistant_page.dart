import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

/// Entry point for the application-preparation assistant — Modern SaaS Workspace.
///
/// AI feedback is generated in the context of a tracked application, so this
/// page intentionally guides the user to that context instead of pretending
/// that a standalone assistant can give grounded scholarship advice.
class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: Spacing.pagePadding(screenWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'AI COPILOT WORKSPACE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    'Ruang Persiapan',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.6,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gunakan AI sebagai pendamping terpercaya untuk menyiapkan berkas aplikasi berdasarkan profil dan beasiswa yang kamu lacak.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textMuted,
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
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: AppTheme.glowShadowOf(primaryColor, intensity: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.brandSecondary,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'AI APPLICATION COPILOT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          const Text(
            'Mulai dari Application Tracker-mu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Buka detail aplikasi untuk mendapatkan review CV, bantuan motivation letter, feedback esai, atau simulasi latihan wawancara yang grounded pada konteks beasiswa incaranmu.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.55,
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
              backgroundColor: AppTheme.brandSecondary,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

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
        AppTheme.brandSecondary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 460,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        mainAxisExtent: 148,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor),
            boxShadow: AppTheme.cardShadowOf(context),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tool.$4.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tool.$4.withValues(alpha: 0.3)),
                    ),
                    child: Icon(tool.$1, color: tool.$4, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tool.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tool.$3,
                style: TextStyle(fontSize: 13, color: textMuted, height: 1.45),
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
    final primaryColor = AppTheme.primaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.md + 2),
      decoration: BoxDecoration(
        color: AppTheme.cardColorOf(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'RadarScholar tidak mengarang prestasi, pengalaman, atau persyaratan. Seluruh analisis AI grounded pada data nyata profil dan dokumen beasiswa.',
              style: TextStyle(color: textMuted, fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
