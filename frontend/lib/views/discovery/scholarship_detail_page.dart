import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../core/scholarship_status.dart';
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
    final borderColor = AppTheme.borderColorOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Beasiswa'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: detailAsync.when(
        data: (scholarship) => _buildContent(context, ref, scholarship),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Gagal memuat detail',
          message:
              'Terjadi kesalahan saat memuat detail beasiswa. Silakan coba lagi.',
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Scholarship scholarship,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 960;
    final isDark = AppTheme.isDark(context);
    final primary = AppTheme.primaryOf(context);
    final cardColor = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: SingleChildScrollView(
          padding: Spacing.pagePadding(screenWidth),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildMainColumn(
                        context,
                        ref,
                        scholarship,
                        isDark,
                        primary,
                        cardColor,
                        borderColor,
                      ),
                    ),
                    const SizedBox(width: Spacing.xl),
                    Expanded(
                      flex: 4,
                      child: _buildSideActionPanel(
                        context,
                        ref,
                        scholarship,
                        isDark,
                        primary,
                        cardColor,
                        borderColor,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainColumn(
                      context,
                      ref,
                      scholarship,
                      isDark,
                      primary,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: Spacing.lg),
                    _buildSideActionPanel(
                      context,
                      ref,
                      scholarship,
                      isDark,
                      primary,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(
    BuildContext context,
    WidgetRef ref,
    Scholarship scholarship,
    bool isDark,
    Color primary,
    Color cardColor,
    Color borderColor,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: borderColor),
            boxShadow: AppTheme.cardShadowOf(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStatusBadge(isDark, registrationStatusOf(scholarship)),
                  const Spacer(),
                  if (scholarship.source != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevatedOf(context),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            scholarship.source!.providerName,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                scholarship.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.6,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scholarship.source?.providerName ?? 'Penyedia Belum Tersedia',
                style: TextStyle(
                  fontSize: 14.5,
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // Match Intelligence Section
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

        // Description Section
        _buildSectionHeader(context, 'Deskripsi Lengkap', Icons.notes_rounded),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor),
            boxShadow: AppTheme.cardShadowOf(context),
          ),
          child: Text(
            scholarship.description,
            style: TextStyle(color: textSecondary, height: 1.65, fontSize: 14),
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // Benefits Section
        if (scholarship.benefits.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Cakupan Beasiswa',
            Icons.card_giftcard_rounded,
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor),
              boxShadow: AppTheme.cardShadowOf(context),
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
                              color: AppTheme.statusSuccess.withValues(
                                alpha: 0.14,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppTheme.statusSuccess,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b.description,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
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
          const SizedBox(height: Spacing.lg),
        ],

        // Requirements Section
        if (scholarship.requirements.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Persyaratan',
            Icons.rule_folder_outlined,
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor),
              boxShadow: AppTheme.cardShadowOf(context),
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
                              color: primary.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_right_rounded,
                              color: primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.description,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
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
        ],
      ],
    );
  }

  Widget _buildSideActionPanel(
    BuildContext context,
    WidgetRef ref,
    Scholarship scholarship,
    bool isDark,
    Color primary,
    Color cardColor,
    Color borderColor,
  ) {
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RINGKASAN & TINDAKAN',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Deadline Info Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.brandSecondary.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppTheme.brandSecondary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.brandSecondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: AppTheme.brandSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scholarship.openDate != null &&
                                scholarship.deadline != null
                            ? 'Periode Pendaftaran'
                            : 'Batas Waktu Pendaftaran',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFFB45309),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatRegistrationDates(
                          scholarship.openDate,
                          scholarship.deadline,
                        ),
                        style: TextStyle(
                          fontSize: 14.5,
                          color: textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dihapus dari tersimpan'),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Disimpan ke daftar'),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menyimpan beasiswa'),
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
                            size: 17,
                          ),
                          label: Text(isSaved ? 'Tersimpan' : 'Simpan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: primary,
                            side: BorderSide(
                              color: primary.withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                      applicationsControllerProvider.notifier,
                                    )
                                    .createApplication(scholarship.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lamaran mulai dilacak'),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                            size: 17,
                          ),
                          label: Text(
                            isTracked ? 'Sedang Dilacak' : 'Lacak Lamaran',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isTracked
                                ? AppTheme.statusSuccess
                                : AppTheme.brandPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPrimaryAction(
                    context,
                    scholarship.applicationUrl,
                    primary,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final primary = AppTheme.primaryOf(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimaryOf(context),
            letterSpacing: -0.3,
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
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: AppTheme.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, RegistrationStatus status) {
    final (String label, Color color, Color textColor) = switch (status) {
      RegistrationStatus.open => (
        'Pendaftaran Dibuka',
        AppTheme.statusSuccess,
        isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
      ),
      RegistrationStatus.closed => (
        'Pendaftaran Ditutup',
        AppTheme.statusDanger,
        isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      ),
      // No deadline stated by the official source: neutral, never "open".
      RegistrationStatus.unknown => (
        'Status pendaftaran belum diketahui',
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              key: const ValueKey('detail-registration-status-badge'),
              style: TextStyle(
                color: textColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRegistrationDates(DateTime? openDate, DateTime? deadline) {
    if (openDate != null && deadline != null) {
      final start = DateFormat('dd MMMM yyyy').format(openDate.toLocal());
      final end = DateFormat('dd MMMM yyyy').format(deadline.toLocal());
      return '$start – $end';
    }
    if (deadline != null) {
      return DateFormat('dd MMMM yyyy').format(deadline.toLocal());
    }
    return 'Batas waktu belum diketahui';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLoginPrompt(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Masuk ke akun untuk melihat analisis kecocokan beasiswa ini dengan profil akademik Anda.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
                height: 1.45,
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
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textSecondary = AppTheme.textSecondaryOf(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor),
        boxShadow: AppTheme.cardShadowOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Kecocokan Profil Anda',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              _buildRelevanceBadge(isDark, match.relevance),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            match.explanation,
            style: TextStyle(fontSize: 13.5, color: textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 14),
          ...match.criterionEvaluations.map(
            (eval) => _buildCriterionRow(context, eval),
          ),
          const SizedBox(height: 14),
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
        color = AppTheme.statusSuccess;
        break;
      case CriterionState.notMatch:
        icon = Icons.cancel_rounded;
        color = AppTheme.statusDanger;
        break;
      case CriterionState.unknown:
      case CriterionState.needsVerification:
        icon = Icons.help_outline_rounded;
        color = AppTheme.brandSecondary;
        break;
      case CriterionState.notApplicable:
        icon = Icons.remove_circle_outline_rounded;
        color = AppTheme.textMutedOf(context);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 9.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              eval.explanation,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryOf(context),
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
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
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.45)
            : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
        text = 'Sangat Relevan';
        break;
      case RelevanceTier.relevan:
        bgColor = isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.45)
            : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        text = 'Relevan';
        break;
      case RelevanceTier.mungkinRelevan:
        bgColor = isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.45)
            : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        text = 'Mungkin Relevan';
        break;
      case RelevanceTier.perluDicek:
        bgColor = isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        text = 'Perlu Dicek';
        break;
      case RelevanceTier.belumCukupInformasi:
        bgColor = isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFE2E8F0);
        textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        text = 'Info Kurang';
        break;
      case RelevanceTier.tidakMemenuhi:
        bgColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
            : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        text = 'Tidak Memenuhi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: textColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
