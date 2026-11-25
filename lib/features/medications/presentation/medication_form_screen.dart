import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:kizuvia/core/domain/enums.dart';
import 'package:kizuvia/features/medications/data/medication_photo_store.dart';
import 'package:kizuvia/features/medications/data/medication_repository.dart';
import 'package:kizuvia/features/medications/domain/med_schedule.dart';
import 'package:kizuvia/features/medications/domain/medication.dart';
import 'package:kizuvia/features/medications/presentation/medication_labels.dart';
import 'package:kizuvia/features/scan/data/label_scanner.dart';
import 'package:kizuvia/features/scan/domain/label_classifier.dart';
import 'package:kizuvia/features/scan/domain/parsed_label.dart';
import 'package:kizuvia/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone/timezone.dart' as tz;

enum _Freq { once, twice, thrice, four, custom, prn }

/// Create or edit a medication with its schedule (T1.4, docs/07 §2).
/// Pass [patientId] to create, [medicationId] to edit.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.patientId, this.medicationId})
    : assert(patientId != null || medicationId != null);

  final String? patientId;
  final String? medicationId;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _strength = TextEditingController();
  final _doseQty = TextEditingController(text: '1');
  final _stock = TextEditingController();
  final _refill = TextEditingController(text: '3');
  final _instructions = TextEditingController();

  MedicationWithSchedule? _existing;
  MedForm? _form;
  MealRelation? _meal;
  _Freq _freq = _Freq.once;
  List<String> _times = [...FrequencyTemplate.once.times];
  Set<int> _days = {1, 2, 3, 4, 5, 6, 7};
  DateTime _start = DateTime.now();
  DateTime? _end;
  String? _photoPath;
  String _timezone = 'Asia/Jakarta';
  bool _loading = true;
  bool _saving = false;
  bool _showTimeError = false;

  /// Fields filled by a scan that the user has not touched yet.
  final Set<String> _review = {};
  bool _fromScan = false;
  bool _scanning = false;

  /// Bumped after a scan so dropdowns (initialValue) rebuild with new values.
  int _scanVersion = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.medicationId;
    if (id != null) {
      final e = await ref.read(medicationRepositoryProvider).get(id);
      if (e != null) {
        _existing = e;
        final m = e.medication;
        _name.text = m.name;
        _strength.text = m.strength ?? '';
        _doseQty.text = _fmt(m.doseQty);
        _stock.text = m.stockQty == null ? '' : _fmt(m.stockQty!);
        _refill.text = m.refillThresholdDays.toString();
        _instructions.text = m.instructions ?? '';
        _form = m.form;
        _meal = m.mealRelation;
        _start = m.startDate.toLocal();
        _end = m.endDate?.toLocal();
        _photoPath = m.photoPath;
        if (m.isPrn || e.schedule == null) {
          _freq = _Freq.prn;
          _times = [];
        } else {
          _times = [...e.schedule!.times];
          _days = {...e.schedule!.daysOfWeek};
          _timezone = e.schedule!.timezone;
          _freq = _freqFor(_times);
        }
      }
    } else {
      _timezone = await _deviceTimezone();
    }
    if (mounted) setState(() => _loading = false);
  }

  static Future<String> _deviceTimezone() async {
    try {
      final id = (await FlutterTimezone.getLocalTimezone()).identifier;
      if (tz.timeZoneDatabase.locations.containsKey(id)) return id;
    } on Object {
      // Fall through to the default.
    }
    return 'Asia/Jakarta';
  }

  static _Freq _freqFor(List<String> times) {
    for (final (f, t) in [
      (_Freq.once, FrequencyTemplate.once),
      (_Freq.twice, FrequencyTemplate.twice),
      (_Freq.thrice, FrequencyTemplate.thrice),
      (_Freq.four, FrequencyTemplate.fourTimes),
    ]) {
      if (t.times.length == times.length &&
          Iterable<int>.generate(times.length)
              .every((i) => t.times[i] == times[i])) {
        return f;
      }
    }
    return _Freq.custom;
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _doseQty.dispose();
    _stock.dispose();
    _refill.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _setFreq(_Freq f) {
    setState(() {
      _freq = f;
      _showTimeError = false;
      switch (f) {
        case _Freq.once:
          _times = [...FrequencyTemplate.once.times];
        case _Freq.twice:
          _times = [...FrequencyTemplate.twice.times];
        case _Freq.thrice:
          _times = [...FrequencyTemplate.thrice.times];
        case _Freq.four:
          _times = [...FrequencyTemplate.fourTimes.times];
        case _Freq.prn:
          _times = [];
        case _Freq.custom:
          if (_times.isEmpty) _times = ['08:00'];
      }
    });
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(int index) async {
    final parts = _times[index].split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked == null) return;
    setState(() {
      _times[index] = _hhmm(picked);
      _times = ({..._times}.toList()..sort());
      _freq = _freqFor(_times);
    });
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      _times = ({..._times, _hhmm(picked)}.toList()..sort());
      _freq = _freqFor(_times);
      _showTimeError = false;
    });
  }

  Future<void> _pickDate({required bool end}) async {
    final now = DateTime.now();
    final initial = end ? (_end ?? _start) : _start;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        // Inclusive: no dose after the end of the chosen day.
        _end = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      } else {
        _start = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoAdd),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoChange),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.photoRemove),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final path = await MedicationPhotoStore().pick(source);
    if (path != null && mounted) setState(() => _photoPath = path);
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.scanFromCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.scanFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() => _scanning = true);
    try {
      final scanner = await ref.read(labelScannerProvider.future);
      final parsed = await scanner.scan(source);
      if (!mounted) return;
      if (parsed == null) return;
      if (!parsed.hasAnyField) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.scanNothing)));
        return;
      }
      _applyParsed(parsed);
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanDone)));
    } on NotALabelException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanNotLabel)));
    } on Object {
      // Never include the scanned text in any error output.
      messenger.showSnackBar(SnackBar(content: Text(l10n.scanError)));
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  /// Fills the form from a scan and marks each filled field for review.
  void _applyParsed(ParsedLabel p) {
    setState(() {
      _fromScan = true;
      _scanVersion++;
      if (p.name != null) {
        _name.text = p.name!;
        _review.add('name');
      }
      if (p.strength != null) {
        _strength.text = p.strength!;
        _review.add('strength');
      }
      if (p.form != null) {
        _form = p.form;
        _review.add('form');
      }
      if (p.doseQty != null) {
        _doseQty.text = _fmt(p.doseQty!);
        _review.add('doseQty');
      }
      if (p.mealRelation != null) {
        _meal = p.mealRelation;
        _review.add('meal');
      }
      if (p.isPrn ?? false) {
        _setFreq(_Freq.prn);
        _review.add('freq');
      } else if (p.timesPerDay != null) {
        final f = switch (p.timesPerDay!) {
          1 => _Freq.once,
          2 => _Freq.twice,
          3 => _Freq.thrice,
          4 => _Freq.four,
          _ => null,
        };
        if (f != null) {
          _setFreq(f);
          _review.add('freq');
        }
      }
    });
  }

  /// Wraps a field with the "Periksa kembali" marker until the user touches it
  /// (docs/07 §2: `warning-soft` background + icon + text, never colour alone).
  Widget _reviewField(String key, Widget child) {
    if (!_review.contains(key)) return child;
    final l10n = AppLocalizations.of(context);
    return Listener(
      onPointerDown: (_) {
        if (_review.remove(key)) setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.tokens.warningSoft,
          borderRadius: AppRadius.cardBorder,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.scanReview,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            child,
          ],
        ),
      ),
    );
  }

  double? _parseNum(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final valid = _formKey.currentState!.validate();
    final needTimes = _freq != _Freq.prn && _times.isEmpty;
    final needDays = _freq != _Freq.prn && _days.isEmpty;
    if (needTimes || needDays) setState(() => _showTimeError = true);
    if (!valid || needTimes || needDays) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reviewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                _name.text.trim(),
                if (_strength.text.trim().isNotEmpty) _strength.text.trim(),
              ].join(' '),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _freq == _Freq.prn
                  ? l10n.prnNote
                  : '${l10n.scheduleSummary(_times.join(', '))}\n${daysSummary(l10n, _days.toList())}',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.reviewHint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    final prn = _freq == _Freq.prn;
    final base =
        _existing?.medication ??
        Medication(
          id: '',
          patientId: widget.patientId!,
          name: '',
          startDate: _start,
        );
    final med = base.copyWith(
      name: _name.text,
      strength: _strength.text.trim().isEmpty ? null : _strength.text.trim(),
      form: _form,
      mealRelation: _meal,
      doseQty: _parseNum(_doseQty.text) ?? 1,
      stockQty: _stock.text.trim().isEmpty ? null : _parseNum(_stock.text),
      refillThresholdDays: int.tryParse(_refill.text.trim()) ?? 3,
      instructions: _instructions.text.trim().isEmpty
          ? null
          : _instructions.text.trim(),
      photoPath: _photoPath,
      startDate: _start,
      endDate: _end,
      isPrn: prn,
      source: _fromScan ? 'scan' : base.source,
    );
    final schedule = prn
        ? null
        : (_existing?.schedule ??
                  const MedSchedule(id: '', medicationId: '', times: []))
              .copyWith(
                times: _times,
                daysOfWeek: (_days.toList()..sort()),
                timezone: _timezone,
              );
    final result = await ref
        .read(medicationRepositoryProvider)
        .save(med, schedule);
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      ok: (_) => router.pop(),
      err: (_) =>
          messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
    );
  }

  String _freqLabel(AppLocalizations l, _Freq f) => switch (f) {
    _Freq.once => l.freq1,
    _Freq.twice => l.freq2,
    _Freq.thrice => l.freq3,
    _Freq.four => l.freq4,
    _Freq.custom => l.freqCustom,
    _Freq.prn => l.freqPrn,
  };

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final prn = _freq == _Freq.prn;

    Widget section(String label) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(label, style: text.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medicationId == null ? l10n.medFormNew : l10n.medFormEdit,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _scanning ? null : _scan,
                    icon: _scanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner_outlined),
                    label: Text(_scanning ? l10n.scanning : l10n.scanAction),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.lg,
                    ),
                    child: Text(l10n.scanHint, style: text.bodySmall),
                  ),
                  // Photo (optional)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.cardBorder,
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: _photoPath == null
                              ? ColoredBox(
                                  color: scheme.surfaceContainer,
                                  child: const Icon(Icons.medication_outlined),
                                )
                              : Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.broken_image_outlined),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(
                            _photoPath == null
                                ? l10n.photoAdd
                                : l10n.photoChange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _reviewField(
                    'name',
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.fieldMedName),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? l10n.errMedName : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _reviewField(
                    'strength',
                    TextFormField(
                      controller: _strength,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.fieldStrength,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _reviewField(
                    'form',
                    DropdownButtonFormField<MedForm>(
                      key: ValueKey('form$_scanVersion'),
                      initialValue: _form,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.fieldForm),
                      items: [
                        for (final f in MedForm.values)
                          DropdownMenuItem(
                            value: f,
                            child: Text(formLabel(l10n, f)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _form = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _reviewField(
                    'doseQty',
                    TextFormField(
                      controller: _doseQty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.fieldDoseQty),
                      validator: (v) {
                        final n = _parseNum(v ?? '');
                        return n == null || n <= 0 ? l10n.errDoseQty : null;
                      },
                    ),
                  ),
                  section(l10n.fieldFrequency),
                  _reviewField(
                    'freq',
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final f in _Freq.values)
                          ChoiceChip(
                            label: Text(_freqLabel(l10n, f)),
                            selected: _freq == f,
                            onSelected: (_) => _setFreq(f),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _reviewField(
                    'meal',
                    DropdownButtonFormField<MealRelation>(
                      key: ValueKey('meal$_scanVersion'),
                      initialValue: _meal,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.fieldMeal),
                      items: [
                        for (final m in MealRelation.values)
                          DropdownMenuItem(
                            value: m,
                            child: Text(mealLabel(l10n, m)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _meal = v),
                    ),
                  ),
                  if (!prn) ...[
                    section(l10n.fieldTimes),
                    for (var i = 0; i < _times.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickTime(i),
                                icon: const Icon(Icons.schedule),
                                label: Text(_times[i]),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.removeTime,
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => setState(() {
                                _times.removeAt(i);
                                _freq = _freqFor(_times);
                              }),
                            ),
                          ],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: _addTime,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addTime),
                    ),
                    if (_showTimeError && _times.isEmpty)
                      Text(
                        l10n.errNeedTime,
                        style: text.bodySmall?.copyWith(color: scheme.error),
                      ),
                    section(l10n.fieldDays),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (var d = 1; d <= 7; d++)
                          FilterChip(
                            label: Text(dayLabel(l10n, d)),
                            selected: _days.contains(d),
                            onSelected: (on) => setState(
                              () => on ? _days.add(d) : _days.remove(d),
                            ),
                          ),
                      ],
                    ),
                    if (_showTimeError && _days.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          l10n.errNeedDay,
                          style: text.bodySmall?.copyWith(color: scheme.error),
                        ),
                      ),
                  ],
                  section(l10n.fieldStartDate),
                  OutlinedButton.icon(
                    onPressed: () => _pickDate(end: false),
                    icon: const Icon(Icons.event),
                    label: Text(_dateLabel(_start)),
                  ),
                  section(l10n.fieldEndDate),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(end: true),
                          icon: const Icon(Icons.event_busy),
                          label: Text(
                            _end == null ? l10n.noEndDate : _dateLabel(_end!),
                          ),
                        ),
                      ),
                      if (_end != null)
                        IconButton(
                          tooltip: l10n.clearDate,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _end = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _stock,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldStock),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _refill,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.fieldRefill),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _instructions,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.fieldInstructions,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.save),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }
}
