import 'package:flutter_haptic_feedback/flutter_haptic_feedback.dart';

/// Haptic feedback helpers. Use these instead of calling the plugin directly.
abstract class Haptics {
  /// Light tap — for chip selection, toggle changes.
  static void selection() => FlutterHapticFeedback.selectionClick();

  /// Medium impact — for confirm actions, adding a person.
  static void impact() => FlutterHapticFeedback.mediumImpact();

  /// Light impact — for number pad key presses.
  static void lightImpact() => FlutterHapticFeedback.lightImpact();

  /// Heavy impact — for destructive actions (delete).
  static void heavyImpact() => FlutterHapticFeedback.heavyImpact();

  /// Success notification — for share, save completed.
  static void success() => FlutterHapticFeedback.notificationSuccess();

  /// Error notification — for validation failures.
  static void error() => FlutterHapticFeedback.notificationError();

  /// Warning notification — for soft warnings.
  static void warning() => FlutterHapticFeedback.notificationWarning();
}
