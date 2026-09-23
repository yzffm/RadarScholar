import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme.dart';
import '../../models/scholarship.dart';
import '../../models/match_result.dart';
import '../../repositories/scholarship_repository.dart';
import '../../controllers/matching_controller.dart';
import '../../controllers/application_controller.dart';
import '../../widgets/empty_state.dart';
import 'widgets/ai_explanation_card.dart';

// Provider for fetching single scholarship detail
final scholarshipDetailProvider = FutureProvider.family<Scholarship, String>((
  ref,
  id,
) async {
  final repo = ref.watch(scholarshipRepositoryProvider);
  return repo.getScholarshipDetail(id);
});

// Provider for fetching match detail if authenticated
final scholarshipMatchDetailProvider =
    FutureProvider.family<MatchedScholarshipResponse?, String>((ref, id) async {
      final isAuth = ref.watch(isAuthenticatedProvider);
      if (!isAuth) return null;
      final repo = ref.watch(matchingRepositoryProvider);
      try {
        return await repo.getMatchDetail(id);
      } catch (e) {
        return null;
      }
    });

class ScholarshipDetailPage extends ConsumerWidget {
  const ScholarshipDetailPage({super.key, required this.scholarshipId});

  final String scholarshipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(scholarshipDetailProvider(scholarshipId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Beasiswa')),
      body: detailAsync.when(
        data: (scholarship) => _buildContent(context, ref, scholarship),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat detail',
            message:
                'Terjadi kesalahan saat memuat detail beasiswa. Silakan coba lagi.',
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Scholarship scholarship,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStatusBadge(scholarship.isActive),
          const SizedBox(height: Spacing.sm),
          Text(
            scholarship.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            scholarship.source?.providerName ?? 'Penyedia Belum Tersedia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Match Section
          Consumer(
            builder: (context, ref, child) {
              final matchAsync = ref.watch(
                scholarshipMatchDetailProvider(scholarship.id),
              );

              return matchAsync.when(
                data: (matchData) {
                  if (matchData == null) {
                    return _buildLoginPrompt(context);
                  }
                  return _buildMatchBox(
                    context,
                    matchData.match,
                    scholarship.id,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: Spacing.md),

          // Deadline info
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batas Waktu Pendaftaran',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDeadline(scholarship.deadline),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Description
          Text(
            'Deskripsi',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            scholarship.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Benefits
          if (scholarship.benefits.isNotEmpty) ...[
            Text(
              'Cakupan Beasiswa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.sm),
            ...scholarship.benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],

          // Requirements
          if (scholarship.requirements.isNotEmpty) ...[
            Text(
              'Persyaratan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.sm),
            ...scholarship.requirements.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.rule_rounded,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],

          // Call to action
          Consumer(
            builder: (context, ref, child) {
              final isAuth = ref.watch(isAuthenticatedProvider);
              if (!isAuth) {
                return _buildPrimaryAction(scholarship.applicationUrl);
              }

              final savedState = ref.watch(savedScholarshipsControllerProvider);
              final isSaved =
                  savedState is SavedScholarshipsSuccess &&
                  savedState.savedScholarships.any(
                    (s) => s.scholarship.id == scholarship.id,
                  );

              final appState = ref.watch(applicationsControllerProvider);
              final isTracked =
                  appState is ApplicationsSuccess &&
                  appState.applications.any(
                    (a) => a.scholarship.id == scholarship.id,
                  );

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (isSaved) {
                              ref
                                  .read(
                                    savedScholarshipsControllerProvider
                                        .notifier,
                                  )
                                  .unsaveScholarship(scholarship.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dihapus dari tersimpan'),
                                ),
                              );
                            } else {
                              ref
                                  .read(
                                    savedScholarshipsControllerProvider
                                        .notifier,
                                  )
                                  .saveScholarship(scholarship.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Disimpan ke daftar'),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          label: Text(isSaved ? 'Tersimpan' : 'Simpan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: AppTheme.brandPrimary,
                            side: const BorderSide(
                              color: AppTheme.brandPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isTracked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sudah dilacak')),
                              );
                            } else {
                              ref
                                  .read(applicationsControllerProvider.notifier)
                                  .createApplication(scholarship.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mulai dilacak')),
                              );
                            }
                          },
                          icon: Icon(
                            isTracked
                                ? Icons.check_circle
                                : Icons.track_changes,
                          ),
                          label: Text(isTracked ? 'Dilacak' : 'Lacak Lamaran'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: isTracked
                                ? Colors.green
                                : AppTheme.brandSecondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  _buildPrimaryAction(scholarship.applicationUrl),
                ],
              );
            },
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction(String url) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _launchUrl(url),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.brandPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: const Text(
          'Kunjungi Situs Resmi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        isActive ? 'Pendaftaran Dibuka' : 'Pendaftaran Ditutup',
        style: TextStyle(
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDeadline(DateTime? date) {
    if (date == null) return 'Batas waktu belum ditentukan';
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.brandPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.brandPrimary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'Masuk ke akun untuk melihat kecocokan beasiswa ini dengan profil Anda.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchBox(
    BuildContext context,
    MatchResult match,
    String scholarshipId,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Kecocokan Profil',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildRelevanceBadge(match.relevance),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            match.explanation,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(),
          const SizedBox(height: Spacing.sm),
          ...match.criterionEvaluations.map(
            (eval) => _buildCriterionRow(context, eval),
          ),
          const SizedBox(height: Spacing.md),
          AiExplanationCard(scholarshipId: scholarshipId),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(BuildContext context, CriterionEvaluation eval) {
    IconData icon;
    Color color;

    switch (eval.state) {
      case CriterionState.match:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case CriterionState.notMatch:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case CriterionState.unknown:
      case CriterionState.needsVerification:
        icon = Icons.help;
        color = Colors.orange;
        break;
      case CriterionState.notApplicable:
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eval.explanation,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevanceBadge(RelevanceTier relevance) {
    Color bgColor;
    Color textColor;
    String text;

    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Sangat Relevan';
        break;
      case RelevanceTier.relevan:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Relevan';
        break;
      case RelevanceTier.mungkinRelevan:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Mungkin Relevan';
        break;
      case RelevanceTier.perluDicek:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = 'Perlu Dicek';
        break;
      case RelevanceTier.belumCukupInformasi:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        text = 'Info Kurang';
        break;
      case RelevanceTier.tidakMemenuhi:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Tidak Memenuhi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
