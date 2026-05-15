import 'package:decimal/decimal.dart';
import '../../data/models/person.dart';
import '../../data/models/split_item.dart';
import '../../data/models/split_mode.dart';
import '../../data/models/split_result.dart';
import '../../data/models/split_session.dart';

/// Core split calculation engine.
///
/// PRECISION RULES:
/// 1. All intermediate math uses full [Decimal] precision.
/// 2. Rounding to 2dp happens ONLY in the returned [SplitResult.total].
/// 3. The last person absorbs any remaining cent from rounding
///    to prevent totals that don't add up to the grand total.
class SplitCalculator {
  const SplitCalculator._();

  /// Calculates the split results for all people in [session].
  ///
  /// [grandTotal] — pre-computed total (subtotal + tax + tip).
  /// [tip] — pre-computed tip amount.
  /// Returns an empty list if there are no people in the session.
  static List<SplitResult> calculate({
    required SplitSession session,
    required Decimal grandTotal,
    required Decimal tip,
  }) {
    if (session.people.isEmpty) return [];

    List<SplitResult> results = switch (session.splitMode) {
      SplitMode.equal => _equalSplit(session, grandTotal, tip),
      SplitMode.custom => _customSplit(session, grandTotal, tip),
      SplitMode.percentage => _percentageSplit(session, grandTotal, tip),
      SplitMode.itemized => _itemizedSplit(session, grandTotal, tip),
    };

    // Apply the "birthday person eats free" adjustment if active.
    if (session.freeDinerPersonId != null) {
      results = _applyFreeDiner(
        results,
        session.freeDinerPersonId!,
        grandTotal,
      );
    }

    return results;
  }

  // ── Equal split ──────────────────────────────────────────────

  /// Divides the bill equally among all people.
  static List<SplitResult> _equalSplit(
    SplitSession session,
    Decimal grandTotal,
    Decimal tip,
  ) {
    final count = session.people.length;
    final decimalCount = Decimal.fromInt(count);
    final subtotalPerPerson = session.subtotal / decimalCount;
    final taxPerPerson = session.tax / decimalCount;
    final tipPerPerson = tip / decimalCount;

    final results = <SplitResult>[];
    Decimal runningTotal = Decimal.zero;

    for (int i = 0; i < count; i++) {
      final isLast = i == count - 1;
      final rawTotal = subtotalPerPerson + taxPerPerson + tipPerPerson;
      final personTotal = isLast
          ? grandTotal - runningTotal
          : _round2(rawTotal);

      runningTotal += personTotal;

      results.add(SplitResult(
        person: session.people[i],
        subtotalShare: _round2(subtotalPerPerson),
        taxShare: _round2(taxPerPerson),
        tipShare: _round2(tipPerPerson),
        total: personTotal,
      ));
    }

    return _applyBadges(results);
  }

  // ── Custom amount split ──────────────────────────────────────

  /// Each person has a custom subtotal amount (stored in cents via shareWeight).
  /// Tax and tip are distributed proportionally.
  static List<SplitResult> _customSplit(
    SplitSession session,
    Decimal grandTotal,
    Decimal tip,
  ) {
    final subtotal = session.subtotal;
    if (subtotal == Decimal.zero) return [];

    final results = <SplitResult>[];
    Decimal runningTotal = Decimal.zero;
    final count = session.people.length;

    for (int i = 0; i < count; i++) {
      final person = session.people[i];
      final isLast = i == count - 1;

      // shareWeight stores the person's subtotal in cents.
      final personSubtotal =
          Decimal.fromInt(person.shareWeight) / Decimal.fromInt(100);
      final proportion =
          subtotal > Decimal.zero ? personSubtotal / subtotal : Decimal.zero;

      final personTax = _round2(session.tax * proportion);
      final personTip = _round2(tip * proportion);

      final rawTotal = isLast
          ? grandTotal - runningTotal
          : _round2(personSubtotal + personTax + personTip);

      runningTotal += rawTotal;

      results.add(SplitResult(
        person: person,
        subtotalShare: personSubtotal,
        taxShare: personTax,
        tipShare: personTip,
        total: rawTotal,
      ));
    }

    return _applyBadges(results);
  }

  // ── Percentage split ─────────────────────────────────────────

  /// Each person is assigned a percentage of the grand total.
  /// shareWeight stores the percentage × 100 in basis points (e.g. 3333 = 33.33%).
  static List<SplitResult> _percentageSplit(
    SplitSession session,
    Decimal grandTotal,
    Decimal tip,
  ) {
    final results = <SplitResult>[];
    Decimal runningTotal = Decimal.zero;
    final count = session.people.length;

    for (int i = 0; i < count; i++) {
      final person = session.people[i];
      final isLast = i == count - 1;

      // shareWeight is percentage × 10000 (basis points with 2 decimal precision).
      final proportion =
          Decimal.fromInt(person.shareWeight) / Decimal.fromInt(10000);

      final rawTotal = isLast
          ? grandTotal - runningTotal
          : _round2(grandTotal * proportion);

      runningTotal += rawTotal;

      results.add(SplitResult(
        person: person,
        subtotalShare: _round2(session.subtotal * proportion),
        taxShare: _round2(session.tax * proportion),
        tipShare: _round2(tip * proportion),
        total: rawTotal,
      ));
    }

    return _applyBadges(results);
  }

  // ── Itemized split (Phase 2) ─────────────────────────────────

  /// Each person is assigned specific line items.
  /// Shared items are split equally among their assignees.
  static List<SplitResult> _itemizedSplit(
    SplitSession session,
    Decimal grandTotal,
    Decimal tip,
  ) {
    // Build personId → raw subtotal from items.
    final personSubtotals = <String, Decimal>{
      for (final p in session.people) p.id: Decimal.zero,
    };

    for (final item in session.items ?? <SplitItem>[]) {
      final assignees = item.assigneeIds;
      if (assignees.isEmpty) continue;
      final share = item.price / Decimal.fromInt(assignees.length);
      for (final id in assignees) {
        if (personSubtotals.containsKey(id)) {
          personSubtotals[id] = personSubtotals[id]! + share;
        }
      }
    }

    final subtotal = session.subtotal;
    final results = <SplitResult>[];
    Decimal runningTotal = Decimal.zero;
    final count = session.people.length;

    for (int i = 0; i < count; i++) {
      final person = session.people[i];
      final isLast = i == count - 1;
      final personSubtotal = personSubtotals[person.id] ?? Decimal.zero;
      final proportion = subtotal > Decimal.zero
          ? personSubtotal / subtotal
          : Decimal.zero;

      final personTax = _round2(session.tax * proportion);
      final personTip = _round2(tip * proportion);

      final rawTotal = isLast
          ? grandTotal - runningTotal
          : _round2(personSubtotal + personTax + personTip);

      runningTotal += rawTotal;

      results.add(SplitResult(
        person: person,
        subtotalShare: personSubtotal,
        taxShare: personTax,
        tipShare: personTip,
        total: rawTotal,
      ));
    }

    return _applyBadges(results);
  }

  // ── Birthday person eats free ────────────────────────────────

  /// Zeroes out the free diner's total and redistributes their share
  /// proportionally among the remaining people.
  static List<SplitResult> _applyFreeDiner(
    List<SplitResult> results,
    String freeDinerPersonId,
    Decimal grandTotal,
  ) {
    final freeIndex =
        results.indexWhere((r) => r.person.id == freeDinerPersonId);
    if (freeIndex < 0) return results;

    final freeShare = results[freeIndex].total;
    final paying = results.where((r) => r.person.id != freeDinerPersonId).toList();
    if (paying.isEmpty) return results;

    // Distribute the free person's share proportionally.
    final payingTotal =
        paying.fold(Decimal.zero, (sum, r) => sum + r.total);

    final updated = <SplitResult>[];
    Decimal runningRedistributed = Decimal.zero;

    for (int i = 0; i < paying.length; i++) {
      final isLast = i == paying.length - 1;
      final r = paying[i];
      final proportion = payingTotal > Decimal.zero
          ? r.total / payingTotal
          : Decimal.zero;

      final extra = isLast
          ? freeShare - runningRedistributed
          : _round2(freeShare * proportion);

      runningRedistributed += extra;

      updated.add(SplitResult(
        person: r.person,
        subtotalShare: r.subtotalShare,
        taxShare: r.taxShare,
        tipShare: r.tipShare,
        total: r.total + extra,
      ));
    }

    // Re-insert the free diner with zero total.
    final freeResult = results[freeIndex].copyWith(isFree: true);
    updated.insert(freeIndex, freeResult.copyWith(isFree: true));

    // Re-index by original positions.
    final finalResults = results.map((r) {
      if (r.person.id == freeDinerPersonId) {
        return SplitResult(
          person: r.person,
          subtotalShare: r.subtotalShare,
          taxShare: r.taxShare,
          tipShare: r.tipShare,
          total: Decimal.zero,
          isFree: true,
        );
      }
      return updated.firstWhere((u) => u.person.id == r.person.id);
    }).toList();

    return _applyBadges(finalResults, excludeFree: true);
  }

  // ── Helpers ──────────────────────────────────────────────────

  /// Rounds a [Decimal] to 2 decimal places.
  static Decimal _round2(Decimal value) =>
      value.toDecimal(scaleOnInfinitePrecision: 2);

  /// Marks the highest and lowest payer in the result list.
  /// [excludeFree] skips zero-total free diners from badge assignment.
  static List<SplitResult> _applyBadges(
    List<SplitResult> results, {
    bool excludeFree = false,
  }) {
    if (results.length <= 1) return results;

    final eligible = excludeFree
        ? results.where((r) => !r.isFree).toList()
        : results;

    if (eligible.isEmpty) return results;

    final sorted = [...eligible]..sort((a, b) => a.total.compareTo(b.total));
    final minTotal = sorted.first.total;
    final maxTotal = sorted.last.total;

    // If all paying people owe the same amount, no badges.
    final allEqual = minTotal == maxTotal;

    return results.map((r) {
      if (r.isFree) return r;
      return r.copyWith(
        isHighest: !allEqual && r.total == maxTotal,
        isLowest: !allEqual && r.total == minTotal,
      );
    }).toList();
  }
}
