import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/db_encryption.dart';
import 'package:kizuvia/core/db/tables/common.dart';
import 'package:kizuvia/core/db/tables/dose_logs.dart';
import 'package:kizuvia/core/db/tables/local_tables.dart';
import 'package:kizuvia/core/db/tables/medications.dart';
import 'package:kizuvia/core/db/tables/patients.dart';
import 'package:kizuvia/core/db/tables/schedules.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Patients,
    Medications,
    Schedules,
    DoseLogs,
    SyncQueue,
    ScheduledNotifications,
    SyncCursor,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        // Encrypted (SQLCipher) and shared with the notification-action
        // background isolate.
        executor ?? openEncryptedConnection(),
      );

  /// Bump on every schema change and add a step in [migration]
  /// (docs/03-DATABASE.md §5).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(medications, medications.photoRemotePath);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
