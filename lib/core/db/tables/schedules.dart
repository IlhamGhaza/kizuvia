import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/tables/common.dart';
import 'package:kizuvia/core/db/tables/medications.dart';

@DataClassName('ScheduleRow')
class Schedules extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();

  /// Local times as `HH:mm`.
  TextColumn get times => text().map(const StringListConverter())();

  /// ISO weekday, 1 = Monday.
  TextColumn get daysOfWeek => text()
      .map(const IntListConverter())
      .withDefault(const Constant('[1,2,3,4,5,6,7]'))();
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Jakarta'))();
  IntColumn get graceMinutes => integer().withDefault(const Constant(30))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
