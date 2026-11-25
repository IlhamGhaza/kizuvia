import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/tables/common.dart';

@DataClassName('PatientRow')
class Patients extends Table with SyncColumns {
  TextColumn get id => text()();

  /// Null while the data is only local (no account yet).
  TextColumn get familyId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get birthYear => integer().nullable()();
  TextColumn get conditions => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
