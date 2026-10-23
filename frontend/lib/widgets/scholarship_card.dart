import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/scholarship_status.dart';
import '../core/theme.dart';
import '../models/scholarship.dart';

class ScholarshipCard extends StatefulWidget {
  const ScholarshipCard({super.key, required this.scholarship});

  final Scholarship scholarship;

  @override
  State<ScholarshipCard> createState() => _ScholarshipCardState();
}

class _ScholarshipCardState extends State<ScholarshipCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scholarship = widget.scholarship;
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = _isHovered
        ? AppTheme.cardHoverColorOf(context)
        : AppTheme.cardColorOf(context);
    final borderColor = _isHovered
        ? primaryColor.withValues(alpha: isDark ? 0.45 : 0.35)
        : AppTheme.borderColorOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);

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
          border: Border.all(color: borderColor, width: 1),
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
            splashColor: primaryColor.withValues(alpha: 0.06),
            highlightColor: primaryColor.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Provider Icon, Eyebrow, Title & Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withValues(
                                alpha: isDark ? 0.22 : 0.12,
                              ),
                              primaryColor.withValues(
                                alpha: isDark ? 0.08 : 0.04,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(
                              alpha: isDark ? 0.3 : 0.2,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_rounded,
                                  size: 12,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scholarship.title,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.3,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary / Description
                  Text(
                    scholarship.summary.isNotEmpty
                        ? scholarship.summary
                        : scholarship.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textMuted,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // Registration status & data freshness. A Wrap keeps the
                  // longer neutral/stale labels readable on narrow screens.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildStatusBadge(context),
                      _buildFreshnessLabel(context),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hairline Divider
                  Container(
                    height: 1,
                    color: AppTheme.borderColorOf(
                      context,
                    ).withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 12),

                  // Footer: Deadline Pill & Action CTA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevatedOf(context),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppTheme.borderColorOf(context),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDateRange(
                                scholarship.openDate,
                                scholarship.deadline,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryOf(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? primaryColor.withValues(
                                  alpha: isDark ? 0.18 : 0.1,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: primaryColor,
                            ),
                          ],
                        ),
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

  Widget _buildFreshnessLabel(BuildContext context) {
    final info = verificationInfoOf(widget.scholarship);
    final isDark = AppTheme.isDark(context);

    final okColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final warnColor = isDark
        ? const Color(0xFFFBBF24)
        : const Color(0xFFD97706);
    final color = info.isLiveChecked && !info.isStale ? okColor : warnColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.07),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  info.label,
                  key: const ValueKey('freshness-label'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (info.staleWarning != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 13, color: warnColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  info.staleWarning!,
                  key: const ValueKey('freshness-stale-warning'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: warnColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Registration status badge. A scholarship whose official source states no
  /// deadline gets a neutral badge; it is never shown as "Aktif".
  Widget _buildStatusBadge(BuildContext context) {
    final status = registrationStatusOf(widget.scholarship);
    final isDark = AppTheme.isDark(context);

    final (String label, Color bgColor, Color textColor) = switch (status) {
      RegistrationStatus.open => (
        'Aktif',
        isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.45)
            : const Color(0xFFDCFCE7),
        isDark ? const Color(0xFF34D399) : const Color(0xFF15803D),
      ),
      RegistrationStatus.closed => (
        'Tidak Aktif',
        isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
            : const Color(0xFFFEE2E2),
        isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
      ),
      RegistrationStatus.unknown => (
        'Status pendaftaran belum diketahui',
        isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              key: const ValueKey('registration-status-badge'),
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? openDate, DateTime? deadline) {
    if (openDate != null && deadline != null) {
      final start = DateFormat('dd MMM').format(openDate.toLocal());
      final end = DateFormat('dd MMM yyyy').format(deadline.toLocal());
      return '$start – $end';
    }
    if (deadline != null) {
      return 'Ditutup: ${DateFormat('dd MMM yyyy').format(deadline.toLocal())}';
    }
    return 'Batas waktu belum diketahui';
  }
}
