import 'package:flutter/material.dart';
import '../core/theme.dart';

/// RadarScholar Official Logo Widget — Modern SaaS Lockup.
///
/// Supports two display modes:
/// - [AppLogoMode.full]: Full horizontal lockup (icon + "RadarScholar" typography + badge).
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
    final isDark = AppTheme.isDark(context);
    final onSurface = AppTheme.textPrimaryOf(context);

    final Widget iconWidget = Container(
      height: effectiveHeight,
      width: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveHeight * 0.28),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.28 : 0.16),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveHeight * 0.26),
        child: Image.asset(
          'assets/images/logo_icon.png',
          height: effectiveHeight,
          width: effectiveHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.radar_rounded,
                color: Colors.white,
                size: effectiveHeight * 0.56,
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
            const SizedBox(width: 10),
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
                        fontSize: (effectiveHeight * 0.48).clamp(15, 19),
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'Scholar',
                      style: TextStyle(
                        fontSize: (effectiveHeight * 0.48).clamp(15, 19),
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.22),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'INTELLIGENCE',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
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
