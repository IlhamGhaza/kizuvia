import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/sync/photo_sync.dart';
import 'package:kizuvia/core/sync/sync_engine.dart';
import 'package:kizuvia/core/sync/sync_remote.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/features/patients/domain/patient.dart';

import 'sync_engine_test.dart' show FakeSyncRemote;

class FakeStorage implements PhotoStorage {
  final Map<String, Uint8List> objects = {};
  bool reject = false;
  bool offline = false;

  @override
  Future<void> upload(String key, Uint8List bytes) async {
    if (offline) throw const SyncNetworkException();
    if (reject) throw const SyncRejectedException('413');
    objects[key] = bytes;
  }

  @override
  Future<Uint8List> download(String key) async {
    if (offline) throw const SyncNetworkException();
    final b = objects[key];
    if (b == null) throw const SyncRejectedException('404');
    return b;
  }
}

class FakeFiles implements PhotoFiles {
  final Map<String, Uint8List> files = {};
  int saved = 0;

  @override
  Future<Uint8List?> read(String path) async => files[path];

  @override
  Future<String> save(Uint8List bytes) async {
    final path = '/cache/${saved++}.jpg';
    files[path] = bytes;
    return path;
  }
}

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late FakeSyncRemote remote;
  late FakeStorage storage;
  late FakeFiles files;
  late SyncEngine engine;
  late PatientRepository patients;
  late MedicationRepository meds;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 3, 2, 1));
    remote = FakeSyncRemote(clock);
    storage = FakeStorage();
    files = FakeFiles();
    engine = SyncEngine(
      db: db,
      remote: remote,
      clock: clock,
      photos: PhotoSync(db: db, storage: storage, files: files, clock: clock),
    );
    meds = MedicationRepository(db, clock);
  });
  tearDown(() => db.close());

  Future<MedicationWithSchedule> addMed({
    required String? family,
    String? photo,
  }) async {
    patients = PatientRepository(db, clock, currentFamilyId: () => family);
    final p = (await patients.save(const Patient(id: '', name: 'Budi')))
        .valueOrNull!;
    return (await meds.save(
      Medication(
        id: '',
        patientId: p.id,
        name: 'Amlodipine',
        startDate: DateTime.utc(2026, 3, 1),
        photoPath: photo,
      ),
      const MedSchedule(id: '', medicationId: '', times: ['07:00']),
    )).valueOrNull!;
  }

  test(
    'uploads the local photo under the family path and syncs photo_path',
    () async {
      files.files['/local/a.jpg'] = Uint8List.fromList([1, 2, 3]);
      final m = await addMed(family: 'fam-1', photo: '/local/a.jpg');
      await engine.syncOnce();

      final key = storage.objects.keys.single;
      expect(
        key,
        startsWith('fam-1/${m.medication.patientId}/${m.medication.id}/'),
      );
      expect(key, endsWith('.jpg'));
      expect(storage.objects[key], [1, 2, 3]);

      final row = await db.select(db.medications).getSingle();
      expect(row.photoRemotePath, key);
      expect(row.photoPath, '/local/a.jpg');
      expect(row.syncStatus.name, 'synced');
      // The server stores the bucket key, never the device path.
      expect(remote.table('medications')[m.medication.id]!['photo_path'], key);
    },
  );

  test('no family yet -> nothing uploaded', () async {
    files.files['/local/a.jpg'] = Uint8List.fromList([1]);
    await addMed(family: null, photo: '/local/a.jpg');
    await db.delete(db.syncQueue).go();
    await engine.syncOnce();
    expect(storage.objects, isEmpty);
  });

  test('upload is not repeated on later syncs', () async {
    files.files['/local/a.jpg'] = Uint8List.fromList([1]);
    await addMed(family: 'fam-1', photo: '/local/a.jpg');
    await engine.syncOnce();
    await engine.syncOnce();
    expect(storage.objects, hasLength(1));
  });

  test(
    'refused upload keeps the photo local and does not break sync',
    () async {
      files.files['/local/a.jpg'] = Uint8List.fromList([1]);
      await addMed(family: 'fam-1', photo: '/local/a.jpg');
      storage.reject = true;
      final r = await engine.syncOnce();
      expect(r.networkError, isFalse);
      final row = await db.select(db.medications).getSingle();
      expect(row.photoPath, '/local/a.jpg');
      expect(row.photoRemotePath, isNull);
    },
  );

  test('offline upload is reported as a network error', () async {
    files.files['/local/a.jpg'] = Uint8List.fromList([1]);
    await addMed(family: 'fam-1', photo: '/local/a.jpg');
    storage.offline = true;
    expect((await engine.syncOnce()).networkError, isTrue);
  });

  test('changing the photo invalidates the uploaded copy', () async {
    files.files['/local/a.jpg'] = Uint8List.fromList([1]);
    files.files['/local/b.jpg'] = Uint8List.fromList([2]);
    final m = await addMed(family: 'fam-1', photo: '/local/a.jpg');
    await engine.syncOnce();
    final first = storage.objects.keys.single;

    final saved = (await meds.get(m.medication.id))!;
    await meds.save(
      saved.medication.copyWith(photoPath: '/local/b.jpg'),
      saved.schedule,
    );
    await engine.syncOnce();

    expect(storage.objects, hasLength(2));
    final row = await db.select(db.medications).getSingle();
    expect(row.photoRemotePath, isNot(first));
    expect(storage.objects[row.photoRemotePath], [2]);
  });

  test('another device downloads the photo into its own cache', () async {
    const key = 'fam-1/p1/m1/x.jpg';
    storage.objects[key] = Uint8List.fromList([9, 9]);
    remote.table('patients')['p1'] = {
      'id': 'p1',
      'family_id': 'fam-1',
      'user_id': null,
      'name': 'Budi',
      'birth_year': null,
      'conditions': <String>[],
      'notes': null,
      'photo_path': null,
      'updated_at': '2026-03-02T05:00:00Z',
      'deleted_at': null,
    };
    remote.table('medications')['m1'] = {
      'id': 'm1',
      'patient_id': 'p1',
      'name': 'Amlodipine',
      'strength': null,
      'form': null,
      'instructions': null,
      'meal_relation': null,
      'prescribed_by': null,
      'stock_qty': null,
      'dose_qty': 1,
      'refill_threshold_days': 3,
      'photo_path': key,
      'start_date': '2026-03-01',
      'end_date': null,
      'is_prn': false,
      'is_active': true,
      'source': 'manual',
      'updated_at': '2026-03-02T05:00:00Z',
      'deleted_at': null,
    };
    await engine.syncOnce();
    final row = await db.select(db.medications).getSingle();
    expect(row.photoRemotePath, key);
    expect(row.photoPath, isNotNull);
    expect(files.files[row.photoPath], [9, 9]);

    // Second sync: nothing to download again.
    final saved = files.saved;
    await engine.syncOnce();
    expect(files.saved, saved);
  });
}
