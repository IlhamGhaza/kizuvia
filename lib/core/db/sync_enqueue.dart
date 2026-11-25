import 'dart:convert';

import 'package:kizuvia/core/db/app_database.dart';
import 'package:kizuvia/core/domain/enums.dart';

/// Appends a change to `sync_queue`. Call inside the same transaction as the
/// local write (docs/05-SYNC.md §1). Payload mirrors the server columns.
Future<void> enqueueSync(
  AppDatabase db, {
  required String table,
  required String rowId,
  required SyncOp op,
  required Map<String, Object?> payload,
  required DateTime now,
}) => db
    .into(db.syncQueue)
    .insert(
      SyncQueueCompanion.insert(
        targetTable: table,
        rowId: rowId,
        op: op,
        payloadJson: jsonEncode(payload),
        createdAt: now,
      ),
    );

String? _date(DateTime? d) => d?.toUtc().toIso8601String();

/// Server `date` columns: the device-local calendar day (a UTC instant would
/// shift the day for users east of UTC).
String? _day(DateTime? d) {
  if (d == null) return null;
  final l = d.toLocal();
  return '${l.year.toString().padLeft(4, '0')}-'
      '${l.month.toString().padLeft(2, '0')}-'
      '${l.day.toString().padLeft(2, '0')}';
}

Map<String, Object?> patientPayload(PatientRow r) => {
  'id': r.id,
  'family_id': r.familyId,
  'user_id': r.userId,
  'name': r.name,
  'birth_year': r.birthYear,
  'conditions': r.conditions,
  'notes': r.notes,
  'photo_path': r.photoPath,
  'deleted_at': _date(r.deletedAt),
};

Map<String, Object?> medicationPayload(MedicationRow r) => {
  'id': r.id,
  'patient_id': r.patientId,
  'name': r.name,
  'strength': r.strength,
  'form': r.form,
  'instructions': r.instructions,
  'meal_relation': r.mealRelation,
  'prescribed_by': r.prescribedBy,
  'stock_qty': r.stockQty,
  'dose_qty': r.doseQty,
  'refill_threshold_days': r.refillThresholdDays,
  'photo_path': r.photoRemotePath,
  'start_date': _day(r.startDate),
  'end_date': _day(r.endDate),
  'is_prn': r.isPrn,
  'is_active': r.isActive,
  'source': r.source,
  'deleted_at': _date(r.deletedAt),
};

Map<String, Object?> schedulePayload(ScheduleRow r) => {
  'id': r.id,
  'medication_id': r.medicationId,
  'times': r.times,
  'days_of_week': r.daysOfWeek,
  'timezone': r.timezone,
  'grace_minutes': r.graceMinutes,
  'deleted_at': _date(r.deletedAt),
};

Map<String, Object?> doseLogPayload(DoseLogRow r) => {
  'id': r.id,
  'schedule_id': r.scheduleId,
  'patient_id': r.patientId,
  'scheduled_at': _date(r.scheduledAt),
  'status': r.status.name,
  'confirmed_at': _date(r.confirmedAt),
  'source': r.source.name,
  'note': r.note,
};
