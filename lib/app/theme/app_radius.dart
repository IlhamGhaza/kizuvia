import 'package:material_ui/material_ui.dart';

/// Radius tokens: 12 cards, 24 large buttons (docs/07-UI-FLOW.md §3).
abstract final class AppRadius {
  static const double card = 12;
  static const double button = 24;

  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const buttonBorder = BorderRadius.all(Radius.circular(button));
}
