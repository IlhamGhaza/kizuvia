// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Kizuvia';

  @override
  String get taglineId => 'Merawat, saling terhubung.';

  @override
  String get disclaimer =>
      'Kizuvia adalah alat bantu pengingat. Aplikasi ini tidak memberikan saran medis. Selalu ikuti petunjuk dokter dan apoteker Anda.';

  @override
  String get navToday => 'Hari ini';

  @override
  String get navPatients => 'Pasien';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navFamily => 'Keluarga';

  @override
  String get homeTitle => 'Hari ini';

  @override
  String get homeEmptyTitle => 'Belum ada obat';

  @override
  String get homeEmptyAction => 'Tambahkan obat pertama';

  @override
  String get routeNotFound => 'Halaman tidak ditemukan';

  @override
  String get routeNotFoundAction => 'Kembali ke beranda';

  @override
  String get notifChannelAlarm => 'Pengingat minum obat';

  @override
  String get notifChannelFollowup => 'Pengingat ulang';

  @override
  String get notifChannelStock => 'Stok obat';

  @override
  String notifTitle(String patient) {
    return '$patient: waktunya minum obat';
  }

  @override
  String get notifTitlePrivate => 'Waktunya minum obat';

  @override
  String notifBodyPrivate(int count, String time) {
    return '$count obat dijadwalkan pukul $time';
  }

  @override
  String notifBodyGroup(int count, String time, String names) {
    return 'Waktunya minum $count obat ($time): $names';
  }

  @override
  String notifFollowupTitle(String patient) {
    return '$patient: obat belum dikonfirmasi';
  }

  @override
  String notifStockBody(String name, int days) {
    return '$name tinggal $days hari lagi. Jangan lupa tebus resep.';
  }

  @override
  String get actionTaken => 'Sudah minum';

  @override
  String get actionSnooze => 'Tunda 10 menit';

  @override
  String get actionSkip => 'Lewati';

  @override
  String get onbWelcomeTitle => 'Selamat datang di Kizuvia';

  @override
  String get onbWelcomeBody =>
      'Pengingat obat untuk keluarga. Alarm tetap berbunyi tanpa internet.';

  @override
  String get consentLabel =>
      'Saya setuju data kesehatan saya disimpan di perangkat ini dan, jika saya masuk akun, disinkronkan ke keluarga saya.';

  @override
  String get consentRequired => 'Centang persetujuan untuk melanjutkan';

  @override
  String get continueAction => 'Lanjut';

  @override
  String get startAction => 'Mulai';

  @override
  String get skipForNow => 'Nanti saja';

  @override
  String get permTitle => 'Izinkan pengingat';

  @override
  String get permBody =>
      'Agar alarm obat berbunyi tepat waktu, Kizuvia perlu izin notifikasi dan alarm. Dua izin terakhir opsional, tapi membantu alarm tetap terdengar.';

  @override
  String get permNotifAction => 'Izinkan notifikasi';

  @override
  String get permExactAction => 'Izinkan alarm tepat waktu';

  @override
  String get permGranted => 'Sudah diizinkan';

  @override
  String get batteryTitle => 'Agar alarm tidak terlewat';

  @override
  String get batteryBody =>
      'Beberapa ponsel menghentikan aplikasi di latar belakang. Ikuti langkah sesuai merek ponsel Anda.';

  @override
  String get batteryXiaomi =>
      'Xiaomi / Redmi / POCO: Pengaturan > Aplikasi > Kizuvia > Hemat baterai > Tanpa batasan. Aktifkan juga Mulai otomatis.';

  @override
  String get batteryOppo =>
      'Oppo / Realme / OnePlus: Pengaturan > Baterai > Kizuvia > Izinkan aktivitas latar belakang. Aktifkan Mulai otomatis.';

  @override
  String get batteryVivo =>
      'Vivo / iQOO: Pengaturan > Baterai > Konsumsi daya latar belakang > Kizuvia > Izinkan. Aktifkan Mulai otomatis.';

  @override
  String get batterySamsung =>
      'Samsung: Pengaturan > Baterai > Batas penggunaan di latar belakang > Aplikasi yang tidak pernah tidur > tambahkan Kizuvia.';

  @override
  String get batteryOther =>
      'Ponsel lain: Pengaturan > Aplikasi > Kizuvia > Baterai > Tanpa batasan.';

  @override
  String get alarmHelpTitle => 'Alarm tidak bunyi?';

  @override
  String get bannerNotifOff =>
      'Notifikasi mati, alarm tidak akan muncul. Aktifkan izin notifikasi';

  @override
  String get bannerExactOff =>
      'Alarm mungkin tidak berbunyi tepat waktu. Aktifkan izin alarm';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get add => 'Tambah';

  @override
  String get back => 'Kembali';

  @override
  String get retry => 'Coba lagi';

  @override
  String get errorGeneric => 'Terjadi masalah saat menyimpan. Coba lagi.';

  @override
  String get loadError => 'Data belum bisa dimuat. Coba lagi.';

  @override
  String get patientsTitle => 'Pasien';

  @override
  String get patientsEmpty => 'Belum ada pasien';

  @override
  String get patientsEmptyAction => 'Tambah pasien';

  @override
  String get patientFormNew => 'Tambah pasien';

  @override
  String get patientFormEdit => 'Ubah pasien';

  @override
  String get fieldName => 'Nama';

  @override
  String get fieldBirthYear => 'Tahun lahir';

  @override
  String get fieldConditions => 'Kondisi (label, pisahkan dengan koma)';

  @override
  String get fieldNotes => 'Catatan';

  @override
  String get errNameRequired => 'Periksa kembali nama';

  @override
  String get errBirthYear => 'Periksa kembali tahun lahir';

  @override
  String get deletePatientTitle => 'Hapus pasien?';

  @override
  String get deletePatientBody =>
      'Pasien dan semua obatnya akan dihapus dari aplikasi.';

  @override
  String get medsEmpty => 'Belum ada obat';

  @override
  String get addMed => 'Tambah obat';

  @override
  String get medFormNew => 'Tambah obat';

  @override
  String get medFormEdit => 'Ubah obat';

  @override
  String get fieldMedName => 'Nama obat';

  @override
  String get fieldStrength => 'Kekuatan (mis. 10 mg)';

  @override
  String get fieldForm => 'Bentuk';

  @override
  String get fieldDoseQty => 'Jumlah per dosis';

  @override
  String get fieldFrequency => 'Frekuensi';

  @override
  String get freq1 => '1x sehari';

  @override
  String get freq2 => '2x sehari';

  @override
  String get freq3 => '3x sehari';

  @override
  String get freq4 => '4x sehari';

  @override
  String get freqCustom => 'Atur sendiri';

  @override
  String get freqPrn => 'Bila perlu';

  @override
  String get fieldTimes => 'Jam minum';

  @override
  String get addTime => 'Tambah jam';

  @override
  String get removeTime => 'Hapus jam';

  @override
  String get fieldDays => 'Hari';

  @override
  String get dayMon => 'Sen';

  @override
  String get dayTue => 'Sel';

  @override
  String get dayWed => 'Rab';

  @override
  String get dayThu => 'Kam';

  @override
  String get dayFri => 'Jum';

  @override
  String get daySat => 'Sab';

  @override
  String get daySun => 'Min';

  @override
  String get fieldMeal => 'Relasi makan';

  @override
  String get mealBefore => 'Sebelum makan';

  @override
  String get mealAfter => 'Sesudah makan';

  @override
  String get mealWith => 'Bersama makan';

  @override
  String get mealAny => 'Bebas';

  @override
  String get fieldStartDate => 'Tanggal mulai';

  @override
  String get fieldEndDate => 'Tanggal selesai';

  @override
  String get noEndDate => 'Tanpa tanggal selesai';

  @override
  String get clearDate => 'Hapus tanggal';

  @override
  String get fieldStock => 'Stok saat ini';

  @override
  String get fieldRefill => 'Ingatkan saat stok tersisa (hari)';

  @override
  String get fieldInstructions => 'Instruksi atau catatan';

  @override
  String get formTablet => 'Tablet';

  @override
  String get formKapsul => 'Kapsul';

  @override
  String get formSirup => 'Sirup';

  @override
  String get formTetes => 'Tetes';

  @override
  String get formSalep => 'Salep';

  @override
  String get formInjeksi => 'Injeksi';

  @override
  String get formInhaler => 'Inhaler';

  @override
  String get formLainnya => 'Lainnya';

  @override
  String get fieldPhoto => 'Foto obat';

  @override
  String get photoAdd => 'Tambah foto';

  @override
  String get photoChange => 'Ganti foto';

  @override
  String get photoRemove => 'Hapus foto';

  @override
  String get errMedName => 'Periksa kembali nama obat';

  @override
  String get errDoseQty => 'Periksa kembali jumlah per dosis';

  @override
  String get errNeedTime => 'Tambahkan minimal satu jam minum';

  @override
  String get errNeedDay => 'Pilih minimal satu hari';

  @override
  String get reviewTitle => 'Periksa sebelum menyimpan';

  @override
  String get reviewHint =>
      'Pastikan nama, kekuatan, dan jadwal sudah sesuai dengan etiket atau resep Anda.';

  @override
  String get deleteMedTitle => 'Hapus obat?';

  @override
  String get deleteMedBody =>
      'Obat dan jadwalnya akan dihapus. Alarmnya ikut berhenti.';

  @override
  String get selectItems => 'Pilih';

  @override
  String get selectAll => 'Pilih semua';

  @override
  String get cancelSelection => 'Batalkan pilihan';

  @override
  String selectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String deletePatientsTitle(int count) {
    return 'Hapus $count pasien?';
  }

  @override
  String deleteMedsTitle(int count) {
    return 'Hapus $count obat?';
  }

  @override
  String get medDetailTitle => 'Detail obat';

  @override
  String scheduleSummary(String times) {
    return 'Jam $times';
  }

  @override
  String get daysEveryDay => 'Setiap hari';

  @override
  String get prnNote => 'Bila perlu: tidak ada alarm.';

  @override
  String stockLeft(String qty) {
    return 'Stok: $qty';
  }

  @override
  String stockDaysLeft(int days) {
    return 'Sisa sekitar $days hari';
  }

  @override
  String stockLow(String name, int days) {
    return '$name tinggal $days hari lagi. Jangan lupa tebus resep.';
  }

  @override
  String get stockUnknown => 'Stok belum diisi';

  @override
  String get restock => 'Tambah stok';

  @override
  String get restockQty => 'Jumlah yang ditambahkan';

  @override
  String get lowStockBadge => 'Stok menipis';

  @override
  String get filterAll => 'Semua';

  @override
  String get todayEmptyTitle => 'Belum ada obat';

  @override
  String get todayEmptyBody => 'Tambahkan pasien dan obat pertama untuk mulai.';

  @override
  String get todayNothing => 'Tidak ada dosis terjadwal hari ini';

  @override
  String get statusUpcoming => 'Akan datang';

  @override
  String get statusNow => 'Sekarang';

  @override
  String get statusTaken => 'Diminum';

  @override
  String get statusSkipped => 'Dilewati';

  @override
  String get statusMissed => 'Belum dikonfirmasi';

  @override
  String get takenAction => 'Sudah minum';

  @override
  String get skipAction => 'Lewati';

  @override
  String confirmedTaken(String name, String time) {
    return 'Tercatat. $name diminum $time';
  }

  @override
  String confirmedSkipped(String name) {
    return 'Dosis $name dilewati';
  }

  @override
  String get doseDetailTitle => 'Detail dosis';

  @override
  String get doseNotFound => 'Dosis tidak ditemukan';

  @override
  String scheduledFor(String time) {
    return 'Jadwal $time';
  }

  @override
  String get allDoneToday => 'Semua dosis hari ini sudah tercatat';

  @override
  String get scanNotLabel =>
      'Foto ini sepertinya bukan etiket atau kemasan obat. Coba foto ulang.';

  @override
  String widgetNext(String time) {
    return 'Berikutnya $time';
  }

  @override
  String get widgetNone => 'Tidak ada dosis berikutnya';

  @override
  String get widgetPrivateBody => 'Obat dijadwalkan';

  @override
  String get appLock => 'Kunci aplikasi';

  @override
  String get appLockHint =>
      'Minta sidik jari, wajah, atau PIN HP saat membuka aplikasi. Alarm minum obat tetap bisa dibuka.';

  @override
  String get appLockReason => 'Buka Kizuvia';

  @override
  String get appLockTitle => 'Kizuvia terkunci';

  @override
  String get appLockUnlock => 'Buka kunci';

  @override
  String get appLockUnavailable =>
      'Atur kunci layar (PIN, pola, atau sidik jari) di HP terlebih dahulu.';

  @override
  String get educationTitle => 'Tentang kondisi';

  @override
  String get educationEmpty =>
      'Belum ada informasi untuk kondisi yang tercatat. Tambahkan kondisi seperti hipertensi, diabetes, kolesterol, atau jantung di data pasien.';

  @override
  String get educationSources => 'Sumber';

  @override
  String get elderlyNextDose => 'Obat berikutnya';

  @override
  String elderlyMoreAtSameTime(int count) {
    return 'Masih ada $count obat lain pada jam ini';
  }

  @override
  String get historyTitle => 'Riwayat';

  @override
  String get historyEmpty => 'Belum ada riwayat dosis';

  @override
  String adherenceLabel(int days, int percent) {
    return 'Kepatuhan $days hari: $percent%';
  }

  @override
  String get adherenceNone => 'Belum ada data kepatuhan';

  @override
  String get legendAll => 'Semua diminum';

  @override
  String get legendPartial => 'Sebagian';

  @override
  String get legendMissed => 'Ada yang belum dikonfirmasi';

  @override
  String get legendNone => 'Tidak ada jadwal';

  @override
  String get perMedication => 'Per obat';

  @override
  String get familyTitle => 'Keluarga';

  @override
  String get familyPlaceholder =>
      'Berbagi dengan keluarga tersedia setelah Anda masuk akun. Fitur ini segera hadir.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get elderlyMode => 'Mode lansia';

  @override
  String get elderlyModeHint => 'Teks dan tombol lebih besar';

  @override
  String get privacyLock => 'Sembunyikan nama di layar kunci';

  @override
  String get privacyLockHint =>
      'Notifikasi tidak menampilkan nama pasien dan obat';

  @override
  String get permDndAction => 'Izinkan alarm saat mode Jangan Ganggu';

  @override
  String get permFullScreenAction => 'Izinkan alarm tampil di layar kunci';

  @override
  String get notifChannelCaregiver => 'Peringatan keluarga';

  @override
  String get loginTitle => 'Masuk';

  @override
  String get loginBody =>
      'Masuk agar keluarga bisa berbagi jadwal obat. Kami kirim tautan masuk ke email Anda.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get errEmail => 'Periksa kembali alamat email';

  @override
  String get sendCode => 'Kirim tautan';

  @override
  String get resendCode => 'Kirim ulang tautan';

  @override
  String codeSentTo(String email) {
    return 'Tautan terkirim ke $email. Buka email itu di ponsel ini lalu ketuk tautannya.';
  }

  @override
  String get errSendCode =>
      'Kode belum terkirim. Periksa koneksi internet lalu coba lagi.';

  @override
  String get errRateLimit =>
      'Batas pengiriman email tercapai. Tunggu sekitar satu jam, lalu coba lagi.';

  @override
  String get accountUnavailable =>
      'Layanan akun belum tersedia di versi aplikasi ini.';

  @override
  String get familyIntroTitle => 'Bagikan dengan keluarga';

  @override
  String get familyIntroBody =>
      'Masuk akun agar anggota keluarga bisa melihat jadwal obat dan diberi tahu jika dosis terlewat. Aplikasi tetap bisa dipakai tanpa akun.';

  @override
  String get signInAction => 'Masuk atau daftar';

  @override
  String get signOutAction => 'Keluar akun';

  @override
  String signedInAs(String email) {
    return 'Masuk sebagai $email';
  }

  @override
  String get familyNoneTitle => 'Belum ada keluarga';

  @override
  String get familyNoneBody =>
      'Buat keluarga baru, atau gabung dengan kode undangan dari anggota keluarga.';

  @override
  String get createFamilyAction => 'Buat keluarga';

  @override
  String get joinFamilyAction => 'Gabung dengan kode';

  @override
  String get fieldFamilyName => 'Nama keluarga';

  @override
  String get fieldYourName => 'Nama Anda di keluarga';

  @override
  String get errFamilyName => 'Periksa kembali nama keluarga';

  @override
  String get fieldInviteCode => 'Kode undangan';

  @override
  String get errInviteCode => 'Kode undangan terdiri dari 6 karakter';

  @override
  String get joinAction => 'Gabung';

  @override
  String get attachLocalTitle => 'Tambahkan data di perangkat ini?';

  @override
  String get attachLocalBody =>
      'Pasien dan obat yang sudah ada di perangkat ini akan dibagikan ke keluarga.';

  @override
  String get attachAction => 'Tambahkan';

  @override
  String get errInviteInvalid =>
      'Kode undangan tidak valid atau sudah kedaluwarsa.';

  @override
  String get errAlreadyMember => 'Anda sudah menjadi anggota keluarga ini.';

  @override
  String get errLastOwner =>
      'Keluarga harus punya minimal satu owner. Jadikan anggota lain owner dulu.';

  @override
  String get errForbidden => 'Anda tidak punya izin untuk tindakan ini.';

  @override
  String get errTooManyInvites =>
      'Terlalu banyak undangan aktif. Tunggu sampai ada yang kedaluwarsa.';

  @override
  String get errNetwork => 'Tidak ada koneksi. Coba lagi saat online.';

  @override
  String get membersTitle => 'Anggota';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleCaregiver => 'Pendamping';

  @override
  String get rolePatient => 'Pasien';

  @override
  String get youSuffix => '(Anda)';

  @override
  String get inviteAction => 'Undang anggota';

  @override
  String get inviteRole => 'Peran undangan';

  @override
  String get inviteCodeTitle => 'Kode undangan';

  @override
  String get inviteCodeHint => 'Berlaku 7 hari dan hanya bisa dipakai sekali.';

  @override
  String inviteShareText(String code) {
    return 'Gabung ke keluarga saya di Kizuvia. Kode undangan: $code. Atau buka kizuvia://invite/$code';
  }

  @override
  String get copyCode => 'Salin kode';

  @override
  String get shareCode => 'Bagikan';

  @override
  String get codeCopied => 'Kode disalin';

  @override
  String get changeRole => 'Ubah peran';

  @override
  String get removeMember => 'Keluarkan';

  @override
  String get removeMemberTitle => 'Keluarkan anggota?';

  @override
  String get removeMemberBody =>
      'Anggota ini tidak akan melihat data keluarga lagi.';

  @override
  String get leaveFamily => 'Keluar dari keluarga';

  @override
  String get leaveFamilyTitle => 'Keluar dari keluarga?';

  @override
  String get leaveFamilyBody =>
      'Anda tidak akan melihat data keluarga ini lagi. Data di perangkat tetap ada.';

  @override
  String get notifyMissedLabel => 'Beri tahu saya jika dosis terlewat';

  @override
  String get syncStatusSynced => 'Tersinkron';

  @override
  String syncStatusPending(int count) {
    return '$count perubahan menunggu dikirim';
  }

  @override
  String get syncStatusOffline =>
      'Offline. Perubahan akan dikirim saat online.';

  @override
  String get syncNow => 'Sinkronkan sekarang';

  @override
  String memberCount(int count) {
    return '$count anggota';
  }

  @override
  String pushMissedTitle(String patient) {
    return '$patient belum minum obat';
  }

  @override
  String get scanAction => 'Scan etiket';

  @override
  String get scanHint => 'Hasil scan hanya draf. Periksa sebelum menyimpan.';

  @override
  String get scanReview => 'Periksa kembali';

  @override
  String get scanDone => 'Hasil scan sudah terisi. Periksa sebelum menyimpan.';

  @override
  String get scanNothing =>
      'Teks etiket belum terbaca. Coba foto lebih dekat dan terang.';

  @override
  String get scanError => 'Scan belum berhasil. Isi manual atau coba lagi.';

  @override
  String get scanFromCamera => 'Foto dengan kamera';

  @override
  String get scanFromGallery => 'Pilih dari galeri';

  @override
  String get scanning => 'Membaca etiket';

  @override
  String get exportAction => 'Ekspor PDF untuk dokter';

  @override
  String get exportTitle => 'Ekspor laporan';

  @override
  String get exportPatient => 'Pasien';

  @override
  String exportRange(int days) {
    return 'Terakhir $days hari';
  }

  @override
  String get exportCreate => 'Buat PDF';

  @override
  String get exportError => 'PDF belum bisa dibuat. Coba lagi.';

  @override
  String get exportNoPatients => 'Tambahkan pasien terlebih dulu.';

  @override
  String get reportTitle => 'Laporan kepatuhan minum obat';

  @override
  String reportPatient(String name) {
    return 'Pasien: $name';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'Periode: $from - $to';
  }

  @override
  String reportGenerated(String date) {
    return 'Dibuat dengan Kizuvia pada $date';
  }

  @override
  String get reportSummary => 'Ringkasan';

  @override
  String get reportAdherence => 'Kepatuhan';

  @override
  String get reportTaken => 'Diminum';

  @override
  String get reportSkipped => 'Dilewati';

  @override
  String get reportMissed => 'Belum dikonfirmasi';

  @override
  String get reportMedColumn => 'Obat';

  @override
  String get reportScheduleColumn => 'Jadwal';

  @override
  String get reportDetail => 'Rincian dosis';

  @override
  String get reportDateColumn => 'Tanggal';

  @override
  String get reportTimeColumn => 'Jam';

  @override
  String get reportStatusColumn => 'Status';

  @override
  String get reportNoData => 'Tidak ada dosis tercatat pada periode ini.';

  @override
  String get familyDefaultName => 'Keluarga saya';
}
