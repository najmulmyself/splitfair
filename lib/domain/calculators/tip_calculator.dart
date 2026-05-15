import 'package:decimal/decimal.dart';

/// Handles all tip calculation logic.
/// All inputs and outputs are [Decimal] — no double conversion.
class TipCalculator {
  const TipCalculator._();

  /// Calculate tip amount.
  ///
  /// [subtotal] — bill subtotal before tax.
  /// [tax] — tax amount.
  /// [tipPercentage] — e.g. [Decimal.parse]('18') for 18%.
  /// [onSubtotal] — if true, tip is calculated on subtotal only (not subtotal + tax).
  ///
  /// Returns the tip amount as [Decimal].
  static Decimal calculateTip({
    required Decimal subtotal,
    required Decimal tax,
    required Decimal tipPercentage,
    required bool onSubtotal,
  }) {
    final hundred = Decimal.fromInt(100);
    final base = onSubtotal ? subtotal : (subtotal + tax);
    return (base * tipPercentage / hundred).toDecimal(
      scaleOnInfinitePrecision: 10,
    );
  }

  /// Calculate the grand total (subtotal + tax + tip).
  static Decimal grandTotal({
    required Decimal subtotal,
    required Decimal tax,
    required Decimal tip,
  }) => subtotal + tax + tip;

  /// Returns the tip percentage as a human-readable label.
  /// e.g. [Decimal.parse]('18') → '18%'
  static String formatPercentage(Decimal percentage) =>
      '${percentage.toStringAsFixed(0)}%';

  /// Given the subtotal and tip amount, back-calculate the implied tip %.
  /// Returns zero if subtotal is zero.
  static Decimal impliedTipPercentage({
    required Decimal subtotal,
    required Decimal tip,
  }) {
    if (subtotal == Decimal.zero) return Decimal.zero;
    return (tip / subtotal * Decimal.fromInt(100)).toDecimal(
      scaleOnInfinitePrecision: 10,
    );
  }

  /// Returns the dollar difference between tipping on subtotal vs tipping on total.
  /// A positive value means tipping on total costs more.
  static Decimal tipDifference({
    required Decimal subtotal,
    required Decimal tax,
    required Decimal tipPercentage,
  }) {
    final tipOnSubtotal = calculateTip(
      subtotal: subtotal,
      tax: tax,
      tipPercentage: tipPercentage,
      onSubtotal: true,
    );
    final tipOnTotal = calculateTip(
      subtotal: subtotal,
      tax: tax,
      tipPercentage: tipPercentage,
      onSubtotal: false,
    );
    return (tipOnTotal - tipOnSubtotal).abs();
  }
}
