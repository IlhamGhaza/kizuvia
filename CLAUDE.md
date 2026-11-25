# CLAUDE.md — Kizuvia

Aplikasi Flutter pengingat minum obat untuk keluarga (pasien + caregiver), offline-first, backend Supabase.
Bahasa UI: Bahasa Indonesia. Kode, nama, dan komentar: Inggris.

## Baca dokumen sesuai tugas
| Dokumen | Kapan dibaca |
|---|---|
| `docs/00-BRAND-IDENTITY.md` | Brand, logo, warna, tipografi, tone of voice (acuan brand & visual) |
| `docs/01-PRD.md` | Memahami fitur, persona, non-goals |
| `docs/02-ARCHITECTURE.md` | **Selalu**, sebelum membuat file/folder baru |
| `docs/03-DATABASE.md` | Mengubah tabel, RLS, RPC, Drift |
| `docs/04-NOTIFICATIONS.md` | Apa pun terkait alarm/notifikasi/FCM |
| `docs/05-SYNC.md` | Sync engine, konflik, offline |
| `docs/06-SCAN-OCR.md` | Scan etiket, ML Kit, LiteRT, parser |
| `docs/07-UI-FLOW.md` | Membuat layar, navigasi, copy |
| `docs/08-SECURITY-PRIVACY.md` | Data pasien, logging, auth, storage |
| `docs/09-TESTING.md` | Menulis test, CI, Definition of Done |
| `docs/10-ROADMAP.md` | Memilih tugas berikutnya (kerjakan berurutan) |

## Aturan keselamatan (tidak boleh dilanggar)
1. Aplikasi tidak pernah merekomendasikan obat, dosis, atau interaksi. Semua data obat dari input pengguna.
2. Tidak ada daftar "obat untuk penyakit X". Kondisi pasien hanya label + edukasi umum bersumber.
3. Hasil OCR selalu draf yang wajib dikonfirmasi pengguna.
4. Alarm tidak boleh bergantung pada internet.
5. Data pasien/obat tidak boleh muncul di log release, analytics, atau crash report.
6. Semua tabel Supabase wajib RLS; service role key tidak pernah ada di app.

## Stack
Flutter · Dart 3 · Riverpod (codegen) · go_router · Drift · supabase_flutter · flutter_local_notifications
· firebase_messaging · google_mlkit_text_recognition · flutter_litert (opsional) · freezed

## Perintah
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter run --flavor dev --dart-define-from-file=env.dev.json
# Rilis (APK per ABI): flutter build apk --release --flavor prod --split-per-abi --dart-define-from-file=env.prod.json

# Supabase: tanpa Docker/CLI lokal. Migrasi, RLS test (pgTAP, dibungkus ROLLBACK),
# dan Edge Function diterapkan ke project dev di cloud lewat MCP Supabase.
```

## Skill desain (plugin Claude Code)
Instal sekali per mesin:
```text
/plugin install frontend-design@claude-plugins-official

/plugin marketplace add Leonxlnx/taste-skill
/plugin install taste-skill@taste-skill

/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

Kapan dipakai:
| Tugas | Skill |
|---|---|
| Menentukan arah visual, palet, tipografi, design token (T0.2) | `ui-ux-pro-max` → lalu `frontend-design` |
| Membuat atau merombak layar/komponen | `frontend-design` + `taste-skill` |
| Review tampilan sebelum PR (hierarki, spacing, konsistensi) | `taste-skill` |
| Alur UX, state kosong/error/loading, aksesibilitas | `ui-ux-pro-max` |

Aturan penerapan untuk Flutter:
- Skill-skill ini banyak memakai contoh web (HTML/CSS/React/Tailwind). **Terjemahkan prinsipnya ke Flutter**:
  `ThemeData`/`ColorScheme`, `TextTheme`, `ThemeExtension` untuk token custom, widget reusable di
  `lib/app/theme/` dan `lib/core/widgets/`. Jangan pernah menghasilkan HTML/CSS di project ini.
- Semua warna, ukuran font, radius, dan spacing lewat token tema, bukan nilai hard-coded di widget.
- Urutan prioritas jika ada konflik:
  1. Aturan keselamatan di atas
  2. Aksesibilitas & mode lansia (`docs/07-UI-FLOW.md` §2–3: kontras AA, target sentuh ≥ 48dp, font scaling 200%)
  3. Design system di `docs/07-UI-FLOW.md` §3
  4. Saran estetika dari skill
- Jika skill menyarankan mengubah design token (misalnya font atau warna primer), perbarui
  `docs/07-UI-FLOW.md` §3 di PR yang sama agar dokumen tetap jadi sumber kebenaran.
- Aplikasi kesehatan untuk lansia: utamakan kejelasan dan ketenangan, bukan efek visual yang ramai.
  Animasi singkat (≤ 300 ms) dan hormati pengaturan `MediaQuery.disableAnimations`.

## Cara kerja
- Kerjakan satu tugas roadmap per sesi/PR; tandai `[x]` di `docs/10-ROADMAP.md` setelah selesai.
- Sebelum menyatakan selesai: penuhi Definition of Done di `docs/09-TESTING.md`.
- Jika keputusan menyimpang dari dokumen, perbarui dokumen terkait di PR yang sama.
- Jangan menambah package baru tanpa alasan; jika perlu, catat di `docs/02-ARCHITECTURE.md` §9 (ADR).

## Catatan kerja (diperbarui Fase 2)
- Tanpa Docker/Supabase CLI lokal; Supabase diatur lewat MCP ke project dev `kizuviadev`. Jangan menaruh service role key atau JSON service account di repo/chat.
- `lib/firebase_options.dart` dibuat `flutterfire configure`: jangan ditimpa.
- Setelah mengubah `.arb`, skema Drift, atau anotasi: `flutter gen-l10n`, `dart run build_runner build --delete-conflicting-outputs`.
- Tool Bash di lingkungan ini sering gagal mem-parse perintah panjang dengan heredoc; untuk berkas besar pakai Write.
- Database lokal terenkripsi SQLCipher (`lib/core/db/db_encryption.dart`); tes memakai executor in-memory. `flutter_secure_storage` + `local_auth` butuh `MainActivity : FlutterFragmentActivity` dan tema AppCompat (sudah diatur).
- Uji alarm di perangkat nyata: layar debug Pengaturan > "Uji alarm" (hanya build debug).
