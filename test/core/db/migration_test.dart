import 'package:drift/drift.dart'
    show OpeningDetails, QueryExecutor, QueryExecutorUser;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/db/app_database.dart';

import 'generated/schema.dart';

/// Re-run `dart run drift_dev schema dump lib/core/db/app_database.dart drift_schemas/`
/// and `dart run drift_dev schema generate drift_schemas/ test/core/db/generated/`
/// whenever schemaVersion changes, then add a `from(N)To(N+1)` case here.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('fresh v2 database matches the dumped schema', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  test('v1 -> v2 adds medications.photo_remote_path and keeps data', () async {
    final schema = await verifier.schemaAt(1);
    final old = schema.newConnection();
    await old.ensureOpen(_NoUser());
    await old.runCustom(
      'INSERT INTO patients (id, name, updated_at, deleted_at, sync_status, local_updated_at, conditions) '
      "VALUES ('p1', 'Budi', 1, NULL, 'pending', 1, '[]')",
    );
    await old.close();

    final connection = schema.newConnection();
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
    expect(await db.select(db.patients).get(), hasLength(1));
  });
}

class _NoUser implements QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
