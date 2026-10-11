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
    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);
    final isDark = AppTheme.isDark(context);

    if (!_showExplanation) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              _showExplanation = true;
            });
          },
          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
          label: const Text('Jelaskan dengan AI'),
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
                  ? const Color(0xFF6366F1).withValues(alpha: 0.4)
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

    final cardBg = isDark ? const Color(0xFF121B33) : const Color(0xFFF5F7FF);
    final borderColor = isDark
        ? const Color(0xFF3B82F6).withValues(alpha: 0.35)
        : const Color(0xFFBFDBFE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md + 2),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
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
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: Spacing.sm + 2),
              Text(
                'Analisis AI Intelligence',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: colors.onSurface,
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
                color: colors.onSurfaceVariant,
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
                    color: colors.onSurface,
                    fontSize: 13.5,
                    height: 1.5,
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
                  const SizedBox(height: Spacing.xs),
                  ...explanation.strengths.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF059669),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
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
                  const SizedBox(height: Spacing.xs),
                  ...explanation.weaknesses.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFDC2626),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
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
                  const SizedBox(height: Spacing.xs),
                  ...explanation.unknowns.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
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
                Icon(Icons.error_outline_rounded, color: colors.error),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    error.toString().replaceAll('Exception: ', ''),
                    style: TextStyle(color: colors.error, fontSize: 13),
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
