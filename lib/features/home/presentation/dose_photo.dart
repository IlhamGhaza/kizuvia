import 'dart:io';

import 'package:kizuvia/app/theme/app_radius.dart';
import 'package:material_ui/material_ui.dart';

/// Local medication photo, or nothing when missing / unreadable.
class DosePhoto extends StatelessWidget {
  const DosePhoto({required this.path, this.height = 240, super.key});

  final String? path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: Image.file(
        File(p),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
