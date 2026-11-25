import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

double ratio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // WCAG AA: 4.5 for text, 3.0 for UI components (docs/00 §3.2).
  void check(String name, Color fg, Color bg, [double min = 4.5]) {
    test('$name >= $min', () {
      expect(ratio(fg, bg), greaterThanOrEqualTo(min));
    });
  }

  group('light', () {
    check('text/background', AppPalette.textPrimary, AppPalette.background);
    check('text/surface', AppPalette.textPrimary, AppPalette.surface);
    check('text2/background', AppPalette.textSecondary, AppPalette.background);
    check('text2/surface', AppPalette.textSecondary, AppPalette.surface);
    check(
      'text2/surface-subtle',
      AppPalette.textSecondary,
      AppPalette.surfaceSubtle,
    );
    check('onPrimary/primary', AppPalette.onPrimary, AppPalette.primary);
    check(
      'onPrimary/primary-dark',
      AppPalette.onPrimary,
      AppPalette.primaryDark,
    );
    check('primary/background', AppPalette.primary, AppPalette.background);
    check('primary/surface', AppPalette.primary, AppPalette.surface);
    check('success/surface', AppPalette.success, AppPalette.surface);
    check('warning/surface', AppPalette.warning, AppPalette.surface);
    check('danger/surface', AppPalette.danger, AppPalette.surface);
    check('info/surface', AppPalette.info, AppPalette.surface);
    check('success/background', AppPalette.success, AppPalette.background);
    check('warning/background', AppPalette.warning, AppPalette.background);
    check('danger/background', AppPalette.danger, AppPalette.background);
    check('text/warning-soft', AppPalette.textPrimary, AppPalette.warningSoft);
    check('text/primary-soft', AppPalette.textPrimary, AppPalette.primarySoft);
    check(
      'primary-dark/primary-soft',
      AppPalette.primaryDark,
      AppPalette.primarySoft,
    );
    check('outline/surface', AppPalette.textSecondary, AppPalette.surface, 3);

    test('warning on warning-soft is below AA: never use it for text', () {
      expect(ratio(AppPalette.warning, AppPalette.warningSoft), lessThan(4.5));
    });
  });

  group('dark', () {
    check(
      'text/background',
      AppPalette.darkTextPrimary,
      AppPalette.darkBackground,
    );
    check('text/surface', AppPalette.darkTextPrimary, AppPalette.darkSurface);
    check(
      'text2/background',
      AppPalette.darkTextSecondary,
      AppPalette.darkBackground,
    );
    check(
      'text2/surface',
      AppPalette.darkTextSecondary,
      AppPalette.darkSurface,
    );
    check(
      'text2/surface-subtle',
      AppPalette.darkTextSecondary,
      AppPalette.darkSurfaceSubtle,
    );
    check(
      'onPrimary/primary',
      AppPalette.darkOnPrimary,
      AppPalette.darkPrimary,
    );
    check(
      'onPrimary/primary-dark',
      AppPalette.darkOnPrimary,
      AppPalette.darkPrimaryDark,
    );
    check(
      'primary/background',
      AppPalette.darkPrimary,
      AppPalette.darkBackground,
    );
    check('primary/surface', AppPalette.darkPrimary, AppPalette.darkSurface);
    check('success/surface', AppPalette.darkSuccess, AppPalette.darkSurface);
    check('warning/surface', AppPalette.darkWarning, AppPalette.darkSurface);
    check('danger/surface', AppPalette.darkDanger, AppPalette.darkSurface);
    check('info/surface', AppPalette.darkInfo, AppPalette.darkSurface);
    check(
      'text/warning-soft',
      AppPalette.darkTextPrimary,
      AppPalette.darkWarningSoft,
    );
    check(
      'warning/warning-soft',
      AppPalette.darkWarning,
      AppPalette.darkWarningSoft,
    );
    check(
      'text/primary-soft',
      AppPalette.darkTextPrimary,
      AppPalette.darkPrimarySoft,
    );
    check(
      'primary/primary-soft',
      AppPalette.darkPrimary,
      AppPalette.darkPrimarySoft,
    );
    check(
      'outline/surface',
      AppPalette.darkTextSecondary,
      AppPalette.darkSurface,
      3,
    );
  });
}
