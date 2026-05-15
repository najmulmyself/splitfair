import 'package:flutter/services.dart';

/// Haptic feedback helpers. Use these instead of calling the plugin directly.
abstract class Haptics {
  /// Light tap — for chip selection, toggle changes.
  static void selection() => HapticFeedback.selectionClick();

  /// Medium impact — for confirm actions, adding a person.
  static void impact() => HapticFeedback.mediumImpact();

  /// Light impact — for number pad key presses.
  static void lightImpact() => HapticFeedback.lightImpact();

  /// Heavy impact — for destructive actions (delete).
  static void heavyImpact() => HapticFeedback.heavyImpact();

  /// Success notification — for share, save completed.
  static void success() => HapticFeedback.mediumImpact();

  /// Error notification — for validation failures.
  static void error() => HapticFeedback.heavyImpact();

  /// Warning notification — for soft warnings.
  static void warning() => HapticFeedback.lightImpact();
}
