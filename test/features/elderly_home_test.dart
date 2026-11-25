import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/notifications/occurrence_calculator.dart';
import 'package:kizuvia/features/dose_log/domain/resolved_dose.dart';
import 'package:kizuvia/features/home/presentation/elderly_home.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';

ResolvedDose dose(int hour, DoseView view) => ResolvedDose(
  context: ScheduleContext(
    patientName: 'Budi',
    medication: Medication(
      id: 'm$hour',
      patientId: 'p1',
      name: 'X',
      startDate: DateTime.utc(2026),
    ),
    schedule: MedSchedule(
      id: 's$hour',
      medicationId: 'm$hour',
      times: const [],
    ),
  ),
  at: DateTime.utc(2026, 3, 2, hour),
  view: view,
);

void main() {
  test('nextDose: now beats upcoming beats missed; done ignored', () {
    expect(
      nextDose([dose(1, DoseView.taken), dose(2, DoseView.skipped)]),
      isNull,
    );
    expect(
      nextDose([dose(1, DoseView.missed), dose(9, DoseView.upcoming)])!.at.hour,
      9,
    );
    expect(
      nextDose([
        dose(9, DoseView.upcoming),
        dose(5, DoseView.now),
        dose(1, DoseView.missed),
      ])!.at.hour,
      5,
    );
    expect(nextDose([dose(1, DoseView.missed)])!.at.hour, 1);
    expect(nextDose(const []), isNull);
  });
}
