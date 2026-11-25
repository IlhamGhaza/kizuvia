# Kizuvia — Brand & Visual Identity

> **Status:** Proposed brand direction  
> **Product:** Family Medication & Care Management  
> **Tagline:** Care that connects.  
> **Primary language:** Bahasa Indonesia  
> **Platform:** Flutter mobile application

Dokumen ini menetapkan arah identitas visual Kizuvia. Dokumen ini tidak mengubah product scope, user stories, arsitektur, aturan keselamatan, atau prioritas roadmap yang sudah ditetapkan di dokumen lain.

---

## 1. Brand foundation

### 1.1 Brand name

**Kizuvia**

Nama brand ciptaan yang terinspirasi dari gagasan *kizuna* (ikatan) dan *via* (jalan/perjalanan). Kombinasi ini merupakan konsep penamaan brand, bukan terjemahan literal atau kata baku dari satu bahasa.

### 1.2 Tagline

**Care that connects.**

Tagline menggambarkan peran Kizuvia dalam menghubungkan pasien, caregiver, dan keluarga melalui rutinitas perawatan yang lebih terorganisasi.

Versi Inggris dipakai untuk materi portfolio/store listing. Di dalam aplikasi (Bahasa Indonesia) gunakan versi Indonesia, usulan: **"Merawat, saling terhubung."** (belum final; ditetapkan di T0.2c). Tagline tidak ditampilkan di layar kerja harian.

### 1.3 Product descriptor

**Family Medication & Care Management**

Gunakan descriptor ini pada materi pengenalan produk atau portfolio. Jangan membatasi positioning produk hanya sebagai *pill reminder*: cakupannya juga meliputi pengelolaan obat, jadwal, stok, riwayat, dan koordinasi caregiver dalam keluarga.

### 1.4 Brand promise

Kizuvia membantu keluarga mengelola rutinitas obat dan saling mengetahui informasi perawatan yang relevan, dengan pengalaman yang jelas, tenang, dan mudah diakses.

Kizuvia bukan tenaga medis dan bukan pengganti arahan dokter atau apoteker.

### 1.5 Brand attributes

| Attribute | Penerapan |
|---|---|
| Caring | Bahasa yang suportif, tidak menghakimi pasien yang melewatkan dosis |
| Connected | Relasi pasien, caregiver, dan keluarga terlihat jelas |
| Calm | Tampilan rapi, warna terkendali, minim distraksi |
| Trustworthy | Informasi, status, dan tindakan ditampilkan secara eksplisit |
| Accessible | Mudah dibaca dan dioperasikan, termasuk oleh pengguna lansia |

---

## 2. Visual direction

### 2.1 Design concept

**Calm, connected, accessible.**

Arah visual Kizuvia adalah produk digital kesehatan keluarga yang modern dan hangat. Gunakan pendekatan minimalis dengan inspirasi prinsip desain Jepang: keteraturan, kesederhanaan, ruang kosong yang cukup, dan perhatian pada detail.

Inspirasi tersebut adalah arahan estetika, bukan klaim bahwa produk berasal dari Jepang atau harus menggunakan ornamen budaya Jepang.

### 2.2 Visual principles

1. **Clarity over decoration** — informasi obat, waktu, dosis, dan status harus lebih menonjol daripada dekorasi.
2. **Warm, not clinical** — hindari tampilan yang terasa seperti dashboard rumah sakit atau aplikasi administrasi medis.
3. **Consistent patterns** — gunakan pola komponen, ikon, jarak, dan status yang konsisten.
4. **One primary action** — terutama pada layar pasien dan mode lansia, tampilkan satu aksi utama yang mudah dikenali.
5. **Accessible by default** — jangan mengorbankan keterbacaan demi tampilan yang lebih padat atau trendi.

### 2.3 Hindari

- Gradien mencolok sebagai dekorasi utama.
- Glassmorphism atau efek blur yang mengurangi keterbacaan.
- Terlalu banyak warna aksen dalam satu layar.
- Ilustrasi kartun yang membuat produk terlihat seperti aplikasi anak-anak.
- Ikon medis generik sebagai satu-satunya identitas brand.
- Informasi penting yang hanya dibedakan melalui warna.
- Animasi, grafik, atau dekorasi yang mengganggu tugas utama pengguna.

---

## 3. Color system

Warna teal dari rancangan awal dipertahankan sebagai fondasi brand. Palet berikut adalah **usulan token awal** dan wajib diuji kontrasnya pada kombinasi foreground/background yang benar sebelum dianggap final.

| Token | Hex | Penggunaan |
|---|---|---|
| `primary` | `#0F766E` | Aksi utama, navigasi aktif, elemen brand |
| `primary-dark` | `#115E59` | State pressed, emphasis pada konteks yang sesuai |
| `primary-soft` | `#DCEFEA` | Surface lembut, chip atau highlight non-kritis |
| `background` | `#F7F7F2` | Latar utama bernuansa warm ivory |
| `surface` | `#FFFFFF` | Kartu, dialog, dan surface utama |
| `surface-subtle` | `#F0F4F1` | Surface sekunder |
| `text-primary` | `#243B38` | Teks utama |
| `text-secondary` | `#526561` | Teks pendukung |
| `border` | `#D8E2DE` | Divider dan outline |
| `success` | `#15803D` | Status berhasil |
| `warning` | `#B45309` | Peringatan |
| `danger` | `#B91C1C` | Kesalahan atau status berisiko |
| `info` | `#1D4ED8` | Informasi non-kritis |
| `warning-soft` | `#FBEFD9` | Latar field yang perlu diperiksa ulang (mis. hasil scan); selalu dengan ikon + label |

### 3.1 Color usage rules

- Gunakan `primary` untuk aksi utama yang paling penting pada layar.
- Jangan menggunakan `primary-soft` untuk teks kecil tanpa menguji kontras.
- Warna status harus selalu disertai label teks dan/atau ikon.
- Jangan menggunakan warna `success` untuk tombol "Sudah minum" tanpa label yang jelas.
- `danger` hanya untuk kondisi yang memang membutuhkan perhatian; jangan menjadikan seluruh pengalaman terasa mengkhawatirkan.
- Hindari penggunaan warna status sebagai dekorasi.

### 3.2 Accessibility requirement

Target minimum tetap mengikuti PRD dan UI Flow:

- WCAG AA untuk teks dan komponen yang relevan.
- Target sentuh minimal 48dp.
- Informasi status tidak boleh bergantung pada warna saja.

Dark mode termasuk cakupan (`02-ARCHITECTURE.md` §3, roadmap T0.2b). Palet dark belum ada dan ditetapkan di T0.2b; sampai itu selesai, hanya palet light di atas yang berlaku.

Uji rasio kontras pada pasangan warna aktual, termasuk disabled, pressed, selected, dan dark mode. Jangan mengklaim palet telah memenuhi WCAG AA sebelum pengujian dilakukan.

---

## 4. Typography

### 4.1 Typeface

Gunakan **Plus Jakarta Sans** sebagai pilihan utama apabila lisensi dan rendering Flutter sudah diverifikasi. **Inter** dapat menjadi fallback.

Font wajib **dibundel sebagai asset** (`flutter: fonts:` di pubspec). Jangan memakai `google_fonts` yang mengunduh saat runtime: aplikasi offline-first.

### 4.2 Typography principles

- Prioritaskan keterbacaan, bukan gaya display.
- Gunakan hierarki yang jelas antara judul halaman, judul kartu, isi, label, dan metadata.
- Hindari font weight terlalu tipis.
- Jangan menyampaikan instruksi penting hanya dengan teks kecil atau warna redup.
- Hormati system text scaling dan font scaling hingga 200% sesuai kebutuhan aksesibilitas produk.

### 4.3 Elderly mode

Mode lansia tetap mengikuti ketentuan `docs/07-UI-FLOW.md`:

- Ukuran font dasar 22sp.
- Tombol dengan tinggi minimal 64dp.
- Satu aksi utama per layar.
- Informasi dosis berikutnya dan aksi konfirmasi ditampilkan dengan hierarki yang kuat.

Jangan mengunci ukuran teks sehingga pengguna tidak dapat memperbesar teks melalui pengaturan sistem.

---

## 5. Logo and brand mark

### 5.1 Recommended concept: Connected Care

Gunakan simbol abstrak yang menggabungkan **dua bentuk yang saling terhubung**. Bentuk tersebut merepresentasikan pasien dan caregiver/keluarga.

Karakter logo:

- Sederhana dan mudah dikenali pada ukuran kecil.
- Tetap terbaca dalam satu warna.
- Tidak bergantung pada detail tipis.
- Dapat digunakan sebagai app icon tanpa wordmark.
- Tidak menyerupai logo institusi medis atau brand lain.

### 5.2 Avoid

- Simbol plus medis sebagai ide utama.
- Gambar kapsul atau pil sebagai satu-satunya simbol.
- Siluet manusia yang terlalu literal.
- Ornamen Jepang/China yang tidak memiliki hubungan jelas dengan konsep produk.
- Detail kompleks yang hilang ketika icon diperkecil.

### 5.3 Logo deliverables

Saat logo dibuat, siapkan:

1. Primary lockup: symbol + wordmark `Kizuvia`.
2. App icon: symbol only.
3. Monochrome version.
4. Light-background and dark-background versions.

**Logo saat ini (diberikan pemilik):** huruf **K** dari dua bentuk daun/pita yang saling melipat, gradien teal di tile rounded-square. Sumber: `assets/logo/logo.png` (1254×1254, raster). Ini menggantikan konsep "dua bentuk terhubung" di §5.1 sebagai arah final; lipatan pada K dianggap mewakili keterhubungan.

Turunan (dibuat dari `logo.png`): `app-icon.png` (iOS + Android lama), `app-icon-foreground.png` (adaptive Android, K dalam safe zone), `splash-logo.png` (tile rounded). Konfigurasi di `pubspec.yaml` (`flutter_launcher_icons`, `flutter_native_splash`); regenerasi dengan `dart run flutter_launcher_icons` dan `dart run flutter_native_splash:create`. Splash: latar `background` (`#F7F7F2`), mode gelap `#243B38`.

Catatan yang belum selesai:
- `logo.png` memakai gradien dan bayangan; §2.3 menghindari gradien mencolok sebagai dekorasi. Untuk logo ini dianggap pengecualian yang disengaja; jangan dipakai untuk elemen UI lain.
- Belum ada versi vektor (SVG), versi monokrom, versi latar gelap, dan lockup dengan wordmark. `logoKizuvia.png` (wordmark gelap dengan glow) hampir tidak terbaca dan belum dipakai.
- Ikon kecil notifikasi Android (monokrom) belum dibuat.

Jangan menganggap konsep logo di dokumen ini sebagai logo final. Bentuk final perlu dibuat dan diuji pada ukuran app icon serta header aplikasi.

---

## 6. UI component direction

| Component | Direction |
|---|---|
| App bar | Bersih, judul jelas, maksimal satu-dua aksi kontekstual |
| Bottom navigation | Empat tujuan yang sudah ditetapkan: Hari ini, Pasien, Riwayat, Keluarga |
| Medication card | Nama obat, kekuatan, jumlah, waktu, instruksi, dan status mudah dipindai |
| Primary button | Kontras kuat, label berupa kata kerja yang jelas |
| Status chip | Ikon + teks; warna hanya sebagai penguat |
| Form | Label selalu terlihat; jangan hanya mengandalkan placeholder |
| Dialog | Menjelaskan konsekuensi tindakan dan menyediakan pilihan yang jelas |
| Empty state | Menjelaskan kondisi dan satu langkah berikutnya |
| Error state | Menjelaskan masalah dan tindakan pemulihan tanpa menyalahkan pengguna |
| Loading state | Stabil dan tidak menyebabkan layout bergeser berlebihan |

### 6.1 Medication status

Pertahankan status domain yang telah digunakan dalam product flow. Setiap status harus memiliki teks yang eksplisit dan ikon yang konsisten. Jangan mengubah arti status hanya demi menyederhanakan visual.

### 6.2 Tone of voice

Gunakan Bahasa Indonesia yang:

- Hangat, sederhana, dan menghormati pengguna.
- Tidak menyalahkan pasien ketika dosis terlewat.
- Tidak membuat klaim medis.
- Menjelaskan tindakan secara langsung.

Contoh:

| Hindari | Gunakan |
|---|---|
| Anda gagal minum obat | Dosis ini belum dikonfirmasi |
| Bahaya! Obat belum diminum! | Dosis pukul 07.00 belum dikonfirmasi |
| Input invalid | Periksa kembali nama obat |
| OCR berhasil membaca resep | Hasil scan sudah terisi. Periksa sebelum menyimpan |

Contoh microcopy yang sudah ada di `docs/07-UI-FLOW.md` tetap menjadi acuan dan hanya diubah jika ada alasan UX yang jelas.

---

## 7. Motion and interaction

- Animasi bersifat fungsional, bukan dekoratif.
- Durasi animasi singkat, maksimal 300 ms sesuai pedoman proyek.
- Hormati `MediaQuery.disableAnimations`.
- Jangan menggunakan animasi sebagai satu-satunya indikator perubahan status.
- Konfirmasi aksi harus tetap jelas tanpa animasi.
- Hindari gesture tersembunyi untuk aksi penting; sediakan tombol yang terlihat.

---

## 8. Flutter implementation guidance

Terapkan visual identity melalui design tokens terpusat, bukan nilai hard-coded di setiap widget.

Lokasi implementasi yang disarankan:

```text
lib/
  app/
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
      app_spacing.dart
      app_radius.dart
```

Struktur di atas adalah rekomendasi; sesuaikan dengan struktur aktual yang ditetapkan `docs/02-ARCHITECTURE.md`. Jangan membuat folder atau file baru sebelum membaca dokumen arsitektur.

Implementation rules:

1. Gunakan Material 3.
2. Definisikan `ColorScheme`, `TextTheme`, dan token komponen secara terpusat.
3. Gunakan `ThemeExtension` bila token custom memang diperlukan.
4. Hindari warna, radius, spacing, dan ukuran font hard-coded di widget.
5. Pastikan semua state interaktif memiliki tampilan yang konsisten: default, pressed, focused, disabled, loading, error, dan selected.
6. Jangan menambah dependency hanya untuk menerapkan branding tanpa alasan teknis yang jelas.

---

## 9. Product and safety boundaries

Branding tidak boleh mengubah batasan produk berikut:

- Kizuvia adalah alat bantu pengingat dan pengelolaan rutinitas obat, bukan pemberi saran medis.
- Aplikasi tidak merekomendasikan obat, dosis, atau interaksi obat.
- Semua data obat berasal dari input pengguna atau hasil scan yang wajib dikonfirmasi.
- Hasil OCR tetap berupa draf, bukan instruksi medis yang tervalidasi.
- Alarm lokal tidak boleh bergantung pada internet.
- Data pasien dan obat harus mengikuti aturan keamanan serta privasi proyek.
- Copywriting tidak boleh menjanjikan hasil kesehatan atau kepatuhan tertentu.

Disclaimer produk tetap wajib ditampilkan sesuai PRD.

---

## 10. Brand consistency checklist

Sebelum menyelesaikan perubahan UI, pastikan:

- [ ] Nama produk ditulis `Kizuvia` secara konsisten.
- [ ] Tagline hanya digunakan pada konteks yang sesuai, bukan dipaksakan di setiap layar.
- [ ] Warna berasal dari theme tokens.
- [ ] Typography berasal dari text theme.
- [ ] Status selalu memiliki ikon dan teks.
- [ ] Target sentuh minimal 48dp.
- [ ] Mode lansia tetap memenuhi spesifikasi khususnya.
- [ ] Font scaling hingga 200% tidak merusak layout.
- [ ] Kontras diuji pada kombinasi warna aktual.
- [ ] Tidak ada dekorasi yang mengganggu tugas utama.
- [ ] Copywriting tidak menyalahkan pasien atau memberikan saran medis.
- [ ] Tidak ada perubahan scope, arsitektur, atau behavior tanpa pembaruan dokumen terkait.

---

## 11. Source of truth and related documents

Dokumen ini menjadi acuan identitas brand dan arah visual. Dokumen berikut tetap menjadi sumber kebenaran untuk domain masing-masing:

| File | Perubahan yang diperlukan |
|---|---|
| `CLAUDE.md` | Ganti nama proyek pada judul/deskripsi; tambahkan aturan bahwa `docs/00-BRAND-IDENTITY.md` adalah acuan brand dan visual |
| `docs/01-PRD.md` | Ganti nama sementara `ObatKeluarga` menjadi `Kizuvia`; pertahankan product scope dan disclaimer |
| `docs/07-UI-FLOW.md` | Sinkronkan design system dengan token dokumen ini setelah kontras diuji; pertahankan alur, layar, dan kebutuhan aksesibilitas |
| `docs/02-ARCHITECTURE.md` | Deep link diganti ke `kizuvia://` (selaras dengan `com.igz.kizuvia`); bagian lain tidak berubah karena rebranding |

**Penting:** jangan melakukan global find-and-replace terhadap `ObatKeluarga` tanpa memeriksa konteks. Nama tabel, package, bundle identifier, folder, nama database, dan identifier teknis tidak otomatis harus diganti bersamaan dengan nama brand. Perubahan identifier teknis harus menjadi keputusan terpisah karena dapat memengaruhi build, integrasi, dan data.
