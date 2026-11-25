# 04 — Alarm & Notifikasi

Bagian paling kritis di aplikasi. Alarm yang tidak berbunyi = produk gagal.

## 1. Dua jenis notifikasi
| Jenis | Mekanisme | Penerima |
|---|---|---|
| Alarm dosis | `flutter_local_notifications` (terjadwal di perangkat) | Pasien / perangkat di rumah |
| Dosis terlewat, stok menipis | FCM dari Edge Function | Caregiver |

## 2. Channel Android
| Channel ID | Nama | Importance | Catatan |
|---|---|---|---|
| `dose_alarm_v2` (v1 `dose_alarm` dihapus saat init) | Pengingat minum obat | max | suara alarm custom, getar, full-screen intent (mode lansia) |
| `dose_followup` | Pengingat ulang | high | 10 menit setelah alarm pertama jika belum dikonfirmasi |
| `caregiver_alert` | Peringatan keluarga | high | dari FCM |
| `stock` | Stok obat | default | |

## 3. Izin
Android:
- `POST_NOTIFICATIONS` (13+) — minta saat onboarding dengan penjelasan.
- `SCHEDULE_EXACT_ALARM` (12+) — arahkan ke pengaturan; jika ditolak, fallback ke inexact + peringatan di UI.
  `USE_EXACT_ALARM` hanya jika lolos kebijakan Play Store untuk aplikasi alarm/pengingat.
- `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `USE_FULL_SCREEN_INTENT` (mode lansia).
- Panduan menonaktifkan optimasi baterai per merek (Xiaomi/MIUI, Oppo/ColorOS, Vivo, Samsung),
  tampilkan sekali saat onboarding dan dari menu Pengaturan → "Alarm tidak bunyi?".

iOS:
- Minta izin alert, sound, badge.
- Pertimbangkan *Time Sensitive* interruption level agar tembus Focus mode.
- *Critical alerts* butuh entitlement khusus Apple — jangan diasumsikan tersedia.

## 4. Algoritma penjadwalan (`AlarmScheduler`)

```
rescheduleAll():
  window = [now, now + 48h]
  occurrences = []
  for schedule in activeSchedules():
    for day in window (di timezone schedule):
      if day.isoWeekday in schedule.days_of_week
         and medication.start_date <= day <= (medication.end_date ?? ∞):
        for t in schedule.times:
          at = TZDateTime(schedule.timezone, day + t)
          if at in window and not alreadyLogged(schedule.id, at):
            occurrences.add(at, schedule)

  occurrences = sortByTime(occurrences).take(MAX)   # MAX = 60 di iOS (sisakan ruang), 200 di Android
  diff dengan tabel scheduled_notifications:
     batalkan yang tidak ada lagi, jadwalkan yang baru
```

Kapan `rescheduleAll()` dipanggil:
- app dibuka / resume,
- setelah CRUD obat atau jadwal,
- setelah sync menarik perubahan,
- `BOOT_COMPLETED`, `TIMEZONE_CHANGED`, `TIME_SET` (Android),
- background fetch berkala (iOS `BGAppRefreshTask`, Android WorkManager tiap ~6 jam).

### Implementasi Fase 1 (penyimpangan dari draf di atas)
- Jendela penjadwalan: **iOS 48 jam / maks. 60 occurrence**, **Android 7 hari / maks. 200 occurrence** (tidak ada batas 64 di Android;
  jendela lebih panjang menjaga alarm tetap bunyi walau app tidak dibuka beberapa hari). Penjadwalan ulang berkala via WorkManager/BGAppRefreshTask
  **belum ada** (butuh paket baru); sementara hanya saat app dibuka/resume dan setelah perubahan data.
- Follow-up (+10 menit) dijadwalkan bersama alarm di Android; **tidak** di iOS (menghemat batas 64).
- Setiap `rescheduleAll()` menjadwalkan ulang semua notifikasi di jendela (id sama = menggantikan), sehingga ganti nama obat / mode privasi langsung berlaku.
  Baris `scheduled_notifications` yang sudah lewat hanya dihapus, tidak di-cancel, agar notifikasi yang masih di tray tidak hilang.
- Konfirmasi "Sudah minum"/"Lewati" (dari notifikasi atau layar Hari ini) membatalkan alarm, follow-up, dan salinan tunda dosis itu.
- Pengingat stok lokal (channel `stock`) muncul setelah dosis `taken` bila stok ≤ ambang; satu per obat per hari.
- Mode privasi layar kunci: judul/isi generik ("N obat dijadwalkan pukul HH:mm"), tanpa nama pasien dan obat.
- Payload notifikasi hanya berisi id + waktu, tanpa nama.

### Perilaku alarm (Android)
- Suara = nada alarm sistem, diulang terus (`FLAG_INSISTENT`) sampai dikonfirmasi/ditutup atau 5 menit; getar berpola; kategori `alarm`.
- Full-screen intent + `showWhenLocked`/`turnScreenOn`: layar menyala dan membuka `/dose/{id}`.
- Menembus Jangan Ganggu butuh izin **Do Not Disturb access** (bukan bisa dipaksa dari app); izin ini dan izin full-screen (Android 14+)
  diminta opsional di onboarding dan "Alarm tidak bunyi?". Properti channel tidak bisa diubah setelah dibuat, jadi perubahan = id channel baru.
- Zona waktu: jadwal menyimpan zona waktunya sendiri (default zona perangkat saat obat dibuat); alarm dijadwalkan sebagai instan UTC,
  jadi mengganti zona waktu perangkat tidak menggeser alarm yang sudah dibuat.

### ID notifikasi
`notificationId = fnv1a32("${scheduleId}|${scheduledAt.toUtc().toIso8601String()}") & 0x7fffffff`
Deterministik, sehingga penjadwalan ulang tidak membuat duplikat.
Untuk notifikasi gabungan, `scheduleId` diganti daftar `scheduleId` terurut (dipisah koma); follow-up memakai prefiks `f:`, tunda ke-n `zN:`.

### Pengelompokan
Jika beberapa obat untuk pasien yang sama jatuh pada menit yang sama, gabungkan menjadi satu notifikasi:
"Waktunya minum 3 obat (07:00): Amlodipine, Clopidogrel, Atorvastatin".
Payload menyimpan daftar `scheduleId`.

## 5. Action button
| Action | Perilaku |
|---|---|
| `TAKEN` — "Sudah minum" | insert `dose_log(taken)`, kurangi stok, batalkan follow-up |
| `SNOOZE` — "Tunda 10 menit" | jadwalkan satu notifikasi sekali jalan +10 menit (maks. 3x) |
| `SKIP` — "Lewati" | insert `dose_log(skipped)` dengan alasan opsional (dari app) |

Handler action berjalan di background isolate (`onDidReceiveBackgroundNotificationResponse`,
fungsi top-level dengan `@pragma('vm:entry-point')`). Isolate ini harus bisa membuka Drift sendiri.

## 6. Konten notifikasi
- Judul: `"💊 {namaPasien}: waktunya minum obat"`
- Isi: `"{namaObat} {kekuatan} — {dose_qty} {bentuk}, {instruksi}"`
- Jangan tampilkan nama obat di lock screen jika pengguna mengaktifkan "Privasi lock screen" (Pengaturan).

## 7. FCM untuk caregiver
- Token disimpan di `device_tokens` setelah login dan setiap `onTokenRefresh`.
- Edge Function `send-push` memakai FCM HTTP v1 (service account di Supabase secrets).
- Payload data: `{type: "missed_dose", patientId, scheduleId, scheduledAt}`; tap → layar detail dosis.
- Token yang dibalas `UNREGISTERED` oleh FCM dihapus.
- Rate limit: maksimal 1 push per pasien per 15 menit (gabungkan beberapa obat yang terlewat).

### Implementasi FCM (T2.6, T2.7)
- Android memakai **Firebase Installation ID (FID)** (`register()` + `onRegistered`, meta-data `firebase_messaging_installation_id_enabled`); iOS tetap memakai token
  (FID sebagai target kirim belum andal di Apple). Nilainya disimpan di `device_tokens.token`; server mengirim `fid` bila tidak mengandung ":" dan `token` bila ya.
- Edge Function memakai service account FCM dari secret `FCM_SERVICE_ACCOUNT` (JSON). **Mengirim dari server tetap butuh kredensial ini**; tanpa itu fungsi
  berhenti sebelum menyentuh data (tidak ada dosis yang "dihabiskan").
- Cron (pg_cron, rahasia di Vault): `missed-dose-check` tiap 5 menit, `low-stock-check` harian 01:00 UTC. Fungsi memakai `verify_jwt=false` dan header `x-cron-secret`.
- Batas: 1 push per pasien per 15 menit (dosis lain menunggu putaran berikutnya); `missed` dicatat ke `dose_logs` hanya setelah push dikirim (atau bila tak ada penerima).
- Channel `caregiver_alert` dibuat di aplikasi; pesan FCM saat app terbuka ditampilkan sebagai notifikasi lokal.

## 8. Checklist uji manual (wajib sebelum rilis)
- [ ] Alarm berbunyi saat app di-kill (swipe dari recent apps)
- [ ] Alarm berbunyi setelah reboot
- [ ] Alarm berbunyi dalam mode hemat daya / Doze
- [ ] Xiaomi, Oppo, Vivo, Samsung, Pixel, iPhone
- [ ] Ganti zona waktu (WIB → WITA) → jam lokal jadwal tetap sesuai pengaturan
- [ ] Action "Sudah minum" dari lock screen tanpa membuka app
- [ ] Lebih dari 64 occurrence di iOS → jadwal bergulir benar
