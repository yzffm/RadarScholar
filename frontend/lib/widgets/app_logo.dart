import 'package:flutter/material.dart';
import '../core/theme.dart';

/// RadarScholar Official Logo Widget.
///
/// Supports two display modes:
/// - [AppLogoMode.full]: Full horizontal lockup (icon + "RadarScholar" typography).
/// - [AppLogoMode.iconOnly]: Square app icon mark only.
enum AppLogoMode { full, iconOnly }

class AppLogo extends StatelessWidget {
  final AppLogoMode mode;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.mode = AppLogoMode.full,
    this.height = 36,
    this.width,
    this.onTap,
  });

  const AppLogo.icon({super.key, this.height = 36, this.width, this.onTap})
    : mode = AppLogoMode.iconOnly;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 36;
    final primaryColor = AppTheme.primaryOf(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Widget iconWidget = Container(
      height: effectiveHeight,
      width: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveHeight * 0.28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveHeight * 0.28),
        child: Image.asset(
          'assets/images/logo_icon.png',
          height: effectiveHeight,
          width: effectiveHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: primaryColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: effectiveHeight * 0.6,
              ),
            );
          },
        ),
      ),
    );

    Widget content;
    if (mode == AppLogoMode.iconOnly) {
      content = iconWidget;
    } else {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Radar',
                      style: TextStyle(
                        fontSize: (effectiveHeight * 0.50).clamp(14, 18),
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Scholar',
                      style: TextStyle(
                        fontSize: (effectiveHeight * 0.50).clamp(14, 18),
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'INTELLIGENCE',
                    style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }
}
