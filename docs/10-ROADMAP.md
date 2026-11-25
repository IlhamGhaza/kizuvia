# 10 — Roadmap & Breakdown Tugas

Kerjakan berurutan. Setiap tugas = satu PR kecil dengan test.

## Fase 0 — Fondasi (± 1 minggu)
- [x] T0.1 `flutter create`, flavor dev/prod, `flutter_lints` ketat, struktur folder (02-ARCHITECTURE §3)
      (flavor baru Android; skema/flavor iOS menunggu Mac/Xcode; folder `features/*` lain dibuat saat dipakai)
- [x] T0.2 Riverpod + go_router + l10n id
- [x] T0.2b Design system: pakai skill `ui-ux-pro-max` + `frontend-design` untuk memfinalkan palet, tipografi, spacing;
      implementasi `ThemeData` (light, dark, lansia) + `ThemeExtension` token + halaman `/dev/gallery` berisi semua komponen;
      review dengan `taste-skill`; perbarui `docs/07-UI-FLOW.md` §3; bundel font Plus Jakarta Sans sebagai asset;
      tetapkan palet dark; uji kontras semua pasangan warna
      Sudah: tema light/dark/lansia, token, font dibundel, `/dev/gallery` (debug), palet dark, uji kontras otomatis.
      Golden test (tag `golden`, dirender di Windows, tidak dijalankan di CI; font uji = blok Ahem) + guideline a11y Flutter lulus.
      Belum dicek manual di emulator/perangkat.
- [x] T0.2c Identitas visual: logo (K, `assets/logo/logo.png`), app icon, dan splash native sudah di-setup;
      sisa: logo vektor/monokrom/lockup, ikon kecil notifikasi Android (monokrom), splash di-cek di perangkat, versi tagline Bahasa Indonesia
- [x] T0.3 Drift database: tabel patients, medications, schedules, dose_logs, sync_queue, scheduled_notifications
- [x] T0.4 `Clock` provider, `Result`/`AppFailure`, logger dengan redaksi
- [x] T0.5 CI GitHub Actions (job `supabase` di-comment sampai T2.1; belum pernah jalan di GitHub)

## Fase 1 — MVP offline (± 3–4 minggu)
- [x] T1.1 Onboarding + disclaimer + persetujuan data
- [x] T1.2 Layar izin notifikasi & exact alarm + panduan optimasi baterai
- [x] T1.3 CRUD pasien
- [x] T1.4 CRUD obat + jadwal (template frekuensi, foto lampiran)
- [x] T1.5 `AlarmScheduler` + unit test lengkap
- [x] T1.6 Notifikasi + action button (background isolate) + follow-up
      (kode + test unit selesai; perilaku nyata di OS belum diuji, lihat T1.10)
- [x] T1.7 Beranda "Hari ini" + konfirmasi manual
- [x] T1.8 Stok otomatis + pengingat stok lokal
- [x] T1.9 Riwayat: kalender + persentase kepatuhan
- [x] T1.10 Uji alarm di perangkat nyata (checklist 04 §8) — butuh perangkat fisik, belum dikerjakan
- 🎯 **Rilis internal / closed testing Play Store**

## Fase 2 — Keluarga & cloud (± 3–4 minggu)
- [x] T2.1 Supabase project, migrasi 0001 & 0002, test RLS (pgTAP)
      (project `kizuviadev`, ap-southeast-1; migrasi di `supabase/migrations/`; 55 test di `supabase/tests/rls_test.sql` lulus, dijalankan via MCP dalam transaksi yang di-rollback)
- [x] T2.2 Auth (email OTP + Google), RPC create_family
      (email OTP + create/join keluarga selesai; **Google Sign-In ditunda** atas permintaan pemilik, belum ada kodenya)
- [x] T2.3 Migrasi data lokal ke akun
- [x] T2.4 Sync engine push/pull + realtime
      (16 test engine dengan `FakeSyncRemote`; **belum diuji end-to-end ke server nyata dari app**; realtime memicu pull, bukan apply langsung)
- [x] T2.5 Undangan (kode + deep link), kelola anggota
      (deep link `kizuvia://invite/{code}`; link https butuh domain + assetlinks, belum ada; belum diuji di perangkat)
- [x] T2.6 Firebase + FCM, simpan device token
      (Android memakai Firebase Installation ID via `register()`; iOS memakai token; belum diuji di perangkat)
- [x] T2.7 Edge Function `expand_occurrences` + `missed-dose-check` + `send-push` + pg_cron
      (`expand_occurrences` = fungsi SQL; `send-push` = modul bersama di tiap fungsi, bukan endpoint publik; terdeploy, auth + jalur "FCM belum dikonfigurasi" teruji; **kirim push nyata menunggu secret `FCM_SERVICE_ACCOUNT`**)
- [x] T2.8 Edge Function `low-stock-check`
      (terdeploy; cron harian 01:00 UTC)
- [x] T2.9 Scan etiket ML Kit + LabelParser + form draf
      (parser 52 test; OCR ML Kit belum diuji di perangkat; `image_cropper` tidak dipakai; kamus nama obat perlu diverifikasi ke BPOM/Fornas)
- [x] T2.10 Ekspor PDF kepatuhan
- [x] T2.11 Storage foto (upload terkompresi, signed URL)
      (unggah/unduh lewat Storage API terautentikasi + RLS, bukan signed URL; foto lama di bucket tidak dihapus saat diganti)
- 🎯 **Rilis beta publik**

## Fase 3 — Penyempurnaan
- [x] T3.1 Mode lansia penuh + alarm full-screen
      (beranda mode lansia = satu kartu "Obat berikutnya" + satu tombol "Sudah minum"; layar `/dose/:id` yang dibuka alarm full-screen kini menampilkan foto obat besar; **belum diuji di perangkat**)
- [x] T3.2 Konten edukasi per kondisi (bersumber + disclaimer)
      (4 topik: hipertensi, diabetes, jantung, kolesterol; teks di `lib/features/education/domain/education_content.dart`, bukan `assets/education/`; hanya Bahasa Indonesia; **isi perlu ditinjau tenaga kesehatan** dan sumber Kemenkes belum punya URL)
- [~] T3.3 Classifier LiteRT untuk foto etiket
      (**hanya jembatannya**: `LabelClassifier`, ambang `other` > 0,7, pesan "coba foto ulang", dipasang di `LabelScanner`; `NoModelClassifier` meloloskan semua foto. Model `.tflite` dan paket `flutter_litert` **belum ada** karena butuh dataset berlabel + pelatihan)
- [x] T3.4 Widget home screen "dosis berikutnya"
      (Android saja, paket `home_widget`; teks diperbarui saat app berjalan; ikut mode privasi layar kunci; **belum diuji di perangkat**)
- [x] T3.5 Enkripsi SQLite (SQLCipher) + kunci aplikasi
      (SQLCipher via `hooks.user_defines.sqlite3.source: sqlcipher`; kunci 256-bit di `flutter_secure_storage`; DB lama otomatis diekspor ke versi terenkripsi; kunci aplikasi via `local_auth`; `allowBackup=false`; **belum diuji di perangkat**, terutama migrasi DB lama dan isolate notifikasi)
- [x] T3.6 Bahasa Inggris
      (`lib/l10n/app_en.arb`; mengikuti bahasa perangkat, selain id/en jatuh ke id; konten edukasi dan laporan PDF tetap sebagian Indonesia)
- [x] T3.7 Wear OS / Apple Watch (eksplorasi)
      (hanya dokumen: `docs/11-WEARABLES.md`; notifikasi diteruskan ke jam tanpa kode, belum diuji)

## Risiko & mitigasi
| Risiko | Dampak | Mitigasi |
|---|---|---|
| Alarm dibunuh OEM Android | Tinggi | Panduan baterai, test matrix perangkat, banner peringatan |
| Kebijakan Play Store untuk exact alarm | Sedang | Deklarasi fungsi inti pengingat; fallback inexact |
| Pengguna salah input obat | Tinggi | Konfirmasi ringkasan sebelum simpan, foto obat |
| OCR salah baca | Sedang | Draf wajib dikonfirmasi, field confidence rendah dikosongkan |
| Biaya Supabase/FCM | Rendah | Free tier cukup untuk ribuan keluarga; pantau penggunaan |
