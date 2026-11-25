import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/notifications/notification_actions.dart';
import 'package:kizuvia/core/notifications/notification_gateway.dart';
import 'package:kizuvia/core/notifications/notification_providers.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/core/notifications/system_settings.dart';
import 'package:kizuvia/features/settings/data/settings_repository.dart';
import 'package:material_ui/material_ui.dart';

/// Debug-only helper for the manual device checklist (docs/04 §8, T1.10).
/// Not shipped in release builds (route registered only when `kDebugMode`),
/// so the labels are not localised.
class AlarmTestScreen extends ConsumerStatefulWidget {
  const AlarmTestScreen({super.key});

  @override
  ConsumerState<AlarmTestScreen> createState() => _AlarmTestScreenState();
}

class _AlarmTestScreenState extends ConsumerState<AlarmTestScreen> {
  static const _checklist = [
    'Alarm berbunyi saat app di-kill (swipe dari recent apps)',
    'Alarm berbunyi setelah reboot',
    'Alarm berbunyi dalam mode hemat daya / Doze',
    'Merek diuji: Xiaomi / Oppo / Vivo / Samsung / Pixel',
    'Ganti zona waktu (WIB -> WITA): jam lokal jadwal tetap',
    'Aksi "Sudah minum" dari lock screen tanpa membuka app',
    'Follow-up +10 menit muncul bila tidak dikonfirmasi',
    'Tunda 10 menit muncul lagi (maks. 3x)',
  ];
  static const _checkPrefix = 'alarm_test_check_';

  String _info = '';
  String _lastAction = '-';
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final service = ref.read(notificationServiceProvider);
    final db = ref.read(appDatabaseProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.reload(); // action handler wrote from another isolate
    final system = ref.read(systemSettingsProvider);
    final rows =
        await (db.select(db.scheduledNotifications)
              ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)])
              ..limit(6))
            .get();
    final total = (await db.select(db.scheduledNotifications).get()).length;
    String tzName;
    try {
      tzName = (await FlutterTimezone.getLocalTimezone()).identifier;
    } on Object {
      tzName = '?';
    }
    final info = [
      'Notifikasi diizinkan: ${await service.notificationsEnabled()}',
      'Alarm tepat waktu diizinkan: ${await service.canScheduleExact()}',
      'Tertunda di OS: ${await service.pendingCount()}',
      'Alarm bisa bunyi saat Jangan Ganggu: ${await system.dndAccessGranted()}',
      'Alarm layar penuh diizinkan: ${await system.fullScreenIntentAllowed()}',
      'Tercatat di database: $total',
      'Zona waktu perangkat: $tzName',
      'Sekarang: ${DateTime.now().toIso8601String()}',
      '',
      '6 alarm terdekat (waktu perangkat | UTC):',
      for (final r in rows)
        '${r.scheduledAt.toLocal().toIso8601String()} | ${r.scheduledAt.toUtc().toIso8601String()}',
    ].join('\n');
    if (!mounted) return;
    setState(() {
      _info = info;
      _lastAction = prefs.getString(testLastActionKey) ?? '-';
    });
  }

  Future<void> _schedule(Duration after) async {
    final now = ref.read(clockProvider).now().toUtc();
    final at = now.add(after);
    await ref
        .read(notificationServiceProvider)
        .schedule(
          PlannedNotification(
            id: notificationIdFor('test', at),
            kind: NotificationKind.doseAlarm,
            at: at,
            title: 'Tes alarm Kizuvia',
            body:
                'Dijadwalkan ${after.inSeconds} detik lalu. Tekan salah satu aksi.',
            payload: testPayload,
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alarm tes dijadwalkan: ${at.toLocal().toIso8601String()}',
        ),
      ),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final prefs = ref.watch(sharedPreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Uji alarm (T1.10)')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(_info, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Aksi terakhir dari notifikasi tes:', style: text.labelMedium),
          Text(_lastAction, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => _schedule(const Duration(seconds: 5)),
            child: const Text('Tes: bunyi 5 detik lagi'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () => _schedule(const Duration(minutes: 1)),
            child: const Text('Tes: bunyi 1 menit lagi'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () => _schedule(const Duration(minutes: 5)),
            child: const Text(
              'Tes: bunyi 5 menit lagi (kill app / kunci layar)',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () async {
              await ref.read(alarmAutoRescheduleProvider.notifier).run();
              await _refresh();
            },
            child: const Text('Jadwalkan ulang semua alarm obat'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _refresh,
            child: const Text('Segarkan status'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Cara uji ganti zona waktu', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '1. Buat obat dengan jam beberapa menit ke depan (zona waktu '
            'jadwal = zona waktu perangkat saat obat dibuat).\n'
            '2. Pengaturan Android > Sistem > Tanggal & waktu: matikan '
            '"Zona waktu otomatis", pilih zona lain (mis. WIB -> WITA).\n'
            '3. Kembali ke sini, tekan "Jadwalkan ulang". Kolom UTC di atas '
            'harus TIDAK berubah: alarm tetap di instan yang sama, jam lokal '
            'perangkat bergeser.',
            style: text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Checklist (docs/04 §8)', style: text.titleMedium),
          for (var i = 0; i < _checklist.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: prefs.getBool('$_checkPrefix$i') ?? false,
              title: Text(_checklist[i]),
              onChanged: (v) async {
                await prefs.setBool('$_checkPrefix$i', v ?? false);
                setState(() => _tick++);
              },
            ),
          Opacity(opacity: 0, child: Text('$_tick')),
        ],
      ),
    );
  }
}
