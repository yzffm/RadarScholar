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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primaryOf(context);
    final cardColor = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metadata Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStatusBadge(isDark, scholarship.isActive),
                  const Spacer(),
                  if (scholarship.source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.blueGrey.withValues(alpha: 0.2)
                            : Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isDark
                              ? Colors.blueGrey.withValues(alpha: 0.3)
                              : Colors.blueGrey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: isDark
                                ? Colors.blueGrey.shade200
                                : Colors.blueGrey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            scholarship.source!.providerName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.blueGrey.shade200
                                  : Colors.blueGrey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Title
              Text(
                scholarship.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                scholarship.source?.providerName ?? 'Penyedia Belum Tersedia',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.lg),

              // Match Section
              Consumer(
                builder: (context, ref, child) {
                  final matchAsync = ref.watch(
                    scholarshipMatchDetailProvider(scholarship.id),
                  );

                  return matchAsync.when(
                    data: (matchData) {
                      if (matchData == null) {
                        return _buildLoginPrompt(context, isDark, primary);
                      }
                      return _buildMatchBox(
                        context,
                        matchData.match,
                        scholarship.id,
                        isDark,
                        primary,
                        cardColor,
                        borderColor,
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.md),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, st) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: Spacing.lg),

              // Deadline info banner
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF261D11)
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF854D0E)
                        : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.shade900.withValues(alpha: 0.3)
                            : Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: isDark
                            ? Colors.amber.shade300
                            : Colors.amber.shade800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batas Waktu Pendaftaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.amber.shade300
                                  : Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDeadline(scholarship.deadline),
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.amber.shade100
                                  : Colors.amber.shade900,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Description section
              _buildSectionHeader(
                context,
                'Deskripsi Lengkap',
                Icons.notes_rounded,
              ),
              const SizedBox(height: Spacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  scholarship.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.88),
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Benefits
              if (scholarship.benefits.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Cakupan Beasiswa',
                  Icons.card_giftcard_rounded,
                ),
                const SizedBox(height: Spacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: scholarship.benefits
                        .map(
                          (b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF10B981),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                Expanded(
                                  child: Text(
                                    b.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
              ],

              // Requirements
              if (scholarship.requirements.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Persyaratan',
                  Icons.rule_folder_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: scholarship.requirements
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_right_rounded,
                                    color: primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                Expanded(
                                  child: Text(
                                    r.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: Spacing.xl),
              ],

              // Action Buttons
              Consumer(
                builder: (context, ref, child) {
                  final isAuth = ref.watch(isAuthenticatedProvider);
                  if (!isAuth) {
                    return _buildPrimaryAction(
                      context,
                      scholarship.applicationUrl,
                      primary,
                    );
                  }

                  final savedState = ref.watch(
                    savedScholarshipsControllerProvider,
                  );
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
                              onPressed: () async {
                                if (isSaved) {
                                  try {
                                    await ref
                                        .read(
                                          savedScholarshipsControllerProvider
                                              .notifier,
                                        )
                                        .unsaveScholarship(scholarship.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Dihapus dari tersimpan',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menghapus dari tersimpan',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  try {
                                    await ref
                                        .read(
                                          savedScholarshipsControllerProvider
                                              .notifier,
                                        )
                                        .saveScholarship(scholarship.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Disimpan ke daftar'),
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menyimpan beasiswa',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                              ),
                              label: Text(isSaved ? 'Tersimpan' : 'Simpan'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                foregroundColor: primary,
                                side: BorderSide(
                                  color: primary.withValues(alpha: 0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (isTracked) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sudah dilacak di tracker lamaran',
                                      ),
                                    ),
                                  );
                                } else {
                                  try {
                                    await ref
                                        .read(
                                          applicationsControllerProvider
                                              .notifier,
                                        )
                                        .createApplication(scholarship.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Lamaran mulai dilacak',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal memulai tracking lamaran',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: Icon(
                                isTracked
                                    ? Icons.check_circle_rounded
                                    : Icons.radar_rounded,
                              ),
                              label: Text(
                                isTracked ? 'Sedang Dilacak' : 'Lacak Lamaran',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: isTracked
                                    ? const Color(0xFF10B981)
                                    : primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      _buildPrimaryAction(
                        context,
                        scholarship.applicationUrl,
                        primary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryOf(context)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryAction(BuildContext context, String url, Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text(
          'Kunjungi Situs Resmi Beasiswa',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
            : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isActive
              ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
              : (isDark ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Pendaftaran Dibuka' : 'Pendaftaran Ditutup',
            style: TextStyle(
              color: isActive
                  ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF166534))
                  : (isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF991B1B)),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget _buildLoginPrompt(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'Masuk ke akun untuk melihat analisis kecocokan beasiswa ini dengan profil akademik Anda.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
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
    bool isDark,
    Color primary,
    Color cardColor,
    Color borderColor,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: primary, size: 18),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Kecocokan Profil Anda',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              _buildRelevanceBadge(isDark, match.relevance),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            match.explanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Divider(color: borderColor),
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
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF10B981);
        break;
      case CriterionState.notMatch:
        icon = Icons.cancel_rounded;
        color = const Color(0xFFEF4444);
        break;
      case CriterionState.unknown:
      case CriterionState.needsVerification:
        icon = Icons.help_outline_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case CriterionState.notApplicable:
        icon = Icons.remove_circle_outline_rounded;
        color = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              eval.explanation,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevanceBadge(bool isDark, RelevanceTier relevance) {
    Color bgColor;
    Color textColor;
    String text;

    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF166534);
        text = 'Sangat Relevan';
        break;
      case RelevanceTier.relevan:
        bgColor = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1);
        text = 'Relevan';
        break;
      case RelevanceTier.mungkinRelevan:
        bgColor = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
        text = 'Mungkin Relevan';
        break;
      case RelevanceTier.perluDicek:
        bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
        textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
        text = 'Perlu Dicek';
        break;
      case RelevanceTier.belumCukupInformasi:
        bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
        textColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);
        text = 'Info Kurang';
        break;
      case RelevanceTier.tidakMemenuhi:
        bgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
        text = 'Tidak Memenuhi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
