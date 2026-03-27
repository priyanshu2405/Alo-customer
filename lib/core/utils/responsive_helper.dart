import 'package:flutter/material.dart';

/// Breakpoints and responsive helpers for mobile, tablet, and iPad.
class AppResponsive {
  AppResponsive._();

  // ── Breakpoints ──────────────────────────────────────────────────────────
  static const double _tabletBreakpoint = 600.0;
  static const double _largeTabletBreakpoint = 900.0;

  // ── Device checks ────────────────────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletBreakpoint &&
      MediaQuery.sizeOf(context).width < _largeTabletBreakpoint;

  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _largeTabletBreakpoint;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletBreakpoint;

  // ── Max content width for forms / lists ──────────────────────────────────
  /// Returns the maximum width for centered form/content on tablets and iPads.
  /// On mobile returns the full screen width so nothing changes.
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 700.0; // iPad Pro 12.9" landscape
    if (w >= 1024) return 660.0; // iPad Pro 12.9" portrait / landscape
    if (w >= 900)  return 620.0; // iPad Pro 11" / iPad Air
    if (w >= 768)  return 560.0; // iPad mini / iPad regular
    if (w >= 600)  return 480.0; // Large phone / small tablet
    return w;                    // Mobile – full width, no change
  }

  // ── Responsive value selector ─────────────────────────────────────────────
  /// Returns the appropriate value for the current screen size.
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? largeTablet,
  }) {
    if (isLargeTablet(context)) return largeTablet ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  // ── Horizontal screen padding ─────────────────────────────────────────────
  static double horizontalPadding(BuildContext context) {
    if (isTabletOrLarger(context)) return 24.0;
    return 20.0;
  }

  // ── Responsive font scale multiplier ─────────────────────────────────────
  static double fontScaleFactor(BuildContext context) {
    if (isLargeTablet(context)) return 1.1;
    if (isTablet(context)) return 1.05;
    return 1.0;
  }

  // ── Responsive font size ──────────────────────────────────────────────────
  /// Returns a font size scaled for the current screen category.
  /// Mobile → raw size; tablet → ×1.05; large tablet → ×1.1.
  static double sp(BuildContext context, double size) =>
      size * fontScaleFactor(context);
}

// ─────────────────────────────────────────────────────────────────────────────
/// Wraps [child] in a centered, max-width [ConstrainedBox] on tablets/iPads.
/// On mobile the [child] is returned unchanged so existing layout is preserved.
///
/// Usage – body:
///   body: ResponsiveCenter(child: SingleChildScrollView(...))
///
/// Usage – bottomNavigationBar:
///   bottomNavigationBar: ResponsiveCenter(child: Padding(...))
// ─────────────────────────────────────────────────────────────────────────────
class ResponsiveCenter extends StatelessWidget {
  final Widget child;

  /// Override the default max-width calculated from [AppResponsive.contentMaxWidth].
  final double? maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    if (AppResponsive.isMobile(context)) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppResponsive.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
