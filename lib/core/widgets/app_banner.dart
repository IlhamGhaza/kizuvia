import 'package:kizuvia/app/theme/app_colors.dart';
import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:kizuvia/app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Warning banner (alarm permission off, low stock...). The whole banner is
/// one tap target; text uses the normal foreground for contrast on
/// `warning-soft` (docs/07 §3).
class AppBanner extends StatelessWidget {
  const AppBanner({
    required this.text,
    super.key,
    this.icon = Icons.warning_amber_rounded,
    this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tokens.warningSoft,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        borderRadius: AppRadius.cardBorder,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(icon, color: context.tokens.warning),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
