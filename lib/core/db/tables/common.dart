import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kizuvia/core/domain/enums.dart';

export 'package:kizuvia/core/domain/enums.dart'
    show DoseSource, DoseStatus, SyncOp, SyncStatus;

/// Columns shared by mutable synced tables.
mixin SyncColumns on Table {
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      textEnum<SyncStatus>().withDefault(Constant(SyncStatus.pending.name))();

  /// Time of the last local edit (conflict resolution, docs/05-SYNC.md).
  DateTimeColumn get localUpdatedAt => dateTime()();
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<int>();

  @override
  String toSql(List<int> value) => jsonEncode(value);
}
