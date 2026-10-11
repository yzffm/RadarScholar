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
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
