import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Standardized error state widget for RadarScholar — Modern SaaS Aesthetic.
///
/// Follows UI/UX (§18) and Error Handling (§20) rules.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final dangerColor = AppTheme.statusDanger;
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: dangerColor.withValues(alpha: isDark ? 0.3 : 0.25),
              ),
              boxShadow: AppTheme.cardShadowOf(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: dangerColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(icon, size: 28, color: dangerColor),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: Spacing.xs + 2),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMutedOf(context),
                    height: 1.55,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: Spacing.lg),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: Text(retryLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimaryOf(context),
                      backgroundColor: AppTheme.surfaceElevatedOf(context),
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
