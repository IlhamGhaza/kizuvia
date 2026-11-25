import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/features/scan/domain/label_classifier.dart';

void main() {
  test('rejects only when "other" exceeds 0.7; no model passes through', () {
    expect(shouldReject(null), isFalse);
    expect(
      shouldReject(
        const ClassifierScores(label: 0.2, package: 0.05, other: 0.75),
      ),
      isTrue,
    );
    expect(
      shouldReject(
        const ClassifierScores(label: 0.3, package: 0.0, other: 0.7),
      ),
      isFalse,
    );
  });
}
