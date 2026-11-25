# 01 — Product Requirements Document (PRD)

## 1. Ringkasan
**Kizuvia** adalah aplikasi mobile Flutter untuk mengingatkan jadwal minum obat
pasien dalam satu keluarga, dan memberi tahu anggota keluarga lain (caregiver) ketika dosis terlewat.

## 2. Masalah
- Pasien kronis (stroke, hipertensi, diabetes, jantung) sering minum 4–10 obat per hari dengan jam berbeda.
- Lansia sering lupa, salah obat, atau dobel dosis.
- Anak/keluarga yang tinggal terpisah tidak tahu apakah orang tuanya sudah minum obat.
- Obat sering habis sebelum jadwal kontrol karena stok tidak dipantau.
- Saat kontrol, dokter tidak punya data kepatuhan minum obat.

## 3. Persona
| Persona | Deskripsi | Kebutuhan utama |
|---|---|---|
| **Pasien lansia** (Pak Budi, 68, pasca-stroke) | HP Android murah, penglihatan menurun | Alarm keras, tombol besar, foto obat |
| **Caregiver utama** (Rina, 38, anak) | Tinggal beda kota, sibuk kerja | Notifikasi jika dosis terlewat, input obat dari jauh |
| **Caregiver di rumah** (Ibu Sari, 65) | Mengurus suami | Melihat jadwal semua obat, konfirmasi atas nama pasien |
| **Pasien mandiri** (Andi, 30, hipertensi) | Tech-savvy | Pengingat sederhana, riwayat untuk dokter |

## 4. User stories (MVP + Fase 2)
### Pasien & obat
- US-01: Sebagai caregiver, saya bisa menambah beberapa pasien dalam satu keluarga.
- US-02: Sebagai caregiver, saya bisa menambah obat (nama, kekuatan, bentuk, instruksi, foto) untuk pasien.
- US-03: Sebagai caregiver, saya bisa mengatur jadwal (jam, hari, tanggal mulai/selesai) per obat.
- US-04: Sebagai pengguna, saya bisa memilih template frekuensi (1x, 2x, 3x sehari) yang otomatis mengisi jam.
### Alarm & konfirmasi
- US-05: Sebagai pasien, saya mendapat alarm tepat waktu walaupun tidak ada internet.
- US-06: Sebagai pasien, saya bisa menekan "Sudah minum", "Tunda 10 menit", atau "Lewati" langsung dari notifikasi.
- US-07: Sebagai caregiver, saya mendapat push notification jika dosis belum dikonfirmasi setelah batas waktu.
- US-08: Sebagai caregiver di rumah, saya bisa mengonfirmasi dosis atas nama pasien.
### Stok
- US-09: Stok berkurang otomatis setiap dosis dikonfirmasi.
- US-10: Saya diingatkan saat stok tersisa ≤ N hari.
### Riwayat
- US-11: Saya bisa melihat kalender kepatuhan dan persentase per obat/per pasien.
- US-12: Saya bisa mengekspor laporan PDF untuk ditunjukkan ke dokter.
### Keluarga
- US-13: Saya bisa mengundang anggota keluarga lewat kode/tautan.
- US-14: Owner bisa mengatur peran (owner, caregiver, patient) dan mengeluarkan anggota.
### Scan
- US-15: Saya bisa memotret etiket apotek dan form obat terisi otomatis sebagai draf yang saya periksa.

## 5. Kebutuhan non-fungsional
| Kategori | Target |
|---|---|
| Keandalan alarm | ≥ 99% alarm berbunyi dalam ±1 menit dari jadwal (diuji di Xiaomi/Oppo/Samsung/iPhone) |
| Offline | Seluruh fitur Fase 1 jalan tanpa internet |
| Latensi notifikasi caregiver | ≤ 10 menit setelah batas waktu terlewat |
| Performa | Cold start < 2 detik di HP kelas menengah |
| Ukuran APK | < 40 MB (tanpa model LiteRT) |
| Aksesibilitas | Font scaling hingga 200%, kontras WCAG AA, target sentuh ≥ 48dp |
| Privasi | Data kesehatan hanya terlihat oleh anggota keluarga (RLS) |
| Bahasa | Bahasa Indonesia (en sebagai tambahan) |

## 6. Di luar cakupan (non-goals)
- Rekomendasi obat, dosis, atau interaksi obat otomatis.
- Daftar "obat untuk penyakit X".
- OCR resep tulisan tangan.
- Telemedicine, chat dengan dokter, pembelian obat.
- Integrasi rekam medis rumah sakit / SATUSEHAT (mungkin di masa depan).

## 7. Metrik keberhasilan
- Tingkat kepatuhan rata-rata pengguna aktif ≥ 85%.
- Retensi D30 ≥ 40%.
- ≥ 50% keluarga punya ≥ 2 anggota (fitur keluarga terpakai).
- Rasio "alarm tidak berbunyi" yang dilaporkan < 1%.

## 8. Disclaimer produk
Ditampilkan saat onboarding dan di layar info:
> "Kizuvia adalah alat bantu pengingat. Aplikasi ini tidak memberikan saran medis.
> Selalu ikuti petunjuk dokter dan apoteker Anda."
