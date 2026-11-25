# 05 — Sinkronisasi Offline-First

## 1. Prinsip
- UI selalu membaca dari Drift.
- Setiap penulisan lokal dilakukan dalam satu transaksi: ubah tabel + `sync_queue.enqueue(...)`.
- Sync engine berjalan saat: app start, koneksi kembali, setelah enqueue (debounce 2 detik),
  push FCM tipe `data_changed`, dan periodik di background.
- ID dibuat di client (UUID v4), jadi tidak ada pemetaan ID lokal ↔ server.

## 2. Push (lokal → server)
```
for item in sync_queue order by created_at:
  switch item.op:
    upsert → supabase.from(table).upsert(payload)
    delete → supabase.from(table).update({deleted_at: now})   # soft delete
    insert_log → supabase.from('dose_logs').insert(payload) (on conflict do nothing)
  sukses → hapus dari queue, set row.sync_status = synced
  gagal (network) → berhenti, coba lagi nanti (exponential backoff 2^n detik, maks 10 menit)
  gagal (4xx/RLS) → attempts++, simpan last_error, sync_status = failed, lanjut item berikutnya
```

## 3. Pull (server → lokal)
Per tabel (`patients`, `medications`, `schedules`, `dose_logs`, `family_members`):
```
since = sync_cursor[table]
rows = select * from table where updated_at > since order by updated_at limit 500   (dose_logs: created_at)
for row in rows: applyRemote(row)
sync_cursor[table] = max(updated_at)
ulangi sampai rows < 500
```
Setelah pull ada perubahan pada schedules/medications → `AlarmScheduler.rescheduleAll()`.

Realtime: subscribe `postgres_changes` untuk tabel di atas, difilter berdasarkan `family_id`/`patient_id`
saat app di foreground → panggil `applyRemote` langsung.

## 4. Resolusi konflik
| Tabel | Aturan |
|---|---|
| patients, medications, schedules | Last-write-wins berdasarkan `updated_at` server vs `local_updated_at`. Jika baris lokal masih `pending`, **jangan timpa**; push dulu. |
| dose_logs | Append-only, tidak ada konflik. Status efektif per `(schedule_id, scheduled_at)`: `taken` > `skipped` > `missed`. |
| stok obat | Hitung ulang dari `dose_logs` jika terjadi selisih: `stock = stock_awal_restock - Σ dose_qty(taken setelah restock)`. Simpan event restock sebagai baris log terpisah (Fase 2: tabel `stock_events`). |
| soft delete | `deleted_at` menang atas update apa pun. |

## 5. Mode tanpa akun (Fase 1)
- Semua fitur berjalan dengan Drift saja; `sync_queue` tetap diisi.
- Saat user login/buat keluarga pertama kali: buat family di server, set `family_id` pada pasien lokal,
  lalu push seluruh antrean (migrasi data lokal ke akun).

## 6. Pengujian sync
- Unit test `SyncEngine` dengan `FakeSupabaseRemote` dan Drift in-memory.
- Skenario wajib:
  1. Edit offline di dua perangkat → online → hasil sesuai LWW.
  2. Konfirmasi `taken` offline setelah server menulis `missed` → status efektif `taken`, caregiver tidak dapat push ganda.
  3. Hapus obat di perangkat A saat perangkat B mengedit → obat tetap terhapus.
  4. Antrean 1.000 item → tidak memblokir UI (jalankan di isolate atau batch).

## 7. Catatan implementasi (Fase 2)
- Realtime (`postgres_changes`) hanya memicu pull inkremental (debounce 1 dtk), tidak memanggil `applyRemote` langsung.
- Pull memakai `>=` pada kursor (baris dengan cap waktu sama dibaca ulang; apply idempoten).
- Sebelum push, edit baris yang sama digabung (hanya versi terakhir dikirim); baris yang ditolak server 5 kali dilewati (tetap di antrean).
- Foto obat: unggah/unduh di awal/akhir tiap siklus sync (`PhotoSync`).
- Migrasi akun (`AccountMigrator`) mengosongkan antrean lama dan mengantre ulang seluruh data lokal dengan `family_id` terisi.
