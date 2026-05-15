import 'package:decimal/decimal.dart';

/// Input validation logic for all user-entered values.
/// All boundary checks live here — never inline validation in widgets.
abstract class Validators {
  /// Bill subtotal must be > 0 and <= 999,999.99
  static bool isValidAmount(Decimal value) =>
      value > Decimal.zero && value <= Decimal.parse('999999.99');

  /// Tip percentage must be >= 0 and <= 100
  static bool isValidTipPercentage(Decimal value) =>
      value >= Decimal.zero && value <= Decimal.fromInt(100);

  /// Tax must be >= 0. Returns false for negative values.
  static bool isValidTax(Decimal tax) => tax >= Decimal.zero;

  /// Soft warning threshold — tax > 50% of subtotal is unusual.
  static bool isTaxSuspiciouslyHigh(Decimal tax, Decimal subtotal) =>
      subtotal > Decimal.zero && tax > (subtotal / Decimal.fromInt(2));

  /// Person name: 1–20 characters, no leading/trailing whitespace
  static bool isValidPersonName(String name) =>
      name.trim().isNotEmpty && name.trim().length <= 20;

  /// Person count: 1–20
  static bool isValidPersonCount(int count) => count >= 1 && count <= 20;

  /// Custom amounts must sum to subtotal (within 1 cent tolerance)
  static bool customAmountsBalance(
    List<Decimal> amounts,
    Decimal subtotal,
  ) {
    final sum = amounts.fold(Decimal.zero, (a, b) => a + b);
    final diff = (sum - subtotal).abs();
    return diff <= Decimal.parse('0.01');
  }

  /// Percentages must sum to 100 (within 0.01% tolerance)
  static bool percentagesSumToHundred(List<Decimal> percentages) {
    final sum = percentages.fold(Decimal.zero, (a, b) => a + b);
    final diff = (sum - Decimal.fromInt(100)).abs();
    return diff <= Decimal.parse('0.01');
  }

  /// Returns true if the string can be safely parsed as a positive Decimal.
  static bool isValidDecimalInput(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return false;
    try {
      final value = Decimal.parse(cleaned);
      return value >= Decimal.zero;
    } catch (_) {
      return false;
    }
  }
}
