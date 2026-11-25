import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Status = icon + text; colour only reinforces (docs/07 §3).
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelMedium;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(label, style: text?.copyWith(color: color)),
        ),
      ],
    );
  }
}
