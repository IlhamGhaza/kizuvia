import 'package:material_ui/material_ui.dart';

/// Plus Jakarta Sans, bundled as asset (offline-first). Weight >= 400.
abstract final class AppTypography {
  static const fontFamily = 'PlusJakartaSans';

  /// Base body size. Elderly mode uses 22sp (docs/07-UI-FLOW.md §2).
  static const double baseSize = 16;
  static const double elderlyBaseSize = 22;

  static TextTheme textTheme({required Color color, double base = baseSize}) {
    final k = base / baseSize;
    TextStyle s(double size, FontWeight w, {double h = 1.4}) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size * k,
      fontWeight: w,
      height: h,
      color: color,
    );
    return TextTheme(
      displaySmall: s(32, FontWeight.w700, h: 1.25),
      headlineMedium: s(28, FontWeight.w700, h: 1.3),
      headlineSmall: s(24, FontWeight.w700, h: 1.3),
      titleLarge: s(20, FontWeight.w600, h: 1.3),
      titleMedium: s(16, FontWeight.w600),
      titleSmall: s(14, FontWeight.w600),
      bodyLarge: s(16, FontWeight.w400, h: 1.5),
      bodyMedium: s(14, FontWeight.w400, h: 1.5),
      bodySmall: s(12, FontWeight.w400),
      labelLarge: s(16, FontWeight.w600),
      labelMedium: s(14, FontWeight.w500),
      labelSmall: s(12, FontWeight.w500),
    );
  }
}
