import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLCipher at-rest encryption for the local database (T3.5, docs/08 §3).
/// The 256-bit key lives in Android Keystore-backed secure storage, never in
/// the app files. Safe to call from the UI and the notification isolate.
const _keyName = 'db_key_v1';
const _dbName = 'kizuvia';

String _pragmaKey(String hex) => "PRAGMA key = \"x'$hex'\"";

Future<String> _loadOrCreateKey(FlutterSecureStorage store) async {
  final existing = await store.read(key: _keyName);
  if (existing != null && existing.length == 64) return existing;
  final r = Random.secure();
  final hex = List.generate(
    32,
    (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await store.write(key: _keyName, value: hex);
  return hex;
}

bool _readable(String path, {String? hexKey}) {
  Database? db;
  try {
    db = sqlite3.open(path);
    if (hexKey != null) db.execute(_pragmaKey(hexKey));
    db.select('SELECT count(*) FROM sqlite_master');
    return true;
  } on Object {
    return false;
  } finally {
    db?.close();
  }
}

void _deleteDb(String path) {
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.deleteSync();
  }
}

/// Makes sure the file at [path] is encrypted with [hexKey]:
/// - missing -> nothing to do (created encrypted on first open);
/// - already readable with the key -> done;
/// - plaintext (pre-T3.5 install) -> exported into an encrypted copy;
/// - unreadable both ways (key lost) -> renamed to `*.unreadable-<ts>` (not
///   deleted) and the app starts clean, re-pulling from the cloud if signed in.
void ensureEncrypted(String path, String hexKey) {
  if (!File(path).existsSync()) return;
  if (_readable(path, hexKey: hexKey)) return;
  if (!_readable(path)) {
    // Never delete health data: keep the unreadable file aside so it can be
    // recovered, and start with a fresh database.
    final stamp = DateTime.now().millisecondsSinceEpoch;
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File('$path$suffix');
      if (f.existsSync()) f.renameSync('$path.unreadable-$stamp$suffix');
    }
    return;
  }
  final tmp = '$path.enc';
  _deleteDb(tmp);
  final db = sqlite3.open(path);
  try {
    final version = db.select('PRAGMA user_version').first.values.first;
    db.execute("ATTACH DATABASE '$tmp' AS enc KEY \"x'$hexKey'\"");
    db.select("SELECT sqlcipher_export('enc')");
    db.execute('PRAGMA enc.user_version = $version');
    db.execute('DETACH DATABASE enc');
  } finally {
    db.close();
  }
  _deleteDb(path);
  File(tmp).renameSync(path);
}

/// Top level so the closure sent to the database isolate captures only [hex].
DriftNativeOptions _options(String hex) => DriftNativeOptions(
  shareAcrossIsolates: true,
  databasePath: () async => p.join(
    (await getApplicationDocumentsDirectory()).path,
    '$_dbName.sqlite',
  ),
  setup: (db) => db.execute(_pragmaKey(hex)),
);

/// Encrypted production connection.
DatabaseConnection openEncryptedConnection() => DatabaseConnection.delayed(
  Future(() async {
    const store = FlutterSecureStorage();
    final hex = await _loadOrCreateKey(store);
    final path = p.join(
      (await getApplicationDocumentsDirectory()).path,
      '$_dbName.sqlite',
    );
    ensureEncrypted(path, hex);
    return driftDatabase(name: _dbName, native: _options(hex));
  }),
);
