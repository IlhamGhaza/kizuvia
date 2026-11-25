import 'dart:ui';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:material_ui/material_ui.dart' show Size, TextFormField;

import '../app/app_test.dart'
    show FakeNotificationService, appScope, settle, unmount;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('add patient, then medication with schedule', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('id')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    // Tall viewport so the whole (lazy) form is built and tappable.
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final notifications = FakeNotificationService();
    await tester.pumpWidget(
      await appScope(
        notifications: notifications,
        prefs: {SettingsKeys.onboardingDone: true},
      ),
    );
    await settle(tester);

    await tester.tap(find.text('Pasien'));
    await settle(tester);
    expect(find.text('Belum ada pasien'), findsOneWidget);

    // Validation: blank name is rejected with a helpful message.
    await tester.tap(find.text('Tambah pasien'));
    await settle(tester);
    await tester.tap(find.text('Simpan'));
    await settle(tester);
    expect(find.text('Periksa kembali nama'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Budi');
    await tester.tap(find.text('Simpan'));
    await settle(tester);
    expect(find.text('Budi'), findsOneWidget);

    await tester.tap(find.text('Budi'));
    await settle(tester);
    expect(find.text('Belum ada obat'), findsOneWidget);

    await tester.tap(find.text('Tambah obat').first);
    await settle(tester);
    await tester.tap(find.text('Simpan'));
    await settle(tester);
    expect(find.text('Periksa kembali nama obat'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Amlodipine');
    await tester.enterText(find.byType(TextFormField).at(1), '10 mg');
    await tester.tap(find.text('Simpan'));
    await settle(tester);

    // Summary must be confirmed before saving (risk table, docs/10).
    expect(find.text('Periksa sebelum menyimpan'), findsOneWidget);
    await tester.tap(find.text('Simpan').last);
    await settle(tester);

    expect(find.text('Amlodipine 10 mg'), findsOneWidget);
    expect(find.text('Jam 08:00'), findsOneWidget);
    // Saving a schedule plans OS alarms without any network (safety rule 4).
    expect(notifications.scheduled, isNotEmpty);
    await unmount(tester);
  });
}
