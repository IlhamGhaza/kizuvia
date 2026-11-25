/// General, non-prescriptive education per condition label (docs/08 §3).
/// Never names drugs or doses (safety rules 1-2). Every topic cites sources.
/// shortcut: Indonesian only and compiled in; move to l10n/assets with T3.6.
class EducationTopic {
  const EducationTopic({
    required this.id,
    required this.title,
    required this.keywords,
    required this.paragraphs,
    required this.sources,
  });

  final String id;
  final String title;

  /// Lower-case fragments matched against a patient's free-text label.
  final List<String> keywords;
  final List<String> paragraphs;
  final List<EducationSource> sources;
}

class EducationSource {
  const EducationSource(this.name, [this.url]);
  final String name;
  final String? url;
}

const educationTopics = <EducationTopic>[
  EducationTopic(
    id: 'hypertension',
    title: 'Tekanan darah tinggi (hipertensi)',
    keywords: ['hipertensi', 'darah tinggi', 'tekanan darah'],
    paragraphs: [
      'Tekanan darah tinggi sering tidak menimbulkan gejala, sehingga perlu diukur secara teratur.',
      'Kebiasaan yang umum dianjurkan: mengurangi garam, memperbanyak sayur dan buah, bergerak secara teratur, tidak merokok, dan menjaga berat badan.',
      'Catat hasil pengukuran dan bawa saat kontrol agar dokter bisa menilai perkembangannya.',
    ],
    sources: [
      EducationSource(
        'WHO: Hypertension',
        'https://www.who.int/news-room/fact-sheets/detail/hypertension',
      ),
    ],
  ),
  EducationTopic(
    id: 'diabetes',
    title: 'Diabetes melitus (kencing manis)',
    keywords: ['diabetes', 'kencing manis', 'gula darah', 'dm'],
    paragraphs: [
      'Diabetes terjadi ketika kadar gula darah terlalu tinggi dalam jangka panjang.',
      'Pola makan seimbang, aktivitas fisik teratur, dan menjaga berat badan membantu mengendalikan gula darah.',
      'Pemeriksaan kaki, mata, dan ginjal secara berkala dianjurkan. Tanyakan kepada dokter kapan perlu diperiksa.',
    ],
    sources: [
      EducationSource(
        'WHO: Diabetes',
        'https://www.who.int/news-room/fact-sheets/detail/diabetes',
      ),
    ],
  ),
  EducationTopic(
    id: 'cardiovascular',
    title: 'Penyakit jantung dan pembuluh darah',
    keywords: ['jantung', 'stroke', 'kardio', 'koroner'],
    paragraphs: [
      'Penyakit jantung dan pembuluh darah berkaitan dengan tekanan darah, kolesterol, gula darah, merokok, dan kurang bergerak.',
      'Mengenali tanda bahaya penting: nyeri dada, sesak napas mendadak, wajah mencong, lemah satu sisi tubuh, atau bicara pelo. Segera cari pertolongan medis darurat.',
    ],
    sources: [
      EducationSource(
        'WHO: Cardiovascular diseases',
        'https://www.who.int/news-room/fact-sheets/detail/cardiovascular-diseases-(cvds)',
      ),
    ],
  ),
  EducationTopic(
    id: 'cholesterol',
    title: 'Kolesterol tinggi',
    keywords: ['kolesterol', 'lemak darah'],
    paragraphs: [
      'Kolesterol tinggi biasanya tanpa gejala dan hanya diketahui lewat pemeriksaan darah.',
      'Mengurangi makanan berlemak jenuh dan gorengan, memperbanyak serat, serta aktif bergerak umumnya dianjurkan.',
    ],
    sources: [
      EducationSource(
        'Kemenkes RI: materi edukasi penyakit tidak menular (P2PTM)',
      ),
    ],
  ),
];

const educationDisclaimer =
    'Informasi ini bersifat umum dan bukan pengganti nasihat dokter. '
    'Kizuvia tidak memberi saran obat atau dosis. Tanyakan kepada dokter atau apoteker Anda.';

/// Topics matching any of [conditions] (free-text labels), without duplicates.
List<EducationTopic> topicsFor(Iterable<String> conditions) {
  final labels = conditions.map((c) => c.toLowerCase()).toList();
  return [
    for (final t in educationTopics)
      if (labels.any((l) => t.keywords.any(l.contains))) t,
  ];
}
