import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Standardized loading state widget for RadarScholar.
///
/// Follows UI/UX rules (§18) for consistent async loading feedback.
class LoadingState extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingState({super.key, this.message, this.size = 36.0});

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.primaryOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size + 24,
              height: size + 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.cardColorOf(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppTheme.borderColorOf(context)),
                boxShadow: AppTheme.cardShadowOf(context),
              ),
              child: SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMutedOf(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
