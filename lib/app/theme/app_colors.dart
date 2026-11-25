import 'package:material_ui/material_ui.dart';

/// Raw palette. Widgets must NOT read these directly: use `Theme` / `AppTokens`.
/// Source of truth: docs/00-BRAND-IDENTITY.md §3 (light) and docs/07-UI-FLOW.md §3 (dark).
abstract final class AppPalette {
  // ---- Light ----
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF115E59);
  static const primarySoft = Color(0xFFDCEFEA);
  static const background = Color(0xFFF7F7F2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF0F4F1);
  static const textPrimary = Color(0xFF243B38);
  static const textSecondary = Color(0xFF526561);
  static const border = Color(0xFFD8E2DE);
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const danger = Color(0xFFB91C1C);
  static const info = Color(0xFF1D4ED8);
  static const warningSoft = Color(0xFFFBEFD9);
  static const onPrimary = Color(0xFFFFFFFF);

  // ---- Dark ----
  static const darkPrimary = Color(0xFF5BC0B3);
  static const darkPrimaryDark = Color(0xFF3FA89B);
  static const darkPrimarySoft = Color(0xFF1F3B37);
  static const darkBackground = Color(0xFF121D1B);
  static const darkSurface = Color(0xFF1A2927);
  static const darkSurfaceSubtle = Color(0xFF223532);
  static const darkTextPrimary = Color(0xFFE8F1EE);
  static const darkTextSecondary = Color(0xFFAFC2BD);
  static const darkBorder = Color(0xFF36514C);
  static const darkSuccess = Color(0xFF6FCF8E);
  static const darkWarning = Color(0xFFF2A65A);
  static const darkDanger = Color(0xFFF28B82);
  static const darkInfo = Color(0xFF8AB4FF);
  static const darkWarningSoft = Color(0xFF3A2E17);
  static const darkOnPrimary = Color(0xFF08201D);
}

/// Custom tokens that `ColorScheme` has no slot for. Access: `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.primaryDark,
    required this.primarySoft,
    required this.surfaceSubtle,
    required this.border,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.warningSoft,
  });

  final Color primaryDark;
  final Color primarySoft;
  final Color surfaceSubtle;
  final Color border;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  /// Background for fields that need review (e.g. scan result).
  /// Text on it must use the default foreground, not [warning] (contrast 4.41).
  final Color warningSoft;

  static const light = AppTokens(
    primaryDark: AppPalette.primaryDark,
    primarySoft: AppPalette.primarySoft,
    surfaceSubtle: AppPalette.surfaceSubtle,
    border: AppPalette.border,
    textSecondary: AppPalette.textSecondary,
    success: AppPalette.success,
    warning: AppPalette.warning,
    danger: AppPalette.danger,
    info: AppPalette.info,
    warningSoft: AppPalette.warningSoft,
  );

  static const dark = AppTokens(
    primaryDark: AppPalette.darkPrimaryDark,
    primarySoft: AppPalette.darkPrimarySoft,
    surfaceSubtle: AppPalette.darkSurfaceSubtle,
    border: AppPalette.darkBorder,
    textSecondary: AppPalette.darkTextSecondary,
    success: AppPalette.darkSuccess,
    warning: AppPalette.darkWarning,
    danger: AppPalette.darkDanger,
    info: AppPalette.darkInfo,
    warningSoft: AppPalette.darkWarningSoft,
  );

  @override
  AppTokens copyWith({
    Color? primaryDark,
    Color? primarySoft,
    Color? surfaceSubtle,
    Color? border,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? warningSoft,
  }) => AppTokens(
    primaryDark: primaryDark ?? this.primaryDark,
    primarySoft: primarySoft ?? this.primarySoft,
    surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
    border: border ?? this.border,
    textSecondary: textSecondary ?? this.textSecondary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    info: info ?? this.info,
    warningSoft: warningSoft ?? this.warningSoft,
  );

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
