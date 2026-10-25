import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Shared "Continue with Google" button used by the Login and Register pages.
///
/// Presentation only — the OAuth flow itself lives in the auth controller (CPMK 4).
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  /// Button text, e.g. "Masuk dengan Google".
  final String label;

  /// Null disables the button (e.g. while loading).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final elevatedBg = AppTheme.surfaceElevatedOf(context);
    final borderStrong = AppTheme.borderStrongOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderStrong, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          backgroundColor: elevatedBg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEA4335),
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

