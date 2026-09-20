import 'package:flutter/material.dart';

import '../core/responsive.dart';

/// A responsive layout widget that renders different builders
/// based on screen width.
///
/// Supports CPMK 2 — Responsive UI requirement.
///
/// Example:
/// ```dart
/// ResponsiveLayout(
///   mobile: (context) => MobileView(),
///   tablet: (context) => TabletView(),
///   desktop: (context) => DesktopView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Builder for mobile layout (< 600px).
  final WidgetBuilder mobile;

  /// Builder for tablet layout (600px – 1024px).
  /// Falls back to [mobile] if not provided.
  final WidgetBuilder? tablet;

  /// Builder for desktop layout (> 1024px).
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);

        switch (deviceType) {
          case DeviceType.desktop:
            return desktop(context);
          case DeviceType.tablet:
            return (tablet ?? mobile)(context);
          case DeviceType.mobile:
            return mobile(context);
        }
      },
    );
  }
}
