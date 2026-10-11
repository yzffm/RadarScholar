import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/scholarship.dart';
import '../models/match_result.dart';

class MatchedScholarshipCard extends StatelessWidget {
  const MatchedScholarshipCard({super.key, required this.matchedScholarship});

  final MatchedScholarshipResponse matchedScholarship;

  @override
  Widget build(BuildContext context) {
    final scholarship = matchedScholarship.scholarship;
    final match = matchedScholarship.match;

    final colors = Theme.of(context).colorScheme;
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = _getRelevanceColor(
      match.relevance,
    ).withValues(alpha: AppTheme.isDark(context) ? 0.35 : 0.45);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: 1.5),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            context.push('/scholarships/${scholarship.id}');
          },
          hoverColor: primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scholarship.source?.providerName ??
                                'Penyedia Belum Tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            scholarship.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              letterSpacing: -0.2,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRelevanceBadge(context, match.relevance),
                  ],
                ),
                const SizedBox(height: Spacing.sm + 4),
                Text(
                  match.explanation,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.md),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.borderColorOf(context).withValues(alpha: 0.5),
                ),
                const SizedBox(height: Spacing.sm + 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${match.matchedCount} Memenuhi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (match.notMatchedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF87171,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              size: 14,
                              color: Color(0xFFF87171),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${match.notMatchedCount} Tidak',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF87171),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelevanceBadge(BuildContext context, RelevanceTier relevance) {
    final isDark = AppTheme.isDark(context);
    Color bgColor;
    Color textColor;
    String text;

    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF34D399) : const Color(0xFF15803D);
        text = 'Sangat Relevan';
        break;
      case RelevanceTier.relevan:
        bgColor = isDark
            ? const Color(0xFF0C4A6E).withValues(alpha: 0.4)
            : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        text = 'Relevan';
        break;
      case RelevanceTier.mungkinRelevan:
        bgColor = isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.4)
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
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
            : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        text = 'Tidak Memenuhi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _getRelevanceColor(RelevanceTier relevance) {
    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        return const Color(0xFF10B981);
      case RelevanceTier.relevan:
        return const Color(0xFF38BDF8);
      case RelevanceTier.mungkinRelevan:
        return const Color(0xFFF59E0B);
      case RelevanceTier.perluDicek:
        return const Color(0xFF94A3B8);
      case RelevanceTier.belumCukupInformasi:
        return const Color(0xFF64748B);
      case RelevanceTier.tidakMemenuhi:
        return const Color(0xFFEF4444);
    }
  }
}
