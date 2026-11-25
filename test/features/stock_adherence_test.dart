import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/history/domain/adherence_calculator.dart';
import 'package:kizuvia/features/stock/domain/stock_calculator.dart';

void main() {
  group('stock', () {
    test('taken reduces by dose_qty, never below zero', () {
      expect(stockAfterTaken(10, 1), 9);
      expect(stockAfterTaken(0.5, 1), 0);
      expect(stockAfterTaken(10, 0.5), 9.5);
    });

    test('days remaining = stock / (dose_qty x doses per day)', () {
      expect(daysRemaining(stock: 30, doseQty: 1, dosesPerDay: 3), 10);
      expect(daysRemaining(stock: 30, doseQty: 0.5, dosesPerDay: 2), 30);
      expect(daysRemaining(stock: null, doseQty: 1, dosesPerDay: 3), isNull);
      expect(daysRemaining(stock: 5, doseQty: 1, dosesPerDay: 0), isNull);
    });

    test('low stock at or below threshold', () {
      bool low(double s) =>
          isLowStock(stock: s, doseQty: 1, dosesPerDay: 1, thresholdDays: 3);
      expect(low(3), isTrue);
      expect(low(4), isFalse);
    });
  });

  group('adherence', () {
    test('effective status priority taken > skipped > missed', () {
      expect(
        effectiveStatus([DoseStatus.missed, DoseStatus.taken]),
        DoseStatus.taken,
      );
      expect(
        effectiveStatus([DoseStatus.missed, DoseStatus.skipped]),
        DoseStatus.skipped,
      );
      expect(effectiveStatus([DoseStatus.missed]), DoseStatus.missed);
    });

    test('percentage and empty', () {
      expect(adherence([]), isNull);
      expect(
        adherence([
          DoseStatus.taken,
          DoseStatus.taken,
          DoseStatus.skipped,
          DoseStatus.missed,
        ]),
        0.5,
      );
    });

    test('day status', () {
      expect(dayStatus([]), DayStatus.none);
      expect(dayStatus([DoseStatus.taken]), DayStatus.allTaken);
      expect(
        dayStatus([DoseStatus.taken, DoseStatus.missed]),
        DayStatus.hasMissed,
      );
      expect(
        dayStatus([DoseStatus.taken, DoseStatus.skipped]),
        DayStatus.partial,
      );
    });
  });
}
