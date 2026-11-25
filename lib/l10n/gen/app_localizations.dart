import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Kizuvia'**
  String get appName;

  /// No description provided for @taglineId.
  ///
  /// In id, this message translates to:
  /// **'Merawat, saling terhubung.'**
  String get taglineId;

  /// No description provided for @disclaimer.
  ///
  /// In id, this message translates to:
  /// **'Kizuvia adalah alat bantu pengingat. Aplikasi ini tidak memberikan saran medis. Selalu ikuti petunjuk dokter dan apoteker Anda.'**
  String get disclaimer;

  /// No description provided for @navToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get navToday;

  /// No description provided for @navPatients.
  ///
  /// In id, this message translates to:
  /// **'Pasien'**
  String get navPatients;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @navFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluarga'**
  String get navFamily;

  /// No description provided for @homeTitle.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada obat'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyAction.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan obat pertama'**
  String get homeEmptyAction;

  /// No description provided for @routeNotFound.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak ditemukan'**
  String get routeNotFound;

  /// No description provided for @routeNotFoundAction.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke beranda'**
  String get routeNotFoundAction;

  /// No description provided for @notifChannelAlarm.
  ///
  /// In id, this message translates to:
  /// **'Pengingat minum obat'**
  String get notifChannelAlarm;

  /// No description provided for @notifChannelFollowup.
  ///
  /// In id, this message translates to:
  /// **'Pengingat ulang'**
  String get notifChannelFollowup;

  /// No description provided for @notifChannelStock.
  ///
  /// In id, this message translates to:
  /// **'Stok obat'**
  String get notifChannelStock;

  /// No description provided for @notifTitle.
  ///
  /// In id, this message translates to:
  /// **'{patient}: waktunya minum obat'**
  String notifTitle(String patient);

  /// No description provided for @notifTitlePrivate.
  ///
  /// In id, this message translates to:
  /// **'Waktunya minum obat'**
  String get notifTitlePrivate;

  /// No description provided for @notifBodyPrivate.
  ///
  /// In id, this message translates to:
  /// **'{count} obat dijadwalkan pukul {time}'**
  String notifBodyPrivate(int count, String time);

  /// No description provided for @notifBodyGroup.
  ///
  /// In id, this message translates to:
  /// **'Waktunya minum {count} obat ({time}): {names}'**
  String notifBodyGroup(int count, String time, String names);

  /// No description provided for @notifFollowupTitle.
  ///
  /// In id, this message translates to:
  /// **'{patient}: obat belum dikonfirmasi'**
  String notifFollowupTitle(String patient);

  /// No description provided for @notifStockBody.
  ///
  /// In id, this message translates to:
  /// **'{name} tinggal {days} hari lagi. Jangan lupa tebus resep.'**
  String notifStockBody(String name, int days);

  /// No description provided for @actionTaken.
  ///
  /// In id, this message translates to:
  /// **'Sudah minum'**
  String get actionTaken;

  /// No description provided for @actionSnooze.
  ///
  /// In id, this message translates to:
  /// **'Tunda 10 menit'**
  String get actionSnooze;

  /// No description provided for @actionSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get actionSkip;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di Kizuvia'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Pengingat obat untuk keluarga. Alarm tetap berbunyi tanpa internet.'**
  String get onbWelcomeBody;

  /// No description provided for @consentLabel.
  ///
  /// In id, this message translates to:
  /// **'Saya setuju data kesehatan saya disimpan di perangkat ini dan, jika saya masuk akun, disinkronkan ke keluarga saya.'**
  String get consentLabel;

  /// No description provided for @consentRequired.
  ///
  /// In id, this message translates to:
  /// **'Centang persetujuan untuk melanjutkan'**
  String get consentRequired;

  /// No description provided for @continueAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get continueAction;

  /// No description provided for @startAction.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get startAction;

  /// No description provided for @skipForNow.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get skipForNow;

  /// No description provided for @permTitle.
  ///
  /// In id, this message translates to:
  /// **'Izinkan pengingat'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In id, this message translates to:
  /// **'Agar alarm obat berbunyi tepat waktu, Kizuvia perlu izin notifikasi dan alarm. Dua izin terakhir opsional, tapi membantu alarm tetap terdengar.'**
  String get permBody;

  /// No description provided for @permNotifAction.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get permNotifAction;

  /// No description provided for @permExactAction.
  ///
  /// In id, this message translates to:
  /// **'Izinkan alarm tepat waktu'**
  String get permExactAction;

  /// No description provided for @permGranted.
  ///
  /// In id, this message translates to:
  /// **'Sudah diizinkan'**
  String get permGranted;

  /// No description provided for @batteryTitle.
  ///
  /// In id, this message translates to:
  /// **'Agar alarm tidak terlewat'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In id, this message translates to:
  /// **'Beberapa ponsel menghentikan aplikasi di latar belakang. Ikuti langkah sesuai merek ponsel Anda.'**
  String get batteryBody;

  /// No description provided for @batteryXiaomi.
  ///
  /// In id, this message translates to:
  /// **'Xiaomi / Redmi / POCO: Pengaturan > Aplikasi > Kizuvia > Hemat baterai > Tanpa batasan. Aktifkan juga Mulai otomatis.'**
  String get batteryXiaomi;

  /// No description provided for @batteryOppo.
  ///
  /// In id, this message translates to:
  /// **'Oppo / Realme / OnePlus: Pengaturan > Baterai > Kizuvia > Izinkan aktivitas latar belakang. Aktifkan Mulai otomatis.'**
  String get batteryOppo;

  /// No description provided for @batteryVivo.
  ///
  /// In id, this message translates to:
  /// **'Vivo / iQOO: Pengaturan > Baterai > Konsumsi daya latar belakang > Kizuvia > Izinkan. Aktifkan Mulai otomatis.'**
  String get batteryVivo;

  /// No description provided for @batterySamsung.
  ///
  /// In id, this message translates to:
  /// **'Samsung: Pengaturan > Baterai > Batas penggunaan di latar belakang > Aplikasi yang tidak pernah tidur > tambahkan Kizuvia.'**
  String get batterySamsung;

  /// No description provided for @batteryOther.
  ///
  /// In id, this message translates to:
  /// **'Ponsel lain: Pengaturan > Aplikasi > Kizuvia > Baterai > Tanpa batasan.'**
  String get batteryOther;

  /// No description provided for @alarmHelpTitle.
  ///
  /// In id, this message translates to:
  /// **'Alarm tidak bunyi?'**
  String get alarmHelpTitle;

  /// No description provided for @bannerNotifOff.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi mati, alarm tidak akan muncul. Aktifkan izin notifikasi'**
  String get bannerNotifOff;

  /// No description provided for @bannerExactOff.
  ///
  /// In id, this message translates to:
  /// **'Alarm mungkin tidak berbunyi tepat waktu. Aktifkan izin alarm'**
  String get bannerExactOff;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get add;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi masalah saat menyimpan. Coba lagi.'**
  String get errorGeneric;

  /// No description provided for @loadError.
  ///
  /// In id, this message translates to:
  /// **'Data belum bisa dimuat. Coba lagi.'**
  String get loadError;

  /// No description provided for @patientsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pasien'**
  String get patientsTitle;

  /// No description provided for @patientsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pasien'**
  String get patientsEmpty;

  /// No description provided for @patientsEmptyAction.
  ///
  /// In id, this message translates to:
  /// **'Tambah pasien'**
  String get patientsEmptyAction;

  /// No description provided for @patientFormNew.
  ///
  /// In id, this message translates to:
  /// **'Tambah pasien'**
  String get patientFormNew;

  /// No description provided for @patientFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah pasien'**
  String get patientFormEdit;

  /// No description provided for @fieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get fieldName;

  /// No description provided for @fieldBirthYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun lahir'**
  String get fieldBirthYear;

  /// No description provided for @fieldConditions.
  ///
  /// In id, this message translates to:
  /// **'Kondisi (label, pisahkan dengan koma)'**
  String get fieldConditions;

  /// No description provided for @fieldNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get fieldNotes;

  /// No description provided for @errNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali nama'**
  String get errNameRequired;

  /// No description provided for @errBirthYear.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali tahun lahir'**
  String get errBirthYear;

  /// No description provided for @deletePatientTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus pasien?'**
  String get deletePatientTitle;

  /// No description provided for @deletePatientBody.
  ///
  /// In id, this message translates to:
  /// **'Pasien dan semua obatnya akan dihapus dari aplikasi.'**
  String get deletePatientBody;

  /// No description provided for @medsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada obat'**
  String get medsEmpty;

  /// No description provided for @addMed.
  ///
  /// In id, this message translates to:
  /// **'Tambah obat'**
  String get addMed;

  /// No description provided for @medFormNew.
  ///
  /// In id, this message translates to:
  /// **'Tambah obat'**
  String get medFormNew;

  /// No description provided for @medFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah obat'**
  String get medFormEdit;

  /// No description provided for @fieldMedName.
  ///
  /// In id, this message translates to:
  /// **'Nama obat'**
  String get fieldMedName;

  /// No description provided for @fieldStrength.
  ///
  /// In id, this message translates to:
  /// **'Kekuatan (mis. 10 mg)'**
  String get fieldStrength;

  /// No description provided for @fieldForm.
  ///
  /// In id, this message translates to:
  /// **'Bentuk'**
  String get fieldForm;

  /// No description provided for @fieldDoseQty.
  ///
  /// In id, this message translates to:
  /// **'Jumlah per dosis'**
  String get fieldDoseQty;

  /// No description provided for @fieldFrequency.
  ///
  /// In id, this message translates to:
  /// **'Frekuensi'**
  String get fieldFrequency;

  /// No description provided for @freq1.
  ///
  /// In id, this message translates to:
  /// **'1x sehari'**
  String get freq1;

  /// No description provided for @freq2.
  ///
  /// In id, this message translates to:
  /// **'2x sehari'**
  String get freq2;

  /// No description provided for @freq3.
  ///
  /// In id, this message translates to:
  /// **'3x sehari'**
  String get freq3;

  /// No description provided for @freq4.
  ///
  /// In id, this message translates to:
  /// **'4x sehari'**
  String get freq4;

  /// No description provided for @freqCustom.
  ///
  /// In id, this message translates to:
  /// **'Atur sendiri'**
  String get freqCustom;

  /// No description provided for @freqPrn.
  ///
  /// In id, this message translates to:
  /// **'Bila perlu'**
  String get freqPrn;

  /// No description provided for @fieldTimes.
  ///
  /// In id, this message translates to:
  /// **'Jam minum'**
  String get fieldTimes;

  /// No description provided for @addTime.
  ///
  /// In id, this message translates to:
  /// **'Tambah jam'**
  String get addTime;

  /// No description provided for @removeTime.
  ///
  /// In id, this message translates to:
  /// **'Hapus jam'**
  String get removeTime;

  /// No description provided for @fieldDays.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get fieldDays;

  /// No description provided for @dayMon.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get daySun;

  /// No description provided for @fieldMeal.
  ///
  /// In id, this message translates to:
  /// **'Relasi makan'**
  String get fieldMeal;

  /// No description provided for @mealBefore.
  ///
  /// In id, this message translates to:
  /// **'Sebelum makan'**
  String get mealBefore;

  /// No description provided for @mealAfter.
  ///
  /// In id, this message translates to:
  /// **'Sesudah makan'**
  String get mealAfter;

  /// No description provided for @mealWith.
  ///
  /// In id, this message translates to:
  /// **'Bersama makan'**
  String get mealWith;

  /// No description provided for @mealAny.
  ///
  /// In id, this message translates to:
  /// **'Bebas'**
  String get mealAny;

  /// No description provided for @fieldStartDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal mulai'**
  String get fieldStartDate;

  /// No description provided for @fieldEndDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal selesai'**
  String get fieldEndDate;

  /// No description provided for @noEndDate.
  ///
  /// In id, this message translates to:
  /// **'Tanpa tanggal selesai'**
  String get noEndDate;

  /// No description provided for @clearDate.
  ///
  /// In id, this message translates to:
  /// **'Hapus tanggal'**
  String get clearDate;

  /// No description provided for @fieldStock.
  ///
  /// In id, this message translates to:
  /// **'Stok saat ini'**
  String get fieldStock;

  /// No description provided for @fieldRefill.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan saat stok tersisa (hari)'**
  String get fieldRefill;

  /// No description provided for @fieldInstructions.
  ///
  /// In id, this message translates to:
  /// **'Instruksi atau catatan'**
  String get fieldInstructions;

  /// No description provided for @formTablet.
  ///
  /// In id, this message translates to:
  /// **'Tablet'**
  String get formTablet;

  /// No description provided for @formKapsul.
  ///
  /// In id, this message translates to:
  /// **'Kapsul'**
  String get formKapsul;

  /// No description provided for @formSirup.
  ///
  /// In id, this message translates to:
  /// **'Sirup'**
  String get formSirup;

  /// No description provided for @formTetes.
  ///
  /// In id, this message translates to:
  /// **'Tetes'**
  String get formTetes;

  /// No description provided for @formSalep.
  ///
  /// In id, this message translates to:
  /// **'Salep'**
  String get formSalep;

  /// No description provided for @formInjeksi.
  ///
  /// In id, this message translates to:
  /// **'Injeksi'**
  String get formInjeksi;

  /// No description provided for @formInhaler.
  ///
  /// In id, this message translates to:
  /// **'Inhaler'**
  String get formInhaler;

  /// No description provided for @formLainnya.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get formLainnya;

  /// No description provided for @fieldPhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto obat'**
  String get fieldPhoto;

  /// No description provided for @photoAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah foto'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get photoChange;

  /// No description provided for @photoRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get photoRemove;

  /// No description provided for @errMedName.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali nama obat'**
  String get errMedName;

  /// No description provided for @errDoseQty.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali jumlah per dosis'**
  String get errDoseQty;

  /// No description provided for @errNeedTime.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan minimal satu jam minum'**
  String get errNeedTime;

  /// No description provided for @errNeedDay.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu hari'**
  String get errNeedDay;

  /// No description provided for @reviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Periksa sebelum menyimpan'**
  String get reviewTitle;

  /// No description provided for @reviewHint.
  ///
  /// In id, this message translates to:
  /// **'Pastikan nama, kekuatan, dan jadwal sudah sesuai dengan etiket atau resep Anda.'**
  String get reviewHint;

  /// No description provided for @deleteMedTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus obat?'**
  String get deleteMedTitle;

  /// No description provided for @deleteMedBody.
  ///
  /// In id, this message translates to:
  /// **'Obat dan jadwalnya akan dihapus. Alarmnya ikut berhenti.'**
  String get deleteMedBody;

  /// No description provided for @selectItems.
  ///
  /// In id, this message translates to:
  /// **'Pilih'**
  String get selectItems;

  /// No description provided for @selectAll.
  ///
  /// In id, this message translates to:
  /// **'Pilih semua'**
  String get selectAll;

  /// No description provided for @cancelSelection.
  ///
  /// In id, this message translates to:
  /// **'Batalkan pilihan'**
  String get cancelSelection;

  /// No description provided for @selectedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} dipilih'**
  String selectedCount(int count);

  /// No description provided for @deletePatientsTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {count} pasien?'**
  String deletePatientsTitle(int count);

  /// No description provided for @deleteMedsTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {count} obat?'**
  String deleteMedsTitle(int count);

  /// No description provided for @medDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail obat'**
  String get medDetailTitle;

  /// No description provided for @scheduleSummary.
  ///
  /// In id, this message translates to:
  /// **'Jam {times}'**
  String scheduleSummary(String times);

  /// No description provided for @daysEveryDay.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari'**
  String get daysEveryDay;

  /// No description provided for @prnNote.
  ///
  /// In id, this message translates to:
  /// **'Bila perlu: tidak ada alarm.'**
  String get prnNote;

  /// No description provided for @stockLeft.
  ///
  /// In id, this message translates to:
  /// **'Stok: {qty}'**
  String stockLeft(String qty);

  /// No description provided for @stockDaysLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa sekitar {days} hari'**
  String stockDaysLeft(int days);

  /// No description provided for @stockLow.
  ///
  /// In id, this message translates to:
  /// **'{name} tinggal {days} hari lagi. Jangan lupa tebus resep.'**
  String stockLow(String name, int days);

  /// No description provided for @stockUnknown.
  ///
  /// In id, this message translates to:
  /// **'Stok belum diisi'**
  String get stockUnknown;

  /// No description provided for @restock.
  ///
  /// In id, this message translates to:
  /// **'Tambah stok'**
  String get restock;

  /// No description provided for @restockQty.
  ///
  /// In id, this message translates to:
  /// **'Jumlah yang ditambahkan'**
  String get restockQty;

  /// No description provided for @lowStockBadge.
  ///
  /// In id, this message translates to:
  /// **'Stok menipis'**
  String get lowStockBadge;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada obat'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan pasien dan obat pertama untuk mulai.'**
  String get todayEmptyBody;

  /// No description provided for @todayNothing.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada dosis terjadwal hari ini'**
  String get todayNothing;

  /// No description provided for @statusUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Akan datang'**
  String get statusUpcoming;

  /// No description provided for @statusNow.
  ///
  /// In id, this message translates to:
  /// **'Sekarang'**
  String get statusNow;

  /// No description provided for @statusTaken.
  ///
  /// In id, this message translates to:
  /// **'Diminum'**
  String get statusTaken;

  /// No description provided for @statusSkipped.
  ///
  /// In id, this message translates to:
  /// **'Dilewati'**
  String get statusSkipped;

  /// No description provided for @statusMissed.
  ///
  /// In id, this message translates to:
  /// **'Belum dikonfirmasi'**
  String get statusMissed;

  /// No description provided for @takenAction.
  ///
  /// In id, this message translates to:
  /// **'Sudah minum'**
  String get takenAction;

  /// No description provided for @skipAction.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get skipAction;

  /// No description provided for @confirmedTaken.
  ///
  /// In id, this message translates to:
  /// **'Tercatat. {name} diminum {time}'**
  String confirmedTaken(String name, String time);

  /// No description provided for @confirmedSkipped.
  ///
  /// In id, this message translates to:
  /// **'Dosis {name} dilewati'**
  String confirmedSkipped(String name);

  /// No description provided for @doseDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail dosis'**
  String get doseDetailTitle;

  /// No description provided for @doseNotFound.
  ///
  /// In id, this message translates to:
  /// **'Dosis tidak ditemukan'**
  String get doseNotFound;

  /// No description provided for @scheduledFor.
  ///
  /// In id, this message translates to:
  /// **'Jadwal {time}'**
  String scheduledFor(String time);

  /// No description provided for @allDoneToday.
  ///
  /// In id, this message translates to:
  /// **'Semua dosis hari ini sudah tercatat'**
  String get allDoneToday;

  /// No description provided for @scanNotLabel.
  ///
  /// In id, this message translates to:
  /// **'Foto ini sepertinya bukan etiket atau kemasan obat. Coba foto ulang.'**
  String get scanNotLabel;

  /// No description provided for @widgetNext.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya {time}'**
  String widgetNext(String time);

  /// No description provided for @widgetNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada dosis berikutnya'**
  String get widgetNone;

  /// No description provided for @widgetPrivateBody.
  ///
  /// In id, this message translates to:
  /// **'Obat dijadwalkan'**
  String get widgetPrivateBody;

  /// No description provided for @appLock.
  ///
  /// In id, this message translates to:
  /// **'Kunci aplikasi'**
  String get appLock;

  /// No description provided for @appLockHint.
  ///
  /// In id, this message translates to:
  /// **'Minta sidik jari, wajah, atau PIN HP saat membuka aplikasi. Alarm minum obat tetap bisa dibuka.'**
  String get appLockHint;

  /// No description provided for @appLockReason.
  ///
  /// In id, this message translates to:
  /// **'Buka Kizuvia'**
  String get appLockReason;

  /// No description provided for @appLockTitle.
  ///
  /// In id, this message translates to:
  /// **'Kizuvia terkunci'**
  String get appLockTitle;

  /// No description provided for @appLockUnlock.
  ///
  /// In id, this message translates to:
  /// **'Buka kunci'**
  String get appLockUnlock;

  /// No description provided for @appLockUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Atur kunci layar (PIN, pola, atau sidik jari) di HP terlebih dahulu.'**
  String get appLockUnavailable;

  /// No description provided for @educationTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang kondisi'**
  String get educationTitle;

  /// No description provided for @educationEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada informasi untuk kondisi yang tercatat. Tambahkan kondisi seperti hipertensi, diabetes, kolesterol, atau jantung di data pasien.'**
  String get educationEmpty;

  /// No description provided for @educationSources.
  ///
  /// In id, this message translates to:
  /// **'Sumber'**
  String get educationSources;

  /// No description provided for @elderlyNextDose.
  ///
  /// In id, this message translates to:
  /// **'Obat berikutnya'**
  String get elderlyNextDose;

  /// No description provided for @elderlyMoreAtSameTime.
  ///
  /// In id, this message translates to:
  /// **'Masih ada {count} obat lain pada jam ini'**
  String elderlyMoreAtSameTime(int count);

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat dosis'**
  String get historyEmpty;

  /// No description provided for @adherenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Kepatuhan {days} hari: {percent}%'**
  String adherenceLabel(int days, int percent);

  /// No description provided for @adherenceNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data kepatuhan'**
  String get adherenceNone;

  /// No description provided for @legendAll.
  ///
  /// In id, this message translates to:
  /// **'Semua diminum'**
  String get legendAll;

  /// No description provided for @legendPartial.
  ///
  /// In id, this message translates to:
  /// **'Sebagian'**
  String get legendPartial;

  /// No description provided for @legendMissed.
  ///
  /// In id, this message translates to:
  /// **'Ada yang belum dikonfirmasi'**
  String get legendMissed;

  /// No description provided for @legendNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jadwal'**
  String get legendNone;

  /// No description provided for @perMedication.
  ///
  /// In id, this message translates to:
  /// **'Per obat'**
  String get perMedication;

  /// No description provided for @familyTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluarga'**
  String get familyTitle;

  /// No description provided for @familyPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Berbagi dengan keluarga tersedia setelah Anda masuk akun. Fitur ini segera hadir.'**
  String get familyPlaceholder;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @elderlyMode.
  ///
  /// In id, this message translates to:
  /// **'Mode lansia'**
  String get elderlyMode;

  /// No description provided for @elderlyModeHint.
  ///
  /// In id, this message translates to:
  /// **'Teks dan tombol lebih besar'**
  String get elderlyModeHint;

  /// No description provided for @privacyLock.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan nama di layar kunci'**
  String get privacyLock;

  /// No description provided for @privacyLockHint.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi tidak menampilkan nama pasien dan obat'**
  String get privacyLockHint;

  /// No description provided for @permDndAction.
  ///
  /// In id, this message translates to:
  /// **'Izinkan alarm saat mode Jangan Ganggu'**
  String get permDndAction;

  /// No description provided for @permFullScreenAction.
  ///
  /// In id, this message translates to:
  /// **'Izinkan alarm tampil di layar kunci'**
  String get permFullScreenAction;

  /// No description provided for @notifChannelCaregiver.
  ///
  /// In id, this message translates to:
  /// **'Peringatan keluarga'**
  String get notifChannelCaregiver;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In id, this message translates to:
  /// **'Masuk agar keluarga bisa berbagi jadwal obat. Kami kirim tautan masuk ke email Anda.'**
  String get loginBody;

  /// No description provided for @fieldEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @errEmail.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali alamat email'**
  String get errEmail;

  /// No description provided for @sendCode.
  ///
  /// In id, this message translates to:
  /// **'Kirim tautan'**
  String get sendCode;

  /// No description provided for @resendCode.
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang tautan'**
  String get resendCode;

  /// No description provided for @codeSentTo.
  ///
  /// In id, this message translates to:
  /// **'Tautan terkirim ke {email}. Buka email itu di ponsel ini lalu ketuk tautannya.'**
  String codeSentTo(String email);

  /// No description provided for @errSendCode.
  ///
  /// In id, this message translates to:
  /// **'Kode belum terkirim. Periksa koneksi internet lalu coba lagi.'**
  String get errSendCode;

  /// No description provided for @errRateLimit.
  ///
  /// In id, this message translates to:
  /// **'Batas pengiriman email tercapai. Tunggu sekitar satu jam, lalu coba lagi.'**
  String get errRateLimit;

  /// No description provided for @accountUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Layanan akun belum tersedia di versi aplikasi ini.'**
  String get accountUnavailable;

  /// No description provided for @familyIntroTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan dengan keluarga'**
  String get familyIntroTitle;

  /// No description provided for @familyIntroBody.
  ///
  /// In id, this message translates to:
  /// **'Masuk akun agar anggota keluarga bisa melihat jadwal obat dan diberi tahu jika dosis terlewat. Aplikasi tetap bisa dipakai tanpa akun.'**
  String get familyIntroBody;

  /// No description provided for @signInAction.
  ///
  /// In id, this message translates to:
  /// **'Masuk atau daftar'**
  String get signInAction;

  /// No description provided for @signOutAction.
  ///
  /// In id, this message translates to:
  /// **'Keluar akun'**
  String get signOutAction;

  /// No description provided for @signedInAs.
  ///
  /// In id, this message translates to:
  /// **'Masuk sebagai {email}'**
  String signedInAs(String email);

  /// No description provided for @familyNoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada keluarga'**
  String get familyNoneTitle;

  /// No description provided for @familyNoneBody.
  ///
  /// In id, this message translates to:
  /// **'Buat keluarga baru, atau gabung dengan kode undangan dari anggota keluarga.'**
  String get familyNoneBody;

  /// No description provided for @createFamilyAction.
  ///
  /// In id, this message translates to:
  /// **'Buat keluarga'**
  String get createFamilyAction;

  /// No description provided for @joinFamilyAction.
  ///
  /// In id, this message translates to:
  /// **'Gabung dengan kode'**
  String get joinFamilyAction;

  /// No description provided for @fieldFamilyName.
  ///
  /// In id, this message translates to:
  /// **'Nama keluarga'**
  String get fieldFamilyName;

  /// No description provided for @fieldYourName.
  ///
  /// In id, this message translates to:
  /// **'Nama Anda di keluarga'**
  String get fieldYourName;

  /// No description provided for @errFamilyName.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali nama keluarga'**
  String get errFamilyName;

  /// No description provided for @fieldInviteCode.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan'**
  String get fieldInviteCode;

  /// No description provided for @errInviteCode.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan terdiri dari 6 karakter'**
  String get errInviteCode;

  /// No description provided for @joinAction.
  ///
  /// In id, this message translates to:
  /// **'Gabung'**
  String get joinAction;

  /// No description provided for @attachLocalTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan data di perangkat ini?'**
  String get attachLocalTitle;

  /// No description provided for @attachLocalBody.
  ///
  /// In id, this message translates to:
  /// **'Pasien dan obat yang sudah ada di perangkat ini akan dibagikan ke keluarga.'**
  String get attachLocalBody;

  /// No description provided for @attachAction.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan'**
  String get attachAction;

  /// No description provided for @errInviteInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan tidak valid atau sudah kedaluwarsa.'**
  String get errInviteInvalid;

  /// No description provided for @errAlreadyMember.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah menjadi anggota keluarga ini.'**
  String get errAlreadyMember;

  /// No description provided for @errLastOwner.
  ///
  /// In id, this message translates to:
  /// **'Keluarga harus punya minimal satu owner. Jadikan anggota lain owner dulu.'**
  String get errLastOwner;

  /// No description provided for @errForbidden.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk tindakan ini.'**
  String get errForbidden;

  /// No description provided for @errTooManyInvites.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak undangan aktif. Tunggu sampai ada yang kedaluwarsa.'**
  String get errTooManyInvites;

  /// No description provided for @errNetwork.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi. Coba lagi saat online.'**
  String get errNetwork;

  /// No description provided for @membersTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggota'**
  String get membersTitle;

  /// No description provided for @roleOwner.
  ///
  /// In id, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleCaregiver.
  ///
  /// In id, this message translates to:
  /// **'Pendamping'**
  String get roleCaregiver;

  /// No description provided for @rolePatient.
  ///
  /// In id, this message translates to:
  /// **'Pasien'**
  String get rolePatient;

  /// No description provided for @youSuffix.
  ///
  /// In id, this message translates to:
  /// **'(Anda)'**
  String get youSuffix;

  /// No description provided for @inviteAction.
  ///
  /// In id, this message translates to:
  /// **'Undang anggota'**
  String get inviteAction;

  /// No description provided for @inviteRole.
  ///
  /// In id, this message translates to:
  /// **'Peran undangan'**
  String get inviteRole;

  /// No description provided for @inviteCodeTitle.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan'**
  String get inviteCodeTitle;

  /// No description provided for @inviteCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Berlaku 7 hari dan hanya bisa dipakai sekali.'**
  String get inviteCodeHint;

  /// No description provided for @inviteShareText.
  ///
  /// In id, this message translates to:
  /// **'Gabung ke keluarga saya di Kizuvia. Kode undangan: {code}. Atau buka kizuvia://invite/{code}'**
  String inviteShareText(String code);

  /// No description provided for @copyCode.
  ///
  /// In id, this message translates to:
  /// **'Salin kode'**
  String get copyCode;

  /// No description provided for @shareCode.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get shareCode;

  /// No description provided for @codeCopied.
  ///
  /// In id, this message translates to:
  /// **'Kode disalin'**
  String get codeCopied;

  /// No description provided for @changeRole.
  ///
  /// In id, this message translates to:
  /// **'Ubah peran'**
  String get changeRole;

  /// No description provided for @removeMember.
  ///
  /// In id, this message translates to:
  /// **'Keluarkan'**
  String get removeMember;

  /// No description provided for @removeMemberTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluarkan anggota?'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberBody.
  ///
  /// In id, this message translates to:
  /// **'Anggota ini tidak akan melihat data keluarga lagi.'**
  String get removeMemberBody;

  /// No description provided for @leaveFamily.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari keluarga'**
  String get leaveFamily;

  /// No description provided for @leaveFamilyTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari keluarga?'**
  String get leaveFamilyTitle;

  /// No description provided for @leaveFamilyBody.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak akan melihat data keluarga ini lagi. Data di perangkat tetap ada.'**
  String get leaveFamilyBody;

  /// No description provided for @notifyMissedLabel.
  ///
  /// In id, this message translates to:
  /// **'Beri tahu saya jika dosis terlewat'**
  String get notifyMissedLabel;

  /// No description provided for @syncStatusSynced.
  ///
  /// In id, this message translates to:
  /// **'Tersinkron'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusPending.
  ///
  /// In id, this message translates to:
  /// **'{count} perubahan menunggu dikirim'**
  String syncStatusPending(int count);

  /// No description provided for @syncStatusOffline.
  ///
  /// In id, this message translates to:
  /// **'Offline. Perubahan akan dikirim saat online.'**
  String get syncStatusOffline;

  /// No description provided for @syncNow.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan sekarang'**
  String get syncNow;

  /// No description provided for @memberCount.
  ///
  /// In id, this message translates to:
  /// **'{count} anggota'**
  String memberCount(int count);

  /// No description provided for @pushMissedTitle.
  ///
  /// In id, this message translates to:
  /// **'{patient} belum minum obat'**
  String pushMissedTitle(String patient);

  /// No description provided for @scanAction.
  ///
  /// In id, this message translates to:
  /// **'Scan etiket'**
  String get scanAction;

  /// No description provided for @scanHint.
  ///
  /// In id, this message translates to:
  /// **'Hasil scan hanya draf. Periksa sebelum menyimpan.'**
  String get scanHint;

  /// No description provided for @scanReview.
  ///
  /// In id, this message translates to:
  /// **'Periksa kembali'**
  String get scanReview;

  /// No description provided for @scanDone.
  ///
  /// In id, this message translates to:
  /// **'Hasil scan sudah terisi. Periksa sebelum menyimpan.'**
  String get scanDone;

  /// No description provided for @scanNothing.
  ///
  /// In id, this message translates to:
  /// **'Teks etiket belum terbaca. Coba foto lebih dekat dan terang.'**
  String get scanNothing;

  /// No description provided for @scanError.
  ///
  /// In id, this message translates to:
  /// **'Scan belum berhasil. Isi manual atau coba lagi.'**
  String get scanError;

  /// No description provided for @scanFromCamera.
  ///
  /// In id, this message translates to:
  /// **'Foto dengan kamera'**
  String get scanFromCamera;

  /// No description provided for @scanFromGallery.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari galeri'**
  String get scanFromGallery;

  /// No description provided for @scanning.
  ///
  /// In id, this message translates to:
  /// **'Membaca etiket'**
  String get scanning;

  /// No description provided for @exportAction.
  ///
  /// In id, this message translates to:
  /// **'Ekspor PDF untuk dokter'**
  String get exportAction;

  /// No description provided for @exportTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor laporan'**
  String get exportTitle;

  /// No description provided for @exportPatient.
  ///
  /// In id, this message translates to:
  /// **'Pasien'**
  String get exportPatient;

  /// No description provided for @exportRange.
  ///
  /// In id, this message translates to:
  /// **'Terakhir {days} hari'**
  String exportRange(int days);

  /// No description provided for @exportCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat PDF'**
  String get exportCreate;

  /// No description provided for @exportError.
  ///
  /// In id, this message translates to:
  /// **'PDF belum bisa dibuat. Coba lagi.'**
  String get exportError;

  /// No description provided for @exportNoPatients.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan pasien terlebih dulu.'**
  String get exportNoPatients;

  /// No description provided for @reportTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan kepatuhan minum obat'**
  String get reportTitle;

  /// No description provided for @reportPatient.
  ///
  /// In id, this message translates to:
  /// **'Pasien: {name}'**
  String reportPatient(String name);

  /// No description provided for @reportPeriod.
  ///
  /// In id, this message translates to:
  /// **'Periode: {from} - {to}'**
  String reportPeriod(String from, String to);

  /// No description provided for @reportGenerated.
  ///
  /// In id, this message translates to:
  /// **'Dibuat dengan Kizuvia pada {date}'**
  String reportGenerated(String date);

  /// No description provided for @reportSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get reportSummary;

  /// No description provided for @reportAdherence.
  ///
  /// In id, this message translates to:
  /// **'Kepatuhan'**
  String get reportAdherence;

  /// No description provided for @reportTaken.
  ///
  /// In id, this message translates to:
  /// **'Diminum'**
  String get reportTaken;

  /// No description provided for @reportSkipped.
  ///
  /// In id, this message translates to:
  /// **'Dilewati'**
  String get reportSkipped;

  /// No description provided for @reportMissed.
  ///
  /// In id, this message translates to:
  /// **'Belum dikonfirmasi'**
  String get reportMissed;

  /// No description provided for @reportMedColumn.
  ///
  /// In id, this message translates to:
  /// **'Obat'**
  String get reportMedColumn;

  /// No description provided for @reportScheduleColumn.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get reportScheduleColumn;

  /// No description provided for @reportDetail.
  ///
  /// In id, this message translates to:
  /// **'Rincian dosis'**
  String get reportDetail;

  /// No description provided for @reportDateColumn.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get reportDateColumn;

  /// No description provided for @reportTimeColumn.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get reportTimeColumn;

  /// No description provided for @reportStatusColumn.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get reportStatusColumn;

  /// No description provided for @reportNoData.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada dosis tercatat pada periode ini.'**
  String get reportNoData;

  /// No description provided for @familyDefaultName.
  ///
  /// In id, this message translates to:
  /// **'Keluarga saya'**
  String get familyDefaultName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
