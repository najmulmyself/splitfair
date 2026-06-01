import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/person.dart';
import '../../../data/models/split_item.dart';
import '../../../data/models/split_mode.dart';
import '../../../data/models/split_result.dart';
import '../../../data/models/split_session.dart';
import '../../../domain/calculators/result_calculator.dart';
import '../../../core/utils/validators.dart';

part 'calculator_provider.g.dart';

/// How tax is entered — as a dollar amount or as a percentage.
enum TaxInputMode { dollar, percent }

/// How each person's share is rounded in the final display.
enum RoundingMode { none, up50c, up1 }

/// The complete state of the calculator screen.
@immutable
class CalculatorState {
  const CalculatorState({
    required this.subtotal,
    required this.tax,
    required this.taxInputMode,
    required this.tipPercentage,
    required this.tipOnSubtotal,
    required this.splitMode,
    required this.roundingMode,
    required this.currencyCode,
    required this.people,
    this.items,
    this.freeDinerPersonId,
    this.sessionLabel,
    this.useIndividualTips = false,
    this.perPersonTipBps = const {},
  });

  final Decimal subtotal;
  final Decimal tax;
  final TaxInputMode taxInputMode;
  final Decimal tipPercentage;
  final bool tipOnSubtotal;
  final SplitMode splitMode;
  final RoundingMode roundingMode;
  final String currencyCode;
  final List<Person> people;
  final List<SplitItem>? items;
  final String? freeDinerPersonId;
  final String? sessionLabel;
  /// Per-person tip in basis points (1800 = 18%). Only used when [useIndividualTips].
  final Map<String, int> perPersonTipBps;
  final bool useIndividualTips;

  /// Returns the default initial state.
  factory CalculatorState.initial() => CalculatorState(
        subtotal: Decimal.zero,
        tax: Decimal.zero,
        taxInputMode: TaxInputMode.dollar,
        tipPercentage: Decimal.parse('18'),
        tipOnSubtotal: true,
        splitMode: SplitMode.equal,
        roundingMode: RoundingMode.none,
        currencyCode: 'USD',
        people: const [],
        useIndividualTips: false,
        perPersonTipBps: const {},
      );

  /// Returns a copy with the given fields replaced.
  CalculatorState copyWith({
    Decimal? subtotal,
    Decimal? tax,
    TaxInputMode? taxInputMode,
    Decimal? tipPercentage,
    bool? tipOnSubtotal,
    SplitMode? splitMode,
    RoundingMode? roundingMode,
    String? currencyCode,
    List<Person>? people,
    List<SplitItem>? items,
    String? freeDinerPersonId,
    String? sessionLabel,
    bool clearFreeDiner = false,
    bool? useIndividualTips,
    Map<String, int>? perPersonTipBps,
  }) {
    return CalculatorState(
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      taxInputMode: taxInputMode ?? this.taxInputMode,
      tipPercentage: tipPercentage ?? this.tipPercentage,
      tipOnSubtotal: tipOnSubtotal ?? this.tipOnSubtotal,
      splitMode: splitMode ?? this.splitMode,
      roundingMode: roundingMode ?? this.roundingMode,
      currencyCode: currencyCode ?? this.currencyCode,
      people: people ?? this.people,
      items: items ?? this.items,
      freeDinerPersonId:
          clearFreeDiner ? null : freeDinerPersonId ?? this.freeDinerPersonId,
      sessionLabel: sessionLabel ?? this.sessionLabel,
      useIndividualTips: useIndividualTips ?? this.useIndividualTips,
      perPersonTipBps: perPersonTipBps ?? this.perPersonTipBps,
    );
  }
}

/// Manages the full calculator state and exposes computed results.
@riverpod
class CalculatorNotifier extends _$CalculatorNotifier {
  static const _uuid = Uuid();

  @override
  CalculatorState build() => CalculatorState.initial();

  // ── Inputs ────────────────────────────────────────────────────

  /// Sets the bill subtotal.
  void setSubtotal(Decimal value) {
    state = state.copyWith(subtotal: value);
  }

  /// Sets the tax amount.
  void setTax(Decimal value) {
    state = state.copyWith(tax: value);
  }

  /// Switches between dollar-amount and percentage tax input.
  void setTaxMode(TaxInputMode mode) {
    state = state.copyWith(taxInputMode: mode);
  }

  /// Sets the tip percentage (e.g. 18 for 18%).
  void setTipPercentage(Decimal percentage) {
    state = state.copyWith(tipPercentage: percentage);
  }

  /// Toggles tip calculation base between subtotal and subtotal + tax.
  void setTipOnSubtotal(bool value) {
    state = state.copyWith(tipOnSubtotal: value);
  }

  /// Changes the split mode.
  void setSplitMode(SplitMode mode) {
    state = state.copyWith(splitMode: mode);
  }

  /// Sets how each person's share is rounded.
  void setRoundingMode(RoundingMode mode) {
    state = state.copyWith(roundingMode: mode);
  }

  /// Changes the active currency.
  void setCurrency(String currencyCode) {
    state = state.copyWith(currencyCode: currencyCode);
  }

  /// Sets an optional label for this split session.
  void setSessionLabel(String? label) {
    state = state.copyWith(sessionLabel: label);
  }

  // ── People ────────────────────────────────────────────────────

  /// Adds a person with the given name.
  /// The color index cycles through [AppColors.personGradients].
  void addPerson(String name) {
    if (!Validators.isValidPersonName(name)) return;
    if (!Validators.isValidPersonCount(state.people.length + 1)) return;

    final colorIndex = state.people.length % 4;
    final person = Person(
      id: _uuid.v4(),
      name: name.trim(),
      colorIndex: colorIndex,
    );
    state = state.copyWith(people: [...state.people, person]);
  }

  /// Removes a person by ID. Cannot remove the last person.
  void removePerson(String personId) {
    if (state.people.length <= 1) return;
    final updated = state.people.where((p) => p.id != personId).toList();
    final clearFree = state.freeDinerPersonId == personId;
    state = state.copyWith(
      people: updated,
      clearFreeDiner: clearFree,
    );
  }

  /// Updates a person's custom subtotal amount (for custom split mode).
  /// [amount] is in currency units (e.g. 12.50 → stores as shareWeight 1250).
  void updatePersonAmount(String personId, Decimal amount) {
    final cents =
        (amount * Decimal.fromInt(100)).round(scale: 0).toBigInt().toInt();
    final updated = state.people.map((p) {
      return p.id == personId ? p.copyWith(shareWeight: cents) : p;
    }).toList();
    state = state.copyWith(people: updated);
  }

  /// Updates a person's percentage (for percentage split mode).
  /// [percentage] is in percent (e.g. 33.33 → stores as shareWeight 3333).
  void updatePersonPercentage(String personId, Decimal percentage) {
    final basisPoints =
        (percentage * Decimal.fromInt(100)).round(scale: 0).toBigInt().toInt();
    final updated = state.people.map((p) {
      return p.id == personId ? p.copyWith(shareWeight: basisPoints) : p;
    }).toList();
    state = state.copyWith(people: updated);
  }

  /// Sets or clears the birthday free diner.
  void setFreeDiner(String? personId) {
    if (personId == null) {
      state = state.copyWith(clearFreeDiner: true);
    } else {
      state = state.copyWith(freeDinerPersonId: personId);
    }
  }

  /// Toggles individual tips mode on/off.
  void toggleIndividualTips() {
    final next = !state.useIndividualTips;
    // Pre-fill everyone with the current global tip when enabling.
    final bps = next
        ? {
            for (final p in state.people)
              p.id: (state.tipPercentage * Decimal.fromInt(100))
                  .round(scale: 0)
                  .toBigInt()
                  .toInt()
          }
        : <String, int>{};
    state = state.copyWith(
        useIndividualTips: next, perPersonTipBps: bps);
  }

  /// Sets a person's individual tip percentage.
  void setPersonTip(String personId, Decimal percentage) {
    final bps = (percentage * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt()
        .toInt();
    final updated = Map<String, int>.from(state.perPersonTipBps)
      ..[personId] = bps;
    state = state.copyWith(perPersonTipBps: updated);
  }

  // ── Computed ─────────────────────────────────────────────────

  /// Returns true when a valid subtotal is entered and at least one person exists.
  bool get hasValidInput =>
      Validators.isValidAmount(state.subtotal) && state.people.isNotEmpty;

  /// Returns the computed tip amount.
  Decimal get computedTip {
    if (state.useIndividualTips && state.perPersonTipBps.isNotEmpty) {
      return results.fold(Decimal.zero, (s, r) => s + r.tipShare);
    }
    final session = _toSessionSnapshot();
    return ResultCalculator.compute(session).tip;
  }

  /// Returns the grand total (subtotal + tax + tip).
  Decimal get grandTotal {
    if (state.useIndividualTips && state.perPersonTipBps.isNotEmpty) {
      return results.fold(Decimal.zero, (s, r) => s + r.total);
    }
    final session = _toSessionSnapshot();
    return ResultCalculator.compute(session).grandTotal;
  }

  /// Returns the computed per-person split results.
  /// When individual tips are active, recalculates each person's tip share.
  List<SplitResult> get results {
    if (!hasValidInput) return [];
    final session = _toSessionSnapshot();
    final base = ResultCalculator.compute(session).perPerson;
    if (!state.useIndividualTips || state.perPersonTipBps.isEmpty) return base;

    // Override each person's tip with their individual rate.
    final overridden = base.map((r) {
      final bps = state.perPersonTipBps[r.person.id];
      if (bps == null) return r;
      final tipPct = (Decimal.fromInt(bps) / Decimal.fromInt(10000))
          .toDecimal(scaleOnInfinitePrecision: 10);
      final base_ = state.tipOnSubtotal
          ? r.subtotalShare
          : r.subtotalShare + r.taxShare;
      final newTip = (base_ * tipPct).round(scale: 2);
      final newTotal = (r.subtotalShare + r.taxShare + newTip).round(scale: 2);
      return SplitResult(
        person: r.person,
        subtotalShare: r.subtotalShare,
        taxShare: r.taxShare,
        tipShare: newTip,
        total: newTotal,
      );
    }).toList();
    return overridden;
  }

  /// In custom mode: true if the sum of entered amounts equals the subtotal.
  bool get customAmountsBalance {
    if (state.splitMode != SplitMode.custom) return true;
    final amounts = state.people.map((p) {
      return (Decimal.fromInt(p.shareWeight) / Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 2);
    }).toList();
    return Validators.customAmountsBalance(amounts, state.subtotal);
  }

  /// In percentage mode: remaining unallocated percentage.
  Decimal get remainingPercentage {
    if (state.splitMode != SplitMode.percentage) return Decimal.zero;
    final allocated = state.people.fold(Decimal.zero, (sum, p) {
      final share = (Decimal.fromInt(p.shareWeight) / Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 2);
      return sum + share;
    });
    final remaining = Decimal.fromInt(100) - allocated;
    return remaining < Decimal.zero ? Decimal.zero : remaining;
  }

  // ── Session actions ───────────────────────────────────────────

  /// Resets all calculator state to initial values.
  void reset() {
    state = CalculatorState.initial();
  }

  /// Snapshots the current state as a [SplitSession] (for saving to history).
  SplitSession toSession() => _toSessionSnapshot();

  // ── Private helpers ───────────────────────────────────────────

  SplitSession _toSessionSnapshot() => SplitSession(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        label: state.sessionLabel,
        subtotalRaw: state.subtotal.toString(),
        taxRaw: state.tax.toString(),
        tipPercentageRaw: state.tipPercentage.toString(),
        tipOnSubtotal: state.tipOnSubtotal,
        splitMode: state.splitMode,
        people: state.people,
        items: state.items,
        currencyCode: state.currencyCode,
        freeDinerPersonId: state.freeDinerPersonId,
      );
}
