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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Gunakan AI sebagai pendamping untuk menyiapkan aplikasi berdasarkan profil dan beasiswa yang kamu lacak.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: colors.secondary, size: 32),
          const SizedBox(height: Spacing.md),
          Text(
            'Mulai dari application tracker-mu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Buka detail aplikasi untuk mendapatkan review CV, bantuan motivation letter, feedback esai, atau latihan wawancara yang grounded pada konteks beasiswamu.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/applications'),
            icon: const Icon(Icons.track_changes_rounded),
            label: const Text('Buka Application Tracker'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.secondary,
              foregroundColor: colors.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolGrid(BuildContext context) {
    final tools = [
      (
        Icons.description_outlined,
        'Review CV',
        'Soroti pengalaman yang relevan tanpa mengarang fakta.',
      ),
      (
        Icons.edit_note_rounded,
        'Motivation letter',
        'Susun struktur dan perkuat alasan yang berasal dari pengalamanmu.',
      ),
      (
        Icons.article_outlined,
        'Feedback esai',
        'Periksa alur, kejelasan, bukti, dan relevansi draft.',
      ),
      (
        Icons.record_voice_over_outlined,
        'Latihan wawancara',
        'Latih pertanyaan sebagai simulasi, bukan pertanyaan resmi.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        crossAxisSpacing: Spacing.md,
        mainAxisSpacing: Spacing.md,
        mainAxisExtent: 150,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tool.$1, color: AppTheme.brandPrimary),
                const SizedBox(height: Spacing.sm),
                Text(
                  tool.$2,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(tool.$3, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrustNote(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'RadarScholar tidak mengarang prestasi, pengalaman, atau persyaratan. Periksa kembali setiap saran sebelum digunakan.',
        style: TextStyle(color: colors.onPrimaryContainer, height: 1.4),
      ),
    );
  }
}
