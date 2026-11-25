import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kizuvia/core/utils/device_l10n.dart';
import 'package:kizuvia/features/dose_log/data/dose_providers.dart';
import 'package:kizuvia/features/home/presentation/elderly_home.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';

/// Pushes the next dose to the Android home-screen widget (T3.4).
/// Honors the lock-screen privacy setting: no medicine name then.
/// shortcut: updates only while the app process runs (minute tick, data
/// changes, resume); the OS also refreshes every 30 min from the last text.
/// Upgrade with WorkManager if widgets go stale in practice.
final homeWidgetSyncProvider = Provider<void>((ref) {
  final doses = ref.watch(todayDosesProvider).value;
  final privacy = ref.watch(
    settingsControllerProvider.select((s) => s.privacyLockScreen),
  );
  if (doses == null) return;
  final l10n = deviceL10n();
  final next = nextDose(doses);
  String two(int n) => n.toString().padLeft(2, '0');
  final String title;
  final String body;
  if (next == null) {
    title = l10n.widgetNone;
    body = '';
  } else {
    final t = next.at.toLocal();
    title = l10n.widgetNext('${two(t.hour)}:${two(t.minute)}');
    final m = next.context.medication;
    body = privacy
        ? l10n.widgetPrivateBody
        : '${next.context.patientName}: '
              '${[m.name, if (m.strength != null) m.strength!].join(' ')}';
  }
  _push(title, body);
});

Future<void> _push(String title, String body) async {
  try {
    await HomeWidget.saveWidgetData<String>('title', title);
    await HomeWidget.saveWidgetData<String>('body', body);
    await HomeWidget.updateWidget(androidName: 'NextDoseWidgetProvider');
  } on Object {
    // No widget host (tests, iOS): ignore. Never log the content.
  }
}
