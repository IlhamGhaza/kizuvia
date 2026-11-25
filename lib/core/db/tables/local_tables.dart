import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/tables/common.dart';

/// Local-only tables (never synced): docs/03-DATABASE.md §5.

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  TextColumn get op => textEnum<SyncOp>()();
  TextColumn get payloadJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Maps OS notification ids to occurrences so they can be cancelled/rescheduled.
class ScheduledNotifications extends Table {
  IntColumn get notificationId => integer()();
  TextColumn get scheduleId => text()();
  DateTimeColumn get scheduledAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {notificationId};
}

class SyncCursor extends Table {
  TextColumn get targetTable => text()();
  DateTimeColumn get lastPulledAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {targetTable};
}
