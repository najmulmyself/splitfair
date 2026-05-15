import 'package:decimal/decimal.dart';

/// Dart extensions used throughout the app.
/// Keep these focused — only truly reusable, stateless transformations.

extension StringX on String {
  /// Capitalize the first character of a string.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis to [maxLength] characters.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';

  /// Returns a trimmed, non-empty string or null.
  String? get nonEmptyTrimmed {
    final t = trim();
    return t.isEmpty ? null : t;
  }
}

extension DecimalX on Decimal {
  /// Round to 2 decimal places (half-up).
  Decimal get roundedToTwoDp => round(scale: 2);

  /// Returns true if the value is exactly zero.
  bool get isZero => this == Decimal.zero;

  /// Returns true if the value is greater than zero.
  bool get isPositive => this > Decimal.zero;

  /// Clamp to a minimum of zero.
  Decimal get clampedToZero => this < Decimal.zero ? Decimal.zero : this;

  /// Format as a simple decimal string with [scale] places.
  String toFixed(int scale) => toStringAsFixed(scale);
}

extension ListX<T> on List<T> {
  /// Returns the element at [index] if it exists, otherwise [fallback].
  T getOrElse(int index, T fallback) =>
      index >= 0 && index < length ? this[index] : fallback;

  /// Returns a new list with the element at [index] replaced by [replacement].
  List<T> withReplaced(int index, T replacement) {
    final copy = [...this];
    copy[index] = replacement;
    return copy;
  }
}
