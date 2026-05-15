import 'package:flutter_haptic_feedback/flutter_haptic_feedback.dart';

/// Haptic feedback helpers. Use these instead of calling the plugin directly.
abstract class Haptics {
  /// Light tap — for chip selection, toggle changes.
  static void selection() => FlutterHapticFeedback.selection();

  /// Medium impact — for confirm actions, adding a person.
  static void impact() =>
      FlutterHapticFeedback.impact(ImpactFeedbackStyle.medium);

  /// Light impact — for number pad key presses.
  static void lightImpact() =>
      FlutterHapticFeedback.impact(ImpactFeedbackStyle.light);

  /// Heavy impact — for destructive actions (delete).
  static void heavyImpact() =>
      FlutterHapticFeedback.impact(ImpactFeedbackStyle.heavy);

  /// Success notification — for share, save completed.
  static void success() =>
      FlutterHapticFeedback.notification(NotificationFeedbackType.success);

  /// Error notification — for validation failures.
  static void error() =>
      FlutterHapticFeedback.notification(NotificationFeedbackType.error);

  /// Warning notification — for soft warnings.
  static void warning() =>
      FlutterHapticFeedback.notification(NotificationFeedbackType.warning);
}
