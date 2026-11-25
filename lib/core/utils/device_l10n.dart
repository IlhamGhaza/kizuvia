import 'dart:ui';

import 'package:kizuvia/l10n/gen/app_localizations.dart';

/// Locale to use: the device language when supported, else Indonesian.
Locale resolveLocale(Locale? device) {
  for (final l in AppLocalizations.supportedLocales) {
    if (l.languageCode == device?.languageCode) return l;
  }
  return const Locale('id');
}

/// Strings outside the widget tree (notifications, home widget).
AppLocalizations deviceL10n() =>
    lookupAppLocalizations(resolveLocale(PlatformDispatcher.instance.locale));
