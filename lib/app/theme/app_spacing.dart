/// Spacing scale: multiples of 4 (docs/07-UI-FLOW.md §3).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Minimum touch target (docs/07-UI-FLOW.md §3).
  static const double minTouch = 48;

  /// Minimum button height in elderly mode (docs/07-UI-FLOW.md §2).
  static const double elderlyButtonHeight = 64;
}
