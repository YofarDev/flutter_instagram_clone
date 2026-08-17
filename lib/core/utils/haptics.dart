import 'package:flutter/services.dart';

/// Centralized haptic vocabulary. Keep calls semantic, not mechanical.
class AppHaptics {
  AppHaptics._();

  /// Tab switches, segmented controls.
  static void tab() => HapticFeedback.selectionClick();

  /// Likes (double-tap or button), heavy moments.
  static void like() => HapticFeedback.mediumImpact();

  /// Follow buttons, small confirmations.
  static void follow() => HapticFeedback.lightImpact();

  /// Post shared / action completed.
  static void success() => HapticFeedback.heavyImpact();
}
