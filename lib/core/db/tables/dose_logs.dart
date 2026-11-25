import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/tables/common.dart';
import 'package:kizuvia/core/db/tables/patients.dart';
import 'package:kizuvia/core/db/tables/schedules.dart';

/// Append-only (docs/05-SYNC.md). No `deleted_at`; effective status is computed.
@DataClassName('DoseLogRow')
class DoseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get scheduleId =>
      text().references(Schedules, #id, onDelete: KeyAction.cascade)();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => textEnum<DoseStatus>()();
  TextColumn get confirmedBy => text().nullable()();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  TextColumn get source =>
      textEnum<DoseSource>().withDefault(Constant(DoseSource.device.name))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus =>
      textEnum<SyncStatus>().withDefault(Constant(SyncStatus.pending.name))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {scheduleId, scheduledAt, status},
  ];
}
