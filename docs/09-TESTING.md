# 09 — Strategi Testing

## 1. Piramida
| Level | Alat | Fokus | Target |
|---|---|---|---|
| Unit | `flutter_test`, `mocktail` | Parser, scheduler, kalkulasi stok, sync engine, kepatuhan | ≥ 80% coverage di `core/` dan `domain/` |
| Widget | `flutter_test` | Form obat, kartu dosis, state kosong/error/loading | Layar utama |
| Golden | `alchemist` atau `golden_toolkit` | Mode normal vs lansia, light/dark | Beranda, form, alarm |
| Integration | `integration_test` | Alur end-to-end di emulator | Tambah obat → alarm → konfirmasi |
| Database | pgTAP di project Supabase dev (cloud), dijalankan via `execute_sql` dalam transaksi `ROLLBACK` | RLS, RPC, `expand_occurrences` | Semua policy |
| Manual | Checklist | Alarm di perangkat nyata | Lihat 04-NOTIFICATIONS.md §8 |

## 2. Kasus wajib unit test
### AlarmScheduler / occurrence
- 3x sehari, 48 jam → 6 occurrence.
- `days_of_week = {1,3,5}` → hanya Senin/Rabu/Jumat.
- `end_date` hari ini jam 13:00 → occurrence 19:00 tidak dibuat.
- Jadwal 23:30 dan 00:30 lintas tengah malam.
- Timezone `Asia/Makassar` saat perangkat di WIB.
- Occurrence yang sudah ada `dose_log` tidak dijadwalkan ulang.
- iOS cap 60 → hanya 60 terdekat.

### LabelParser
- "AMLODIPINE 10 MG / 1 x 1 tablet / sesudah makan" → name, 10 mg, 1x, 1, sesudah.
- "Paracetamol 500mg 3dd1 bila perlu" → isPrn = true.
- "1/2 tab" → doseQty 0.5.
- Teks sampah → semua field null, tidak crash.

### Stok
- Konfirmasi taken → stok berkurang `dose_qty`.
- Skipped/missed → stok tetap.
- Hitung "sisa hari" = stok / (dose_qty × jumlah dosis per hari).

### Kepatuhan
- `taken / (taken + skipped + missed)`, status efektif per occurrence (taken > skipped > missed).

### Sync
- Lihat skenario di 05-SYNC.md §6.

## 3. Test RLS (pgTAP, `supabase/tests/rls_test.sql`)
- User A (keluarga 1) tidak bisa select/insert pasien keluarga 2.
- Caregiver bisa insert `dose_logs`, tidak bisa update/delete.
- Non-owner tidak bisa membuat undangan.

## 4. CI (GitHub Actions)
```
on: [push, pull_request]
jobs:
  flutter:
    - flutter pub get
    - dart run build_runner build --delete-conflicting-outputs
    - dart format --set-exit-if-changed .
    - flutter analyze
    - flutter test --coverage
  supabase:
    # Tanpa Docker/CLI lokal: file di supabase/tests/*.sql dijalankan terhadap
    # project dev di cloud (MCP atau psql dengan DB URL di secret CI), tiap file
    # diawali BEGIN dan diakhiri ROLLBACK agar tidak meninggalkan data.
```

## 5. Definition of Done
- [ ] `flutter analyze` tanpa issue
- [ ] Test baru untuk logika baru, semua test lulus
- [ ] String UI di `l10n`, bukan hard-coded
- [ ] Jika menyentuh UI: warna/spacing/font dari token tema, sudah direview dengan `taste-skill`, golden test diperbarui
- [ ] Jika menyentuh UI/copy: checklist `docs/00-BRAND-IDENTITY.md` §10 terpenuhi
- [ ] Tidak ada data pasien di log
- [ ] Jika menyentuh notifikasi: checklist manual di perangkat nyata
- [ ] Jika menyentuh skema: migrasi Supabase + migrasi Drift + test

## 6. Status (per Fase 2)
- Unit/widget: 186 test non-golden (`flutter test --exclude-tags golden`). Golden (tag `golden`) dirender di Windows dan hanya dijalankan lokal.
- Database: `supabase/tests/rls_test.sql` (55 pernyataan TAP). Cara menjalankan tanpa Docker: kirim isi file ke `execute_sql` pada project dev;
  file berakhir dengan `RAISE EXCEPTION 'TAP REPORT ...'` sehingga semua perubahan di-rollback, dan hasilnya dibaca dari pesan error (semua baris harus `ok`).
- Migrasi Drift: `test/core/db/migration_test.dart` (v1 -> v2). Setelah mengubah skema: `dart run drift_dev schema dump lib/core/db/app_database.dart drift_schemas/`
  lalu `dart run drift_dev schema generate drift_schemas/ test/core/db/generated/`.
- Test widget yang memakai Drift perlu `settle(tester)` dan `unmount(tester)` (lihat `test/app/app_test.dart`): stream Drift butuh waktu nyata dan penutupan DB tidak boleh di teardown fake-async.
- Belum ada: integration_test di emulator, uji sync ke server nyata, uji OCR dengan foto etiket (`test/fixtures/labels/`), uji FCM end-to-end.
