import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Debug-only component gallery (`/dev/gallery`, T0.2b). Not shipped in release
/// (route is registered only when `kDebugMode`), so labels are not localised.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _dark = false;
  bool _elderly = false;

  @override
  Widget build(BuildContext context) {
    final theme = _dark
        ? AppTheme.dark(elderly: _elderly)
        : AppTheme.light(elderly: _elderly);
    return Theme(
      data: theme,
      child: Builder(builder: _content),
    );
  }

  Widget _content(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SwitchListTile(
            title: const Text('Dark'),
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
          ),
          SwitchListTile(
            title: const Text('Mode lansia'),
            value: _elderly,
            onChanged: (v) => setState(() => _elderly = v),
          ),
          _section('Typography'),
          Text('Display small', style: text.displaySmall),
          Text('Headline medium', style: text.headlineMedium),
          Text('Title large', style: text.titleLarge),
          Text('Title medium', style: text.titleMedium),
          Text('Body large: Amlodipine 10 mg, 1 tablet', style: text.bodyLarge),
          Text('Body medium: sesudah makan', style: text.bodyMedium),
          Text(
            'Body small / metadata',
            style: text.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
          _section('Colors'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _swatch('primary', scheme.primary, scheme.onPrimary),
              _swatch('primary-dark', tokens.primaryDark, scheme.onPrimary),
              _swatch('primary-soft', tokens.primarySoft, scheme.onSurface),
              _swatch('surface', scheme.surface, scheme.onSurface),
              _swatch('surface-subtle', tokens.surfaceSubtle, scheme.onSurface),
              _swatch('warning-soft', tokens.warningSoft, scheme.onSurface),
            ],
          ),
          _section('Status (ikon + teks)'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _status('Diminum', Icons.check_circle, tokens.success),
              _status('Sekarang', Icons.schedule, tokens.info),
              _status('Akan datang', Icons.access_time, tokens.textSecondary),
              _status('Dilewati', Icons.remove_circle_outline, tokens.warning),
              _status('Belum dikonfirmasi', Icons.error, tokens.danger),
            ],
          ),
          _section('Buttons'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: const Text('Sudah minum'),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Tunda')),
              TextButton(onPressed: () {}, child: const Text('Lewati')),
              const FilledButton(onPressed: null, child: Text('Nonaktif')),
            ],
          ),
          _section('Chips'),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Ayah'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          _section('Form'),
          const TextField(decoration: InputDecoration(labelText: 'Nama obat')),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: tokens.warningSoft,
              borderRadius: AppRadius.cardBorder,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Periksa kembali: hasil scan',
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Jumlah per dosis',
              errorText: 'Periksa kembali jumlah dosis',
            ),
          ),
          _section('Card'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amlodipine 10 mg', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '07:00 · 1 tablet · sesudah makan',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _swatch(String label, Color bg, Color fg) => Container(
    width: 140,
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: AppRadius.cardBorder,
      border: Border.all(color: context.tokens.border),
    ),
    child: Text(label, style: TextStyle(color: fg)),
  );

  Widget _status(String label, IconData icon, Color color) => Chip(
    avatar: Icon(icon, color: color, size: 20),
    label: Text(label),
  );
}
