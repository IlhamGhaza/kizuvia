# 11 — Wear OS / Apple Watch (eksplorasi T3.7)

Status: **eksplorasi saja, tidak ada kode.** Tujuan: tahu opsi termurah sebelum memutuskan investasi.

## 1. Tanpa kode tambahan (sudah jalan)
- Notifikasi alarm Kizuvia memakai `flutter_local_notifications` dengan action `TAKEN` / `SNOOZE` / `SKIP`.
  Android dan iOS otomatis meneruskan (*bridge*) notifikasi telepon ke jam yang terpasang, termasuk tombol action.
- Konsekuensi: pengguna Wear OS dan Apple Watch sudah bisa menerima pengingat dan menekan "Sudah minum" dari jam,
  selama jam terhubung ke telepon dan aplikasi diizinkan menampilkan notifikasi di jam.
- **Belum diuji di perangkat jam.** Uji dulu sebelum mengklaimnya ke pengguna. Mode privasi layar kunci
  (judul/isi generik) juga berlaku di jam.

## 2. Aplikasi jam mandiri (butuh pekerjaan terpisah)
| Platform | Cara | Kira-kira | Catatan |
|---|---|---|---|
| Wear OS | Modul Android native (Kotlin + Compose for Wear OS) di folder `android/wear/`, bukan Flutter | 1-2 minggu | Data lewat Data Layer API dari telepon; alarm lokal tetap dari telepon |
| Apple Watch | Target watchOS (SwiftUI) di Xcode, `WatchConnectivity` | 1-2 minggu | Butuh Mac dan akun developer; proyek ini belum punya target iOS yang diuji |

Flutter tidak mendukung Wear OS / watchOS secara resmi, jadi aplikasi jam harus native dan hanya berisi:
dosis berikutnya, tombol "Sudah minum", dan "Lewati".

## 3. Rekomendasi
1. Uji notifikasi yang diteruskan ke jam di satu perangkat Wear OS dan satu Apple Watch.
2. Jika cukup, jangan bangun aplikasi jam (non-goal PRD: fokus telepon). Catat sebagai keterbatasan yang diketahui.
3. Aplikasi jam hanya jika ada permintaan nyata pengguna. Alarm tidak boleh bergantung pada jam.

## 4. Batasan keselamatan
- Data pasien/obat di jam mengikuti aturan yang sama dengan telepon (docs/08): tidak masuk log atau analytics.
- Jam bukan sumber alarm; alarm tetap dijadwalkan di telepon (aturan keselamatan 4).
