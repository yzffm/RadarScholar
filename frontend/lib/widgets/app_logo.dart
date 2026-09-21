import 'package:flutter/material.dart';

/// RadarScholar Official Logo Widget.
///
/// Supports two display modes:
/// - [AppLogoMode.full]: Full horizontal lockup (icon + "RadarScholar" text).
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
    this.height = 40,
    this.width,
    this.onTap,
  });

  const AppLogo.icon({
    super.key,
    this.height = 40,
    this.width,
    this.onTap,
  }) : mode = AppLogoMode.iconOnly;

  @override
  Widget build(BuildContext context) {
    final assetPath = mode == AppLogoMode.full
        ? 'assets/images/logo_full.png'
        : 'assets/images/logo_icon.png';

    Widget logoImage = Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback in case asset is not available
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: height ?? 40,
              height: height ?? 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B98),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            if (mode == AppLogoMode.full) ...[
              const SizedBox(width: 8),
              Text(
                'RadarScholar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D3B98),
                    ),
              ),
            ],
          ],
        );
      },
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: logoImage,
      );
    }

    return logoImage;
  }
}
