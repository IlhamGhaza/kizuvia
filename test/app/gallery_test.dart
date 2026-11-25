@Tags(['golden'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/app/theme/app_theme.dart';
import 'package:kizuvia/features/dev/gallery_screen.dart';
import 'package:kizuvia/features/onboarding/presentation/onboarding_screen.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _app(Widget home, ThemeData theme) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      theme: theme,
      locale: const Locale('id'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: home,
    ),
  );
}

void main() {
  void useSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  final variants = <String, ThemeData>{
    'light': AppTheme.light(),
    'dark': AppTheme.dark(),
    'elderly': AppTheme.light(elderly: true),
  };

  for (final e in variants.entries) {
    testWidgets('onboarding golden ${e.key}', (tester) async {
      useSmallPhone(tester);
      await tester.pumpWidget(await _app(const OnboardingScreen(), e.value));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OnboardingScreen),
        matchesGoldenFile('goldens/onboarding_${e.key}.png'),
      );
    });
  }

  testWidgets('gallery golden light', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(
      await _app(const GalleryScreen(), AppTheme.light()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GalleryScreen),
      matchesGoldenFile('goldens/gallery_light.png'),
    );
  });

  testWidgets(
    'onboarding meets a11y guidelines (tap target, label, contrast)',
    (tester) async {
      final handle = tester.ensureSemantics();
      useSmallPhone(tester);
      await tester.pumpWidget(
        await _app(const OnboardingScreen(), AppTheme.light()),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    },
  );
}
