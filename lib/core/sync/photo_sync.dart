import 'dart:io';

import 'package:drift/drift.dart';
import 'package:kizuvia/core/clock/clock.dart';
import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/db/sync_enqueue.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/core/sync/sync_remote.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

/// Private bucket `medication-photos` (docs/03 §4). Keys are
/// `{family_id}/{patient_id}/{medication_id}/{uuid}.jpg`, so the storage
/// policy can check family membership from the first path segment.
abstract interface class PhotoStorage {
  Future<void> upload(String key, Uint8List bytes);
  Future<Uint8List> download(String key);
}

abstract interface class PhotoFiles {
  Future<Uint8List?> read(String path);

  /// Stores [bytes] as a new local photo and returns its path.
  Future<String> save(Uint8List bytes);
}

class SupabasePhotoStorage implements PhotoStorage {
  SupabasePhotoStorage(this._client);

  final sb.SupabaseClient _client;

  sb.StorageFileApi get _bucket => _client.storage.from('medication-photos');

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on sb.StorageException catch (e) {
      final code = int.tryParse(e.statusCode ?? '') ?? 500;
      if (code >= 400 && code < 500 && code != 408 && code != 429) {
        throw SyncRejectedException('$code');
      }
      throw const SyncNetworkException();
    } on Object {
      throw const SyncNetworkException();
    }
  }

  @override
  Future<void> upload(String key, Uint8List bytes) => _guard(
    () => _bucket.uploadBinary(
      key,
      bytes,
      fileOptions: const sb.FileOptions(contentType: 'image/jpeg'),
    ),
  );

  @override
  Future<Uint8List> download(String key) => _guard(() => _bucket.download(key));
}

class LocalPhotoFiles implements PhotoFiles {
  @override
  Future<Uint8List?> read(String path) async {
    final f = File(path);
    return f.existsSync() ? f.readAsBytes() : null;
  }

  @override
  Future<String> save(Uint8List bytes) async {
    final dir = Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'med_photos'),
    );
    await dir.create(recursive: true);
    final path = p.join(dir.path, '${const Uuid().v4()}.jpg');
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }
}

/// Uploads local medication photos and downloads the ones taken on other
/// devices (T2.11). Images are already compressed (max 1280 px, JPEG q80)
/// when picked. Used by the sync engine; never touches alarms.
class PhotoSync {
  PhotoSync({
    required this.db,
    required this.storage,
    required this.files,
    required this.clock,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final PhotoStorage storage;
  final PhotoFiles files;
  final Clock clock;
  final Uuid _uuid;

  /// Local photo, family known, not uploaded yet -> upload, then queue the
  /// medication row so `photo_path` reaches the server.
  Future<void> uploadPending() async {
    final rows =
        await (db.select(db.medications).join([
              innerJoin(
                db.patients,
                db.patients.id.equalsExp(db.medications.patientId),
              ),
            ])..where(
              db.medications.photoPath.isNotNull() &
                  db.medications.photoRemotePath.isNull() &
                  db.medications.deletedAt.isNull() &
                  db.patients.familyId.isNotNull(),
            ))
            .get();
    for (final r in rows) {
      final med = r.readTable(db.medications);
      final family = r.readTable(db.patients).familyId!;
      final bytes = await files.read(med.photoPath!);
      if (bytes == null) continue; // file gone: nothing to upload
      final key = '$family/${med.patientId}/${med.id}/${_uuid.v4()}.jpg';
      try {
        await storage.upload(key, bytes);
      } on SyncRejectedException {
        continue; // e.g. file too large / type refused: leave it local
      }
      final now = clock.now().toUtc();
      await db.transaction(() async {
        await (db.update(
          db.medications,
        )..where((t) => t.id.equals(med.id))).write(
          MedicationsCompanion(
            photoRemotePath: Value(key),
            updatedAt: Value(now),
            localUpdatedAt: Value(now),
            syncStatus: const Value(SyncStatus.pending),
          ),
        );
        final row = await (db.select(
          db.medications,
        )..where((t) => t.id.equals(med.id))).getSingle();
        await enqueueSync(
          db,
          table: 'medications',
          rowId: med.id,
          op: SyncOp.upsert,
          payload: medicationPayload(row),
          now: now,
        );
      });
    }
  }

  /// Remote photo, no local file -> download into the app folder.
  Future<void> downloadMissing() async {
    final rows =
        await (db.select(db.medications)..where(
              (t) =>
                  t.photoRemotePath.isNotNull() &
                  t.photoPath.isNull() &
                  t.deletedAt.isNull(),
            ))
            .get();
    for (final med in rows) {
      try {
        final bytes = await storage.download(med.photoRemotePath!);
        final path = await files.save(bytes);
        // Local-only change: no sync status bump, no queue entry.
        await (db.update(db.medications)..where((t) => t.id.equals(med.id)))
            .write(MedicationsCompanion(photoPath: Value(path)));
      } on SyncRejectedException {
        continue; // missing object: try again after the next change
      }
    }
  }
}
