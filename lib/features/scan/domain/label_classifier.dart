/// Optional pre-OCR gate (docs/06 §7): rejects photos that are not a label or
/// package. Scores are probabilities for `label`, `package`, `other`.
class ClassifierScores {
  const ClassifierScores({
    required this.label,
    required this.package,
    required this.other,
  });

  final double label;
  final double package;
  final double other;
}

abstract interface class LabelClassifier {
  /// Null when no model is available: the scan then continues to OCR.
  Future<ClassifierScores?> classify(String imagePath);
}

/// shortcut: no trained `.tflite` is bundled yet (docs/06 §7 needs a labelled
/// dataset), so this lets every photo through. Replace with a
/// `flutter_litert` implementation once `assets/models/label_classifier.tflite`
/// exists.
class NoModelClassifier implements LabelClassifier {
  const NoModelClassifier();

  @override
  Future<ClassifierScores?> classify(String imagePath) async => null;
}

const classifierRejectThreshold = 0.7;

/// True when the photo should be rejected ("coba foto ulang").
bool shouldReject(ClassifierScores? s) =>
    s != null && s.other > classifierRejectThreshold;

class NotALabelException implements Exception {
  const NotALabelException();
}
