import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/app/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Builds light, dark and elderly themes. Elderly = same palette, larger type
/// and 64dp buttons (docs/07-UI-FLOW.md §2).
abstract final class AppTheme {
  static ThemeData light({bool elderly = false}) => _build(
    brightness: Brightness.light,
    elderly: elderly,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.primary,
      onPrimary: AppPalette.onPrimary,
      primaryContainer: AppPalette.primarySoft,
      onPrimaryContainer: AppPalette.primaryDark,
      secondary: AppPalette.primaryDark,
      onSecondary: AppPalette.onPrimary,
      error: AppPalette.danger,
      onError: AppPalette.onPrimary,
      surface: AppPalette.surface,
      onSurface: AppPalette.textPrimary,
      onSurfaceVariant: AppPalette.textSecondary,
      surfaceContainerLowest: AppPalette.background,
      surfaceContainerLow: AppPalette.surface,
      surfaceContainer: AppPalette.surfaceSubtle,
      surfaceContainerHighest: AppPalette.surfaceSubtle,
      outline: AppPalette.textSecondary,
      outlineVariant: AppPalette.border,
    ),
    background: AppPalette.background,
    tokens: AppTokens.light,
  );

  static ThemeData dark({bool elderly = false}) => _build(
    brightness: Brightness.dark,
    elderly: elderly,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.darkPrimary,
      onPrimary: AppPalette.darkOnPrimary,
      primaryContainer: AppPalette.darkPrimarySoft,
      onPrimaryContainer: AppPalette.darkPrimary,
      secondary: AppPalette.darkPrimaryDark,
      onSecondary: AppPalette.darkOnPrimary,
      error: AppPalette.darkDanger,
      onError: AppPalette.darkOnPrimary,
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkTextPrimary,
      onSurfaceVariant: AppPalette.darkTextSecondary,
      surfaceContainerLowest: AppPalette.darkBackground,
      surfaceContainerLow: AppPalette.darkSurface,
      surfaceContainer: AppPalette.darkSurfaceSubtle,
      surfaceContainerHighest: AppPalette.darkSurfaceSubtle,
      outline: AppPalette.darkTextSecondary,
      outlineVariant: AppPalette.darkBorder,
    ),
    background: AppPalette.darkBackground,
    tokens: AppTokens.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required bool elderly,
    required ColorScheme scheme,
    required Color background,
    required AppTokens tokens,
  }) {
    final textTheme = AppTypography.textTheme(
      color: scheme.onSurface,
      base: elderly ? AppTypography.elderlyBaseSize : AppTypography.baseSize,
    );
    final buttonHeight = elderly
        ? AppSpacing.elderlyButtonHeight
        : AppSpacing.minTouch;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: elderly ? AppRadius.buttonBorder : AppRadius.cardBorder,
    );
    final buttonSize = Size(AppSpacing.minTouch, buttonHeight);
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: elderly ? AppSpacing.xxl : AppSpacing.xl,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      extensions: [tokens],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: tokens.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: tokens.border, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surface,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.cardBorder,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardBorder,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardBorder,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.cardBorder,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceSubtle,
        selectedColor: tokens.primarySoft,
        side: BorderSide(color: tokens.border),
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: tokens.primarySoft,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
    );
  }
}
