import 'package:flutter_test/flutter_test.dart';
import 'package:kizuvia/features/education/domain/education_content.dart';

void main() {
  test('topicsFor matches free-text labels case-insensitively', () {
    expect(topicsFor(['Hipertensi', 'DM']).map((t) => t.id), [
      'hypertension',
      'diabetes',
    ]);
    expect(topicsFor(['flu']), isEmpty);
  });

  test('every topic has sources and no dosage wording', () {
    for (final t in educationTopics) {
      expect(t.sources, isNotEmpty);
      expect(t.paragraphs.join(' ').toLowerCase(), isNot(contains(' mg')));
    }
  });
}
