import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/ai_controller.dart';
import '../../../core/theme.dart';

class AiExplanationCard extends ConsumerStatefulWidget {
  final String scholarshipId;

  const AiExplanationCard({super.key, required this.scholarshipId});

  @override
  ConsumerState<AiExplanationCard> createState() => _AiExplanationCardState();
}

class _AiExplanationCardState extends ConsumerState<AiExplanationCard> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryOf(context);
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

    if (!_showExplanation) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              _showExplanation = true;
            });
          },
          icon: const Icon(Icons.auto_awesome_rounded, size: 17),
          label: const Text(
            'Jelaskan dengan AI',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? const Color(0xFF1E1B4B)
                : const Color(0xFFEEF2FF),
            foregroundColor: isDark
                ? const Color(0xFFA5B4FC)
                : const Color(0xFF4338CA),
            elevation: 0,
            side: BorderSide(
              color: isDark
                  ? const Color(0xFF6366F1).withValues(alpha: 0.45)
                  : const Color(0xFFC7D2FE),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      );
    }

    final explanationAsync = ref.watch(
      aiExplanationProvider(widget.scholarshipId),
    );

    final cardBg = isDark ? const Color(0xFF10182E) : const Color(0xFFF5F8FF);
    final borderColor = isDark
        ? primaryColor.withValues(alpha: 0.35)
        : const Color(0xFFBFDBFE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Analisis AI Intelligence',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    _showExplanation = false;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: textMuted,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          explanationAsync.when(
            data: (explanation) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation.summary,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),
                if (explanation.strengths.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Kekuatan Profil:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...explanation.strengths.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF059669),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryOf(context),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (explanation.weaknesses.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Kekurangan / Perlu Ditingkatkan:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...explanation.weaknesses.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFDC2626),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryOf(context),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (explanation.unknowns.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Informasi Kurang / Perlu Verifikasi:',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...explanation.unknowns.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryOf(context),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.statusDanger,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    error.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(
                      color: AppTheme.statusDanger,
                      fontSize: 13,
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
}
