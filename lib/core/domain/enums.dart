// Pure-Dart enums shared by domain and data layers (no Drift import here).

/// Local sync state of a row (docs/03-DATABASE.md §5).
enum SyncStatus { synced, pending, failed }

enum DoseStatus { taken, skipped, missed }

enum DoseSource { device, server }

enum SyncOp { upsert, delete }

enum MedForm {
  tablet,
  kapsul,
  sirup,
  tetes,
  salep,
  injeksi,
  inhaler,
  lainnya;

  static MedForm? tryParse(String? v) {
    for (final f in values) {
      if (f.name == v) return f;
    }
    return null;
  }
}

enum MealRelation {
  sebelumMakan('sebelum_makan'),
  sesudahMakan('sesudah_makan'),
  bersamaMakan('bersama_makan'),
  bebas('bebas');

  const MealRelation(this.dbValue);

  /// Value stored in SQLite / Supabase.
  final String dbValue;

  static MealRelation? tryParse(String? v) {
    for (final m in values) {
      if (m.dbValue == v) return m;
    }
    return null;
  }
}
