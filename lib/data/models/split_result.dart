import 'package:decimal/decimal.dart';
import 'person.dart';

/// The computed result for one person in a split.
/// This is a pure value object — computed from [SplitSession], never stored.
class SplitResult {
  /// The person this result belongs to.
  final Person person;

  /// Their share of the pre-tax subtotal.
  final Decimal subtotalShare;

  /// Their proportional share of the tax.
  final Decimal taxShare;

  /// Their proportional share of the tip.
  final Decimal tipShare;

  /// Total amount owed: subtotalShare + taxShare + tipShare.
  final Decimal total;

  /// True if this person owes the most (for UI badge).
  final bool isHighest;

  /// True if this person owes the least (for UI badge).
  final bool isLowest;

  /// True if this person eats free (birthday feature).
  final bool isFree;

  const SplitResult({
    required this.person,
    required this.subtotalShare,
    required this.taxShare,
    required this.tipShare,
    required this.total,
    this.isHighest = false,
    this.isLowest = false,
    this.isFree = false,
  });

  /// Returns a copy with [isHighest], [isLowest], or [isFree] replaced.
  SplitResult copyWith({bool? isHighest, bool? isLowest, bool? isFree}) =>
      SplitResult(
        person: person,
        subtotalShare: subtotalShare,
        taxShare: taxShare,
        tipShare: tipShare,
        total: total,
        isHighest: isHighest ?? this.isHighest,
        isLowest: isLowest ?? this.isLowest,
        isFree: isFree ?? this.isFree,
      );

  @override
  String toString() =>
      'SplitResult(${person.name}: \$${total.toStringAsFixed(2)})';
}
