import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Formats [Decimal] money values into human-readable currency strings.
/// All formatting must go through this class — never format amounts inline.
class CurrencyFormatter {
  /// Creates a formatter for the given currency code.
  ///
  /// [currencyCode] — ISO 4217 code (e.g. 'USD', 'BDT')
  /// [decimalPlaces] — number of decimal places for this currency (default 2)
  const CurrencyFormatter({
    required this.currencyCode,
    this.decimalPlaces = 2,
  });

  final String currencyCode;
  final int decimalPlaces;

  /// Format a [Decimal] as a currency string.
  /// e.g. Decimal.parse('12.5') → '\$12.50' for USD
  String format(Decimal value) {
    final formatter = NumberFormat.currency(
      name: currencyCode,
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value.toDouble());
  }

  /// Format just the number portion (no symbol).
  /// e.g. Decimal.parse('12.5') → '12.50'
  String formatNumber(Decimal value) {
    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: decimalPlaces,
    );
    return formatter.format(value.toDouble());
  }

  /// Format a compact amount for tight UI spaces.
  /// e.g. Decimal.parse('1234.5') → '\$1,234.50'
  String formatCompact(Decimal value) => format(value);

  /// Parse a user-entered string to Decimal.
  /// Returns [Decimal.zero] if parsing fails.
  static Decimal parseInput(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return Decimal.zero;
    try {
      return Decimal.parse(cleaned);
    } catch (_) {
      return Decimal.zero;
    }
  }
}
