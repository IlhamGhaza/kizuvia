import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';

String formLabel(AppLocalizations l, MedForm f) => switch (f) {
  MedForm.tablet => l.formTablet,
  MedForm.kapsul => l.formKapsul,
  MedForm.sirup => l.formSirup,
  MedForm.tetes => l.formTetes,
  MedForm.salep => l.formSalep,
  MedForm.injeksi => l.formInjeksi,
  MedForm.inhaler => l.formInhaler,
  MedForm.lainnya => l.formLainnya,
};

String mealLabel(AppLocalizations l, MealRelation m) => switch (m) {
  MealRelation.sebelumMakan => l.mealBefore,
  MealRelation.sesudahMakan => l.mealAfter,
  MealRelation.bersamaMakan => l.mealWith,
  MealRelation.bebas => l.mealAny,
};

/// ISO weekday 1..7 -> short label.
String dayLabel(AppLocalizations l, int isoDay) => switch (isoDay) {
  1 => l.dayMon,
  2 => l.dayTue,
  3 => l.dayWed,
  4 => l.dayThu,
  5 => l.dayFri,
  6 => l.daySat,
  _ => l.daySun,
};

/// `1,2,3,4,5,6,7` -> "Setiap hari", otherwise "Sen, Rab, Jum".
String daysSummary(AppLocalizations l, List<int> days) {
  final sorted = [...days]..sort();
  if (sorted.length == 7) return l.daysEveryDay;
  return sorted.map((d) => dayLabel(l, d)).join(', ');
}
