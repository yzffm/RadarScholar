/// Responsive breakpoints and utilities for RadarScholar.
///
/// Supports CPMK 2 — Responsive UI requirement.
/// Provides consistent breakpoints for desktop, tablet, and mobile layouts.
class Breakpoints {
  Breakpoints._();

  /// Mobile: < 600px
  static const double mobile = 600;

  /// Tablet: 600px – 1024px
  static const double tablet = 1024;

  // Desktop: > 1024px (implicit)
}

/// Determines the current device category based on screen width.
enum DeviceType { mobile, tablet, desktop }

/// Returns the [DeviceType] for the given [width].
DeviceType getDeviceType(double width) {
  if (width < Breakpoints.mobile) return DeviceType.mobile;
  if (width < Breakpoints.tablet) return DeviceType.tablet;
  return DeviceType.desktop;
}

/// Helper class for responsive checks across widgets.
class Responsive {
  Responsive._();

  static DeviceType getDeviceType(double width) {
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(double width) => width < Breakpoints.mobile;
  static bool isTablet(double width) =>
      width >= Breakpoints.mobile && width < Breakpoints.tablet;
  static bool isDesktop(double width) => width >= Breakpoints.tablet;
}
