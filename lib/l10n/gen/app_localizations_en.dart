// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kizuvia';

  @override
  String get taglineId => 'Caring, connected.';

  @override
  String get disclaimer =>
      'Kizuvia is a reminder tool. It does not give medical advice. Always follow the instructions of your doctor and pharmacist.';

  @override
  String get navToday => 'Today';

  @override
  String get navPatients => 'Patients';

  @override
  String get navHistory => 'History';

  @override
  String get navFamily => 'Family';

  @override
  String get homeTitle => 'Today';

  @override
  String get homeEmptyTitle => 'No medications yet';

  @override
  String get homeEmptyAction => 'Add the first medication';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get routeNotFoundAction => 'Back to home';

  @override
  String get notifChannelAlarm => 'Medication reminders';

  @override
  String get notifChannelFollowup => 'Repeat reminders';

  @override
  String get notifChannelStock => 'Medication stock';

  @override
  String notifTitle(String patient) {
    return '$patient: time to take medication';
  }

  @override
  String get notifTitlePrivate => 'Time to take medication';

  @override
  String notifBodyPrivate(int count, String time) {
    return '$count medications scheduled at $time';
  }

  @override
  String notifBodyGroup(int count, String time, String names) {
    return 'Time to take $count medications ($time): $names';
  }

  @override
  String notifFollowupTitle(String patient) {
    return '$patient: medication not confirmed';
  }

  @override
  String notifStockBody(String name, int days) {
    return '$name has $days days left. Remember to refill.';
  }

  @override
  String get actionTaken => 'Taken';

  @override
  String get actionSnooze => 'Snooze 10 min';

  @override
  String get actionSkip => 'Skip';

  @override
  String get onbWelcomeTitle => 'Welcome to Kizuvia';

  @override
  String get onbWelcomeBody =>
      'Medication reminders for your family. Alarms still ring without internet.';

  @override
  String get consentLabel =>
      'I agree that my health data is stored on this device and, if I sign in, synced to my family.';

  @override
  String get consentRequired => 'Tick the consent box to continue';

  @override
  String get continueAction => 'Continue';

  @override
  String get startAction => 'Start';

  @override
  String get skipForNow => 'Not now';

  @override
  String get permTitle => 'Allow reminders';

  @override
  String get permBody =>
      'For medication alarms to ring on time, Kizuvia needs notification and alarm permissions. The last two are optional but help alarms stay audible.';

  @override
  String get permNotifAction => 'Allow notifications';

  @override
  String get permExactAction => 'Allow exact alarms';

  @override
  String get permGranted => 'Allowed';

  @override
  String get batteryTitle => 'So alarms are not missed';

  @override
  String get batteryBody =>
      'Some phones stop apps in the background. Follow the steps for your phone brand.';

  @override
  String get batteryXiaomi =>
      'Xiaomi / Redmi / POCO: Settings > Apps > Kizuvia > Battery saver > No restrictions. Also enable Autostart.';

  @override
  String get batteryOppo =>
      'Oppo / Realme / OnePlus: Settings > Battery > Kizuvia > Allow background activity. Enable Autostart.';

  @override
  String get batteryVivo =>
      'Vivo / iQOO: Settings > Battery > Background power consumption > Kizuvia > Allow. Enable Autostart.';

  @override
  String get batterySamsung =>
      'Samsung: Settings > Battery > Background usage limits > Never sleeping apps > add Kizuvia.';

  @override
  String get batteryOther =>
      'Other phones: Settings > Apps > Kizuvia > Battery > Unrestricted.';

  @override
  String get alarmHelpTitle => 'Alarm not ringing?';

  @override
  String get bannerNotifOff =>
      'Notifications are off, alarms will not appear. Enable notification permission';

  @override
  String get bannerExactOff =>
      'Alarms may not ring on time. Enable alarm permission';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Try again';

  @override
  String get errorGeneric => 'Something went wrong while saving. Try again.';

  @override
  String get loadError => 'Data could not be loaded. Try again.';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsEmpty => 'No patients yet';

  @override
  String get patientsEmptyAction => 'Add patient';

  @override
  String get patientFormNew => 'Add patient';

  @override
  String get patientFormEdit => 'Edit patient';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldBirthYear => 'Birth year';

  @override
  String get fieldConditions => 'Conditions (labels, separated by commas)';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get errNameRequired => 'Check the name';

  @override
  String get errBirthYear => 'Check the birth year';

  @override
  String get deletePatientTitle => 'Delete patient?';

  @override
  String get deletePatientBody =>
      'The patient and all their medications will be removed from the app.';

  @override
  String get medsEmpty => 'No medications yet';

  @override
  String get addMed => 'Add medication';

  @override
  String get medFormNew => 'Add medication';

  @override
  String get medFormEdit => 'Edit medication';

  @override
  String get fieldMedName => 'Medication name';

  @override
  String get fieldStrength => 'Strength (e.g. 10 mg)';

  @override
  String get fieldForm => 'Form';

  @override
  String get fieldDoseQty => 'Amount per dose';

  @override
  String get fieldFrequency => 'Frequency';

  @override
  String get freq1 => '1x a day';

  @override
  String get freq2 => '2x a day';

  @override
  String get freq3 => '3x a day';

  @override
  String get freq4 => '4x a day';

  @override
  String get freqCustom => 'Custom';

  @override
  String get freqPrn => 'As needed';

  @override
  String get fieldTimes => 'Times';

  @override
  String get addTime => 'Add time';

  @override
  String get removeTime => 'Remove time';

  @override
  String get fieldDays => 'Days';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get fieldMeal => 'Relation to meals';

  @override
  String get mealBefore => 'Before meals';

  @override
  String get mealAfter => 'After meals';

  @override
  String get mealWith => 'With meals';

  @override
  String get mealAny => 'Any time';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get fieldEndDate => 'End date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get fieldStock => 'Current stock';

  @override
  String get fieldRefill => 'Remind when stock is down to (days)';

  @override
  String get fieldInstructions => 'Instructions or notes';

  @override
  String get formTablet => 'Tablet';

  @override
  String get formKapsul => 'Capsule';

  @override
  String get formSirup => 'Syrup';

  @override
  String get formTetes => 'Drops';

  @override
  String get formSalep => 'Ointment';

  @override
  String get formInjeksi => 'Injection';

  @override
  String get formInhaler => 'Inhaler';

  @override
  String get formLainnya => 'Other';

  @override
  String get fieldPhoto => 'Medication photo';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoChange => 'Change photo';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get errMedName => 'Check the medication name';

  @override
  String get errDoseQty => 'Check the amount per dose';

  @override
  String get errNeedTime => 'Add at least one time';

  @override
  String get errNeedDay => 'Select at least one day';

  @override
  String get reviewTitle => 'Review before saving';

  @override
  String get reviewHint =>
      'Make sure the name, strength and schedule match your label or prescription.';

  @override
  String get deleteMedTitle => 'Delete medication?';

  @override
  String get deleteMedBody =>
      'The medication and its schedule will be deleted. Its alarms stop too.';

  @override
  String get selectItems => 'Select';

  @override
  String get selectAll => 'Select all';

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String deletePatientsTitle(int count) {
    return 'Delete $count patients?';
  }

  @override
  String deleteMedsTitle(int count) {
    return 'Delete $count medications?';
  }

  @override
  String get medDetailTitle => 'Medication details';

  @override
  String scheduleSummary(String times) {
    return 'At $times';
  }

  @override
  String get daysEveryDay => 'Every day';

  @override
  String get prnNote => 'As needed: no alarm.';

  @override
  String stockLeft(String qty) {
    return 'Stock: $qty';
  }

  @override
  String stockDaysLeft(int days) {
    return 'About $days days left';
  }

  @override
  String stockLow(String name, int days) {
    return '$name has $days days left. Remember to refill.';
  }

  @override
  String get stockUnknown => 'Stock not entered';

  @override
  String get restock => 'Add stock';

  @override
  String get restockQty => 'Amount to add';

  @override
  String get lowStockBadge => 'Low stock';

  @override
  String get filterAll => 'All';

  @override
  String get todayEmptyTitle => 'No medications yet';

  @override
  String get todayEmptyBody =>
      'Add a patient and the first medication to get started.';

  @override
  String get todayNothing => 'No doses scheduled today';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusNow => 'Now';

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusMissed => 'Not confirmed';

  @override
  String get takenAction => 'Taken';

  @override
  String get skipAction => 'Skip';

  @override
  String confirmedTaken(String name, String time) {
    return 'Recorded. $name taken at $time';
  }

  @override
  String confirmedSkipped(String name) {
    return '$name dose skipped';
  }

  @override
  String get doseDetailTitle => 'Dose details';

  @override
  String get doseNotFound => 'Dose not found';

  @override
  String scheduledFor(String time) {
    return 'Scheduled $time';
  }

  @override
  String get allDoneToday => 'All of today\'s doses are recorded';

  @override
  String get scanNotLabel =>
      'This photo does not look like a medication label or package. Try again.';

  @override
  String widgetNext(String time) {
    return 'Next $time';
  }

  @override
  String get widgetNone => 'No next dose';

  @override
  String get widgetPrivateBody => 'Medication scheduled';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockHint =>
      'Ask for fingerprint, face or phone PIN when opening the app. Medication alarms can still be opened.';

  @override
  String get appLockReason => 'Open Kizuvia';

  @override
  String get appLockTitle => 'Kizuvia is locked';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockUnavailable =>
      'Set up a screen lock (PIN, pattern or fingerprint) on your phone first.';

  @override
  String get educationTitle => 'About the condition';

  @override
  String get educationEmpty =>
      'No information for the recorded conditions yet. Add a condition such as hypertension, diabetes, cholesterol or heart disease to the patient.';

  @override
  String get educationSources => 'Sources';

  @override
  String get elderlyNextDose => 'Next medication';

  @override
  String elderlyMoreAtSameTime(int count) {
    return '$count more medications at this time';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No dose history yet';

  @override
  String adherenceLabel(int days, int percent) {
    return '$days-day adherence: $percent%';
  }

  @override
  String get adherenceNone => 'No adherence data yet';

  @override
  String get legendAll => 'All taken';

  @override
  String get legendPartial => 'Partial';

  @override
  String get legendMissed => 'Some not confirmed';

  @override
  String get legendNone => 'No schedule';

  @override
  String get perMedication => 'Per medication';

  @override
  String get familyTitle => 'Family';

  @override
  String get familyPlaceholder =>
      'Family sharing is available after you sign in. Coming soon.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get elderlyMode => 'Elderly mode';

  @override
  String get elderlyModeHint => 'Larger text and buttons';

  @override
  String get privacyLock => 'Hide names on lock screen';

  @override
  String get privacyLockHint =>
      'Notifications do not show patient and medication names';

  @override
  String get permDndAction => 'Allow alarms in Do Not Disturb';

  @override
  String get permFullScreenAction => 'Allow alarms on the lock screen';

  @override
  String get notifChannelCaregiver => 'Family alerts';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginBody =>
      'Sign in so your family can share the medication schedule. We send a sign-in link to your email.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get errEmail => 'Check the email address';

  @override
  String get sendCode => 'Send link';

  @override
  String get resendCode => 'Resend link';

  @override
  String codeSentTo(String email) {
    return 'Link sent to $email. Open that email on this phone and tap the link.';
  }

  @override
  String get errSendCode =>
      'The link was not sent. Check your internet connection and try again.';

  @override
  String get errRateLimit =>
      'Email sending limit reached. Wait about an hour, then try again.';

  @override
  String get accountUnavailable =>
      'Account service is not available in this app version.';

  @override
  String get familyIntroTitle => 'Share with family';

  @override
  String get familyIntroBody =>
      'Sign in so family members can see the medication schedule and be notified when a dose is missed. The app still works without an account.';

  @override
  String get signInAction => 'Sign in or sign up';

  @override
  String get signOutAction => 'Sign out';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get familyNoneTitle => 'No family yet';

  @override
  String get familyNoneBody =>
      'Create a new family, or join with an invite code from a family member.';

  @override
  String get createFamilyAction => 'Create family';

  @override
  String get joinFamilyAction => 'Join with code';

  @override
  String get fieldFamilyName => 'Family name';

  @override
  String get fieldYourName => 'Your name in the family';

  @override
  String get errFamilyName => 'Check the family name';

  @override
  String get fieldInviteCode => 'Invite code';

  @override
  String get errInviteCode => 'The invite code has 6 characters';

  @override
  String get joinAction => 'Join';

  @override
  String get attachLocalTitle => 'Add data on this device?';

  @override
  String get attachLocalBody =>
      'Patients and medications already on this device will be shared with the family.';

  @override
  String get attachAction => 'Add';

  @override
  String get errInviteInvalid => 'The invite code is invalid or has expired.';

  @override
  String get errAlreadyMember => 'You are already a member of this family.';

  @override
  String get errLastOwner =>
      'A family needs at least one owner. Make another member an owner first.';

  @override
  String get errForbidden => 'You do not have permission for this action.';

  @override
  String get errTooManyInvites =>
      'Too many active invites. Wait until one expires.';

  @override
  String get errNetwork => 'No connection. Try again when online.';

  @override
  String get membersTitle => 'Members';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleCaregiver => 'Caregiver';

  @override
  String get rolePatient => 'Patient';

  @override
  String get youSuffix => '(You)';

  @override
  String get inviteAction => 'Invite member';

  @override
  String get inviteRole => 'Invite role';

  @override
  String get inviteCodeTitle => 'Invite code';

  @override
  String get inviteCodeHint => 'Valid for 7 days and can be used once.';

  @override
  String inviteShareText(String code) {
    return 'Join my family on Kizuvia. Invite code: $code. Or open kizuvia://invite/$code';
  }

  @override
  String get copyCode => 'Copy code';

  @override
  String get shareCode => 'Share';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get changeRole => 'Change role';

  @override
  String get removeMember => 'Remove';

  @override
  String get removeMemberTitle => 'Remove member?';

  @override
  String get removeMemberBody =>
      'This member will no longer see the family\'s data.';

  @override
  String get leaveFamily => 'Leave family';

  @override
  String get leaveFamilyTitle => 'Leave family?';

  @override
  String get leaveFamilyBody =>
      'You will no longer see this family\'s data. Data on this device stays.';

  @override
  String get notifyMissedLabel => 'Notify me when a dose is missed';

  @override
  String get syncStatusSynced => 'Synced';

  @override
  String syncStatusPending(int count) {
    return '$count changes waiting to send';
  }

  @override
  String get syncStatusOffline => 'Offline. Changes will be sent when online.';

  @override
  String get syncNow => 'Sync now';

  @override
  String memberCount(int count) {
    return '$count members';
  }

  @override
  String pushMissedTitle(String patient) {
    return '$patient has not taken medication';
  }

  @override
  String get scanAction => 'Scan label';

  @override
  String get scanHint => 'Scan results are only a draft. Check before saving.';

  @override
  String get scanReview => 'Check again';

  @override
  String get scanDone => 'Scan filled in. Check before saving.';

  @override
  String get scanNothing =>
      'The label text could not be read. Try a closer, brighter photo.';

  @override
  String get scanError => 'Scan failed. Enter manually or try again.';

  @override
  String get scanFromCamera => 'Take a photo';

  @override
  String get scanFromGallery => 'Choose from gallery';

  @override
  String get scanning => 'Reading label';

  @override
  String get exportAction => 'Export PDF for doctor';

  @override
  String get exportTitle => 'Export report';

  @override
  String get exportPatient => 'Patient';

  @override
  String exportRange(int days) {
    return 'Last $days days';
  }

  @override
  String get exportCreate => 'Create PDF';

  @override
  String get exportError => 'The PDF could not be created. Try again.';

  @override
  String get exportNoPatients => 'Add a patient first.';

  @override
  String get reportTitle => 'Medication adherence report';

  @override
  String reportPatient(String name) {
    return 'Patient: $name';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'Period: $from - $to';
  }

  @override
  String reportGenerated(String date) {
    return 'Created with Kizuvia on $date';
  }

  @override
  String get reportSummary => 'Summary';

  @override
  String get reportAdherence => 'Adherence';

  @override
  String get reportTaken => 'Taken';

  @override
  String get reportSkipped => 'Skipped';

  @override
  String get reportMissed => 'Not confirmed';

  @override
  String get reportMedColumn => 'Medication';

  @override
  String get reportScheduleColumn => 'Schedule';

  @override
  String get reportDetail => 'Dose details';

  @override
  String get reportDateColumn => 'Date';

  @override
  String get reportTimeColumn => 'Time';

  @override
  String get reportStatusColumn => 'Status';

  @override
  String get reportNoData => 'No doses recorded in this period.';

  @override
  String get familyDefaultName => 'My family';
}
