import 'package:drift/drift.dart';
import 'package:kizuvia/core/db/tables/common.dart';
import 'package:kizuvia/core/db/tables/patients.dart';

@DataClassName('MedicationRow')
class Medications extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get strength => text().nullable()();
  TextColumn get form => text().nullable().customConstraint(
    "NULL CHECK (form IN ('tablet','kapsul','sirup','tetes','salep','injeksi','inhaler','lainnya'))",
  )();
  TextColumn get instructions => text().nullable()();
  TextColumn get mealRelation => text().nullable().customConstraint(
    "NULL CHECK (meal_relation IN ('sebelum_makan','sesudah_makan','bersama_makan','bebas'))",
  )();
  TextColumn get prescribedBy => text().nullable()();
  RealColumn get stockQty => real().nullable()();
  RealColumn get doseQty => real().withDefault(const Constant(1))();
  IntColumn get refillThresholdDays =>
      integer().withDefault(const Constant(3))();

  /// Local file (compressed JPEG on this device).
  TextColumn get photoPath => text().nullable()();

  /// Key in the private `medication-photos` bucket once uploaded
  /// (`{family}/{patient}/{medication}/{uuid}.jpg`). Synced as `photo_path`.
  TextColumn get photoRemotePath => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();

  /// "Bila perlu": no alarm.
  BoolColumn get isPrn => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
