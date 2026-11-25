# 08 — Keamanan, Privasi & Kepatuhan

## 1. Klasifikasi data
| Data | Sensitivitas | Perlakuan |
|---|---|---|
| Nama pasien, kondisi, obat, log dosis | Tinggi (data kesehatan) | RLS, enkripsi at-rest bawaan Supabase, tidak masuk analytics/log |
| Foto obat/resep | Tinggi | Bucket privat, signed URL berumur 1 jam |
| Email, nama anggota | Sedang | RLS |
| Token FCM | Rendah | milik user sendiri |

## 2. Regulasi
- **UU No. 27/2022 tentang Pelindungan Data Pribadi (UU PDP)**: data kesehatan termasuk data pribadi spesifik.
  - Persetujuan eksplisit saat onboarding (checkbox, bukan pre-checked).
  - Kebijakan privasi dalam Bahasa Indonesia.
  - Hak pengguna: lihat, ekspor, hapus data → menu Pengaturan → "Data saya".
- Google Play: isi formulir *Health apps declaration* dan *Data safety* dengan jujur.
- Apple: isi *App Privacy* label; hindari klaim medis di deskripsi App Store.
- Aplikasi **bukan perangkat medis**: tidak mendiagnosis, tidak merekomendasikan terapi.
- Pastikan region Supabase dicatat di kebijakan privasi (misalnya Singapore `ap-southeast-1`).

## 3. Kontrol teknis
- RLS di semua tabel (lihat 03-DATABASE.md). Tambahkan test RLS dengan dua user berbeda keluarga.
- Service role key hanya di Edge Function.
- Drift lokal terenkripsi SQLCipher (T3.5). Kunci 256-bit acak disimpan di `flutter_secure_storage`; DB lama yang belum terenkripsi diekspor otomatis saat pertama dibuka.
  Jika kunci hilang dan DB tak terbaca, file diganti nama `*.unreadable-<ts>` (tidak dihapus) dan data ditarik ulang dari cloud (bila masuk akun). `allowBackup=false` agar backup Android tidak memulihkan DB tanpa kunci.
- Kunci aplikasi opsional (Pengaturan) via `local_auth` (biometrik atau PIN/pola perangkat). Layar dosis `/dose/...` dari alarm sengaja tidak dikunci agar dosis tetap bisa dikonfirmasi.
- Widget home screen menampilkan nama pasien dan obat kecuali "Sembunyikan nama di layar kunci" aktif.
- Lock screen privacy: sembunyikan nama obat pada notifikasi jika diaktifkan.
- Logger: redact field `name`, `notes`, `conditions`, `instructions` di build release.
- Crash reporting: `beforeSend` men-scrub data di atas.
- Hapus akun: RPC `delete_my_account()` → hapus membership; jika owner tunggal, hapus keluarga beserta data (cascade) + file storage.

## 4. Konten medis
- Konten edukasi di `assets/education/` hanya teks umum yang ditulis/ditinjau, dengan sumber (Kemenkes, WHO, dll.).
- Setiap halaman edukasi berakhir dengan disclaimer.
- Tidak ada fitur "cek interaksi obat" sebelum ada sumber data tervalidasi dan tinjauan apoteker.

## 5. Threat model singkat
| Ancaman | Mitigasi |
|---|---|
| User keluarga A membaca data keluarga B | RLS + test otomatis |
| Kode undangan ditebak | 6 karakter alfanumerik (~1 miliar kombinasi), kedaluwarsa 7 hari, sekali pakai, rate-limit RPC |
| HP hilang | Kunci aplikasi opsional, logout jarak jauh (hapus sesi dari perangkat lain) |
| Bocornya anon key | Aman selama RLS benar; anon key memang publik |
| Spam push | Rate limit di Edge Function |

## 6. Status kontrol (per Fase 2)
| Kontrol | Status |
|---|---|
| RLS di semua tabel + test dua keluarga (55 test pgTAP) | ada |
| Service role key hanya di Edge Function (disuntik Supabase); anon/publishable key di `env.dev.json` (di-.gitignore) | ada |
| Logger redaksi + hanya tipe error; `AppLogger` dipakai untuk semua peringatan start-up | ada |
| Foto obat: bucket privat, batas 5 MB, JPEG/PNG/WebP, path per keluarga | ada |
| Payload notifikasi lokal hanya id + waktu; mode privasi layar kunci | ada |
| `delete_my_account_data()` (RPC) | ada di server; **belum ada layar "Data saya"** (UU PDP: lihat/ekspor/hapus) |
| Enkripsi SQLite (SQLCipher) + kunci aplikasi | ada (T3.5), belum diuji di perangkat |
| Kebijakan privasi, formulir Play Data safety | belum (pra-rilis) |
| Crash reporting dengan scrubbing | belum |

Hal yang perlu diketahui:
- **Push FCM berisi nama pasien dan nama obat** (mis. "Ayah belum minum Amlodipine (jadwal 07:00)") dan lewat server Google.
  Ini mengikuti microcopy di `07-UI-FLOW.md`; pertimbangkan mode "tanpa nama" sebelum rilis publik.
- Hasil scan dan foto sementara dari kamera dihapus setelah dibaca; PDF laporan disimpan sementara di folder temp dan diganti pada ekspor berikutnya.
- Kode undangan: 6 karakter, kedaluwarsa 7 hari, sekali pakai, maks. 20 undangan aktif per keluarga; belum ada rate-limit per pengguna di RPC.
