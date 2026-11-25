import 'dart:math' as math;

/// Stock left after a confirmed (taken) dose. Never below zero.
/// Skipped/missed doses do not change stock (docs/09 §2).
double stockAfterTaken(double stock, double doseQty) =>
    math.max(0, stock - doseQty);

/// Whole days of stock left: `stock / (doseQty × dosesPerDay)`.
/// Null when it cannot be computed (no stock, no doses per day).
double? daysRemaining({
  required double? stock,
  required double doseQty,
  required int dosesPerDay,
}) {
  if (stock == null || dosesPerDay <= 0 || doseQty <= 0) return null;
  return stock / (doseQty * dosesPerDay);
}

/// True when stock is at or below the refill threshold (US-10).
bool isLowStock({
  required double? stock,
  required double doseQty,
  required int dosesPerDay,
  required int thresholdDays,
}) {
  final days = daysRemaining(
    stock: stock,
    doseQty: doseQty,
    dosesPerDay: dosesPerDay,
  );
  return days != null && days <= thresholdDays;
}
