import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/features/education/domain/education_content.dart';
import 'package:kizuvia/features/patients/data/patient_repository.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// `/patients/:id/education`: general, sourced info for the patient's condition
/// labels. Ends with the disclaimer (docs/08 §3).
class EducationScreen extends ConsumerWidget {
  const EducationScreen({required this.patientId, super.key});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final patient = ref
        .watch(patientsProvider)
        .value
        ?.where((p) => p.id == patientId)
        .firstOrNull;
    final topics = topicsFor(patient?.conditions ?? const []);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.educationTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (topics.isEmpty) Text(l10n.educationEmpty, style: text.bodyLarge),
          for (final t in topics) ...[
            Text(t.title, style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final p in t.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(p, style: text.bodyLarge),
              ),
            Text(l10n.educationSources, style: text.labelLarge),
            for (final s in t.sources)
              Text(
                s.url == null ? s.name : '${s.name}\n${s.url}',
                style: text.bodySmall,
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(educationDisclaimer)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
