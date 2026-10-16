import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Standardized empty state widget for RadarScholar — Modern SaaS Aesthetic.
///
/// Follows UI/UX rules (§18) for representing empty or initial states cleanly.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIllustration;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final primaryColor = AppTheme.primaryOf(context);
    final cardBg = AppTheme.cardColorOf(context);
    final borderColor = AppTheme.borderColorOf(context);

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.xl + 4,
              ),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: isDark ? 0.65 : 0.9),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: borderColor),
                boxShadow: AppTheme.cardShadowOf(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (customIllustration != null)
                    customIllustration!
                  else
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withValues(
                                  alpha: isDark ? 0.22 : 0.14,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevatedOf(context),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: AppTheme.glowShadowOf(
                              primaryColor,
                              intensity: isDark ? 0.2 : 0.1,
                            ),
                          ),
                          child: Icon(icon, size: 26, color: primaryColor),
                        ),
                      ],
                    ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(context),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMutedOf(context),
                      height: 1.55,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: Spacing.lg),
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        actionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.brandPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
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
      ),
    );
  }
}
