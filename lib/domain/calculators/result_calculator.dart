import 'package:decimal/decimal.dart';
import '../../data/models/split_result.dart';
import '../../data/models/split_session.dart';
import 'tip_calculator.dart';
import 'split_calculator.dart';

/// Combines [TipCalculator] and [SplitCalculator] into a single result.
///
/// This is the entry point for all calculation calls from providers.
/// It returns both the per-person results and the totals summary.
class ResultCalculator {
  const ResultCalculator._();

  /// Compute the full bill results from a [SplitSession].
  ///
  /// Returns a [BillResult] containing the tip, grand total, and per-person results.
  static BillResult compute(SplitSession session) {
    final tip = TipCalculator.calculateTip(
      subtotal: session.subtotal,
      tax: session.tax,
      tipPercentage: session.tipPercentage,
      onSubtotal: session.tipOnSubtotal,
    );

    final total = TipCalculator.grandTotal(
      subtotal: session.subtotal,
      tax: session.tax,
      tip: tip,
    );

    final results = SplitCalculator.calculate(
      session: session,
      grandTotal: total,
      tip: tip,
    );

    return BillResult(
      tip: tip,
      grandTotal: total,
      perPerson: results,
    );
  }
}

/// Holds the fully computed bill totals and per-person results.
class BillResult {
  /// Computed tip amount.
  final Decimal tip;

  /// Grand total (subtotal + tax + tip).
  final Decimal grandTotal;

  /// Per-person split results.
  final List<SplitResult> perPerson;

  const BillResult({
    required this.tip,
    required this.grandTotal,
    required this.perPerson,
  });

  /// True if there are per-person results to display.
  bool get hasResults => perPerson.isNotEmpty;
}
