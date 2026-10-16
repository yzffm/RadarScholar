import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/scholarship.dart';
import '../models/match_result.dart';

class MatchedScholarshipCard extends StatefulWidget {
  const MatchedScholarshipCard({super.key, required this.matchedScholarship});

  final MatchedScholarshipResponse matchedScholarship;

  @override
  State<MatchedScholarshipCard> createState() => _MatchedScholarshipCardState();
}

class _MatchedScholarshipCardState extends State<MatchedScholarshipCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scholarship = widget.matchedScholarship.scholarship;
    final match = widget.matchedScholarship.match;

    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final relevanceColor = _getRelevanceColor(match.relevance);
    final cardBg = _isHovered
        ? AppTheme.cardHoverColorOf(context)
        : AppTheme.cardColorOf(context);
    final borderColor = _isHovered
        ? relevanceColor.withValues(alpha: isDark ? 0.6 : 0.5)
        : relevanceColor.withValues(alpha: isDark ? 0.32 : 0.35);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: Spacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: AppTheme.cardShadowOf(context, isHovered: _isHovered),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () {
              context.push('/scholarships/${scholarship.id}');
            },
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: relevanceColor.withValues(
                            alpha: isDark ? 0.16 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: relevanceColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.radar_rounded,
                          size: 20,
                          color: relevanceColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scholarship.source?.providerName ??
                                  'Penyedia Belum Tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                                letterSpacing: 0.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scholarship.title,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimaryOf(context),
                                letterSpacing: -0.3,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildRelevanceBadge(context, match.relevance),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    match.explanation,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMutedOf(context),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: AppTheme.borderColorOf(
                      context,
                    ).withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.statusSuccess.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppTheme.statusSuccess.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppTheme.statusSuccess,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${match.matchedCount} Memenuhi',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.statusSuccess,
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
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.statusDanger.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppTheme.statusDanger.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cancel_outlined,
                                size: 14,
                                color: AppTheme.statusDanger,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${match.notMatchedCount} Tidak',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.statusDanger,
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
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Color _getRelevanceColor(RelevanceTier relevance) {
    switch (relevance) {
      case RelevanceTier.sangatRelevan:
        return AppTheme.statusSuccess;
      case RelevanceTier.relevan:
        return AppTheme.darkPrimary;
      case RelevanceTier.mungkinRelevan:
        return AppTheme.brandSecondary;
      case RelevanceTier.perluDicek:
        return const Color(0xFF94A3B8);
      case RelevanceTier.belumCukupInformasi:
        return const Color(0xFF64748B);
      case RelevanceTier.tidakMemenuhi:
        return AppTheme.statusDanger;
    }
  }
}
