import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../data/models/currency.dart';
import '../../data/models/split_session.dart';
import '../../data/sources/currency_data_source.dart';
import '../currency/currency_provider.dart';
import '../history/history_provider.dart';
import '../settings/settings_provider.dart';
import '../tip_guide/tip_guide_sheet.dart';
import 'providers/calculator_provider.dart';
import '../../domain/calculators/tip_calculator.dart';
import 'widgets/bill_card.dart';
import 'widgets/numpad.dart';
import 'widgets/people_row.dart';
import 'widgets/result_section.dart';
import 'widgets/tip_section.dart';

/// The main bill-splitting calculator screen.
class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  String _billBuffer = '';
  String _taxBuffer = '';
  bool _isEditingBill = false;
  bool _isEditingTax = false;
  String? _activePersonId;

  // Currency info loaded from assets
  Currency _activeCurrency = const Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsCurrency = ref.read(currencyNotifierProvider);
      ref
          .read(calculatorNotifierProvider.notifier)
          .setCurrency(settingsCurrency);
      _loadActiveCurrencyByCode(settingsCurrency);
      _checkDraft();
      _incrementSessionAndMaybeShowPro();
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  // ── Draft save / restore ──────────────────────────────────────

  void _saveDraft() {
    final s = ref.read(calculatorNotifierProvider);
    if (s.subtotal <= Decimal.zero) return;
    final data = {
      'subtotal': s.subtotal.toString(),
      'tax': s.tax.toString(),
      'taxMode': s.taxInputMode.name,
      'tip': s.tipPercentage.toString(),
      'tipOnSubtotal': s.tipOnSubtotal,
      'splitMode': s.splitMode.name,
      'currency': s.currencyCode,
      'people': s.people.map((p) => p.name).toList(),
    };
    ref.read(settingsRepositoryProvider).saveDraft(json.encode(data));
  }

  Future<void> _incrementSessionAndMaybeShowPro() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.incrementSessionCount();
    final isPro = ref.read(settingsNotifierProvider).isPro;
    if (!isPro && repo.sessionCount == 3) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.push(AppRoutes.proUnlock);
    }
  }

  Future<void> _checkDraft() async {
    final repo = ref.read(settingsRepositoryProvider);
    final raw = repo.draft;
    if (raw == null) return;
    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      final subtotal = data['subtotal'] as String? ?? '0';
      if ((Decimal.tryParse(subtotal) ?? Decimal.zero) <= Decimal.zero) return;
      final people = (data['people'] as List?)?.cast<String>() ?? [];
      if (!mounted) return;
      final resume = await showDialog<bool>(
        context: context,
        builder: (ctx) => _DraftRestoreDialog(
          subtotal: subtotal,
          currency: data['currency'] as String? ?? 'USD',
          peopleCount: people.length,
        ),
      );
      if (resume == true && mounted) {
        _restoreDraft(data, people);
      } else {
        repo.clearDraft();
      }
    } catch (_) {
      repo.clearDraft();
    }
  }

  void _restoreDraft(Map<String, dynamic> data, List<String> people) {
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    final subtotal = Decimal.tryParse(data['subtotal'] as String? ?? '0') ?? Decimal.zero;
    final tax = Decimal.tryParse(data['tax'] as String? ?? '0') ?? Decimal.zero;
    final tip = Decimal.tryParse(data['tip'] as String? ?? '18') ?? Decimal.fromInt(18);
    notifier.setSubtotal(subtotal);
    notifier.setTax(tax);
    notifier.setTipPercentage(tip);
    notifier.setTipOnSubtotal((data['tipOnSubtotal'] as bool?) ?? true);
    notifier.setCurrency(data['currency'] as String? ?? 'USD');
    if ((data['taxMode'] as String?) == 'percent') {
      notifier.setTaxMode(TaxInputMode.percent);
    }
    for (final name in people) {
      notifier.addPerson(name);
    }
    setState(() {
      _billBuffer = subtotal > Decimal.zero
          ? subtotal.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '')
          : '';
    });
  }

  Future<void> _loadActiveCurrencyByCode(String code) async {
    try {
      final match = await CurrencyDataSource.instance.findByCode(code);
      if (mounted && match != null) setState(() => _activeCurrency = match);
    } catch (_) {
      // Keep current
    }
  }

  bool get _isEditing => _isEditingBill || _isEditingTax;

  // ── Numpad input ──────────────────────────────────────────────

  void _onNumpadKey(String key) {
    Haptics.lightImpact();
    setState(() {
      if (_isEditingBill) {
        _billBuffer = _applyKey(_billBuffer, key);
        _commitBill();
      } else if (_isEditingTax) {
        _taxBuffer = _applyKey(_taxBuffer, key);
        _commitTax();
      }
    });
  }

  void _onDone() {
    Haptics.impact();
    setState(() {
      _isEditingBill = false;
      _isEditingTax = false;
    });
  }

  String _applyKey(String buffer, String key) {
    if (key == '⌫') {
      return buffer.isEmpty ? '' : buffer.substring(0, buffer.length - 1);
    }
    if (key == '.') {
      if (buffer.contains('.')) return buffer;
      return buffer.isEmpty ? '0.' : '$buffer.';
    }
    // Digit
    if (buffer == '0') return key;
    if (buffer.contains('.')) {
      final dec = buffer.split('.')[1];
      if (dec.length >= 2) return buffer;
    } else {
      if (buffer.length >= 6) return buffer;
    }
    return '$buffer$key';
  }

  void _commitBill() {
    final value = _billBuffer.isEmpty
        ? Decimal.zero
        : Decimal.tryParse(_billBuffer) ?? Decimal.zero;
    ref.read(calculatorNotifierProvider.notifier).setSubtotal(value);
  }

  void _commitTax() {
    final raw = _taxBuffer.isEmpty ? '0' : _taxBuffer;
    final input = Decimal.tryParse(raw) ?? Decimal.zero;
    final state = ref.read(calculatorNotifierProvider);
    Decimal taxAmount;
    if (state.taxInputMode == TaxInputMode.percent) {
      taxAmount = (state.subtotal * input / Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 2);
    } else {
      taxAmount = input;
    }
    ref.read(calculatorNotifierProvider.notifier).setTax(taxAmount);
  }

  // ── People ────────────────────────────────────────────────────

  Future<void> _showAddPersonDialog() async {
    Haptics.impact();
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddPersonSheet(controller: controller),
    );
    if (name != null && name.trim().isNotEmpty) {
      final trimmed = name.trim();
      ref.read(calculatorNotifierProvider.notifier).addPerson(trimmed);
      ref.read(recentNamesRepositoryProvider).add(trimmed);
    }
  }

  Future<void> _showTipGuide() async {
    Haptics.impact();
    final midPct = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => const TipGuideSheet(),
      ),
    );
    if (midPct != null) {
      final d = Decimal.tryParse(midPct);
      if (d != null) {
        ref.read(calculatorNotifierProvider.notifier).setTipPercentage(d);
        Haptics.selection();
      }
    }
  }

  Future<void> _showCustomTipDialog() async {
    Haptics.impact();
    final result = await showModalBottomSheet<Decimal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomTipSheet(
        current: ref.read(calculatorNotifierProvider).tipPercentage,
      ),
    );
    if (result != null) {
      ref.read(calculatorNotifierProvider.notifier).setTipPercentage(result);
      Haptics.selection();
    }
  }

  void _onPersonLongPress(String personId) {
    final people = ref.read(calculatorNotifierProvider).people;
    if (people.length <= 1) return;
    Haptics.heavyImpact();
    final person = people.firstWhere((p) => p.id == personId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RemovePersonSheet(
        personName: person.name,
        colorIndex: person.colorIndex,
        onRemove: () {
          ref.read(calculatorNotifierProvider.notifier).removePerson(personId);
          if (_activePersonId == personId) {
            setState(() => _activePersonId = null);
          }
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // React to currency changes
    ref.listen<String>(currencyNotifierProvider, (prev, next) {
      if (prev != next) _loadActiveCurrencyByCode(next);
    });

    // Auto-save draft on every calculator state change
    ref.listen<CalculatorState>(calculatorNotifierProvider, (prev, next) {
      _saveDraft();
    });

    final calcState = ref.watch(calculatorNotifierProvider);
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    final hasBill = calcState.subtotal > Decimal.zero;
    final hasPeople = calcState.people.isNotEmpty;
    final hasResults = notifier.hasValidInput && hasPeople;
    final results = hasResults ? notifier.results : <dynamic>[];

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────
            _CalcAppBar(
              onHistory: () => context.push(AppRoutes.history),
              onSettings: () => context.push(AppRoutes.settings),
            ),

            // ── Scrollable content ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Who pays next banner
                    _WhoNxtBanner(people: calcState.people),

                    // Bill card
                    BillCard(
                      billBuffer: _billBuffer,
                      taxBuffer: _taxBuffer,
                      isEditingBill: _isEditingBill,
                      isEditingTax: _isEditingTax,
                      taxMode: calcState.taxInputMode,
                      currencyCode: _activeCurrency.code,
                      currencySymbol: _activeCurrency.symbol,
                      currencyFlag: _activeCurrency.flag,
                      onTap: () => setState(() {
                        _isEditingBill = true;
                        _isEditingTax = false;
                      }),
                      onTaxTap: () => setState(() {
                        _isEditingTax = true;
                        _isEditingBill = false;
                      }),
                      onCurrencyTap: () {
                        Haptics.selection();
                        context.push(AppRoutes.currency);
                      },
                      onTaxModeChanged: (mode) {
                        notifier.setTaxMode(mode);
                        _taxBuffer = '';
                        notifier.setTax(Decimal.zero);
                      },
                    ).animate().fade(duration: 300.ms).slideY(
                        begin: -0.05,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 14),

                    // People row
                    PeopleRow(
                      people: calcState.people,
                      activePersonId: _activePersonId,
                      canRemove: calcState.people.length > 1,
                      onAdd: _showAddPersonDialog,
                      onSelect: (id) => setState(() => _activePersonId = id),
                      onLongPress: _onPersonLongPress,
                    ).animate().fade(duration: 300.ms, delay: 80.ms),

                    // Tip section (visible when people added + not editing)
                    if (!_isEditing && hasPeople) ...[
                      const SizedBox(height: 14),
                      TipSection(
                        selectedTip: calcState.tipPercentage,
                        tipOnSubtotal: calcState.tipOnSubtotal,
                        hasTax: calcState.tax > Decimal.zero,
                        tipSavings: calcState.tax > Decimal.zero
                            ? TipCalculator.tipDifference(
                                subtotal: calcState.subtotal,
                                tax: calcState.tax,
                                tipPercentage: calcState.tipPercentage,
                              )
                            : null,
                        onTipSelected: (tip) {
                          notifier.setTipPercentage(tip);
                          Haptics.selection();
                        },
                        onToggleTipBase: (val) {
                          notifier.setTipOnSubtotal(val);
                          Haptics.selection();
                        },
                        onMoreTap: _showCustomTipDialog,
                        onGuideTap: _showTipGuide,
                      ).animate().fade(duration: 280.ms).slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut),
                    ],

                    // Rounding row (shown when results exist)
                    if (!_isEditing && hasResults) ...[
                      const SizedBox(height: 10),
                      _RoundingRow(
                        mode: calcState.roundingMode,
                        onChanged: (mode) {
                          notifier.setRoundingMode(mode);
                          Haptics.selection();
                        },
                      ),
                    ],

                    // Flex split toggle + remainder banner
                    if (!_isEditing && hasResults) ...[
                      const SizedBox(height: 10),
                      _FlexSplitToggle(
                        enabled: calcState.useFlexSplit,
                        onToggle: () {
                          notifier.toggleFlexSplit();
                          Haptics.selection();
                        },
                      ),
                    ],
                    if (!_isEditing && hasResults && calcState.useFlexSplit) ...[
                      const SizedBox(height: 8),
                      _FlexRemainderBanner(
                        remainder: notifier.flexRemainder,
                        equalCount: calcState.people
                            .where((p) =>
                                !calcState.flexOverrides.containsKey(p.id))
                            .length,
                        currencySymbol: _activeCurrency.symbol,
                        exceeds: notifier.flexOverridesExceedTotal,
                      ),
                    ],

                    // Individual tips toggle
                    if (!_isEditing && hasResults) ...[
                      const SizedBox(height: 10),
                      _IndividualTipsToggle(
                        enabled: calcState.useIndividualTips,
                        onToggle: () {
                          notifier.toggleIndividualTips();
                          Haptics.selection();
                        },
                      ),
                    ],

                    // Result section
                    if (!_isEditing && hasResults) ...[
                      const SizedBox(height: 10),
                      ResultSection(
                        results: notifier.results,
                        grandTotal: notifier.grandTotal,
                        tip: notifier.computedTip,
                        currencyCode: calcState.currencyCode,
                        currencySymbol: _activeCurrency.symbol,
                        useIndividualTips: calcState.useIndividualTips,
                        perPersonTipBps: calcState.perPersonTipBps,
                        onPersonTipChanged: (personId, pct) =>
                            notifier.setPersonTip(personId, pct),
                        useFlexSplit: calcState.useFlexSplit,
                        flexOverrides: calcState.flexOverrides,
                        onFlexOverrideChanged: (personId, override) =>
                            override == null
                                ? notifier.clearFlexOverride(personId)
                                : notifier.setFlexOverride(personId, override),
                      ),
                    ],

                    // Hint text when no people yet
                    if (!_isEditing && !hasPeople) ...[
                      const SizedBox(height: 16),
                      _HintCard(
                        onJustMe: () {
                          final trimmed = 'Me';
                          ref
                              .read(calculatorNotifierProvider.notifier)
                              .addPerson(trimmed);
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Bottom: numpad or action button ────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _isEditing
                  ? Numpad(
                      key: const ValueKey('numpad'),
                      onKey: _onNumpadKey,
                      onDone: _onDone,
                    )
                  : _BottomBar(
                      key: const ValueKey('bottom_bar'),
                      hasResults: results.isNotEmpty &&
                          !notifier.flexOverridesExceedTotal,
                      hasBill: hasBill,
                      onShare: () async {
                        final calcState = ref.read(calculatorNotifierProvider);
                        final session = SplitSession(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          createdAt: DateTime.now(),
                          label: calcState.sessionLabel,
                          subtotalRaw: calcState.subtotal.toStringAsFixed(2),
                          taxRaw: calcState.tax.toStringAsFixed(2),
                          tipPercentageRaw:
                              calcState.tipPercentage.toStringAsFixed(2),
                          tipOnSubtotal: calcState.tipOnSubtotal,
                          splitMode: calcState.splitMode,
                          people: calcState.people,
                          currencyCode: calcState.currencyCode,
                        );
                        await ref
                            .read(historyNotifierProvider.notifier)
                            .save(session);
                        ref.read(settingsRepositoryProvider).clearDraft();
                        if (context.mounted) {
                          context.push(AppRoutes.share);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────

class _CalcAppBar extends StatelessWidget {
  const _CalcAppBar({required this.onHistory, required this.onSettings});
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
      child: Row(
        children: [
          // Logo mark
          _LogoMark(),
          const SizedBox(width: 10),
          Text(
            'DivvyBill',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const Spacer(),
          _AppBarBtn(
            icon: Icons.history_rounded,
            onTap: onHistory,
          ),
          const SizedBox(width: 4),
          _AppBarBtn(
            icon: Icons.settings_rounded,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  const _AppBarBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surface1,
          border: Border.all(color: context.colors.borderDefault),
        ),
        child: Icon(icon, color: context.colors.textSecondary, size: 18),
      ),
    );
  }
}

// ── Mini logo mark for app bar ────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const size = 34.0;
    const overlap = 10.0;
    return SizedBox(
      width: size * 2 - overlap,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _Circle(
              label: 'S',
              gradient: const LinearGradient(
                colors: [Color(0xFF9B7FFF), Color(0xFF6A3FE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              size: size,
            ),
          ),
          Positioned(
            right: 0,
            child: _Circle(
              label: 'F',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              size: size,
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(
      {required this.label, required this.gradient, required this.size});
  final String label;
  final LinearGradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Hint card ─────────────────────────────────────────────────────────────

class _HintCard extends StatelessWidget {
  const _HintCard({required this.onJustMe});
  final VoidCallback onJustMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: context.colors.surface1.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryViolet.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primaryViolet.withOpacity(0.6), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Add people to split the bill.",
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 14,
                    height: 1.5,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Haptics.impact();
              onJustMe();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryViolet.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primaryViolet.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_rounded,
                      size: 16,
                      color: AppColors.primaryViolet.withOpacity(0.8)),
                  const SizedBox(width: 8),
                  Text(
                    "Just me — solo tip calc",
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryViolet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 350.ms, delay: 150.ms);
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    super.key,
    required this.hasResults,
    required this.hasBill,
    required this.onShare,
  });
  final bool hasResults;
  final bool hasBill;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 12),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: hasResults
            ? _ShareButton(onTap: onShare)
            : _DisabledButton(hasBill: hasBill),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B9D).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Share Results',
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({required this.hasBill});
  final bool hasBill;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Center(
        child: Text(
          hasBill ? 'Add people to continue' : 'Enter a bill to continue',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: context.colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ── Add person bottom sheet ───────────────────────────────────────────────

class _AddPersonSheet extends ConsumerStatefulWidget {
  const _AddPersonSheet({required this.controller});
  final TextEditingController controller;

  @override
  ConsumerState<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<_AddPersonSheet> {
  List<String> _recentNames = [];

  @override
  void initState() {
    super.initState();
    _recentNames = ref.read(recentNamesRepositoryProvider).getAll();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Who's at the table?",
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          // Recent names chips
          if (_recentNames.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final n = _recentNames[i];
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryViolet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                            color:
                                AppColors.primaryViolet.withOpacity(0.3)),
                      ),
                      child: Text(
                        n,
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryViolet,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: widget.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter a name',
              hintStyle: TextStyle(color: context.colors.textTertiary),
              filled: true,
              fillColor: context.colors.surface2,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primaryViolet, width: 1.5),
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.pop(context, value.trim());
              }
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final name = widget.controller.text.trim();
                if (name.isNotEmpty) Navigator.pop(context, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Add Person',
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Remove person iOS-style action sheet ─────────────────────────────────

class _RemovePersonSheet extends StatelessWidget {
  const _RemovePersonSheet({
    required this.personName,
    required this.colorIndex,
    required this.onRemove,
    required this.onCancel,
  });

  final String personName;
  final int colorIndex;
  final VoidCallback onRemove;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final gradients = AppColors.personGradients;
    final gradient = gradients[colorIndex % gradients.length];
    final initial = personName.isNotEmpty ? personName[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottom + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main action card ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface1,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.borderDefault),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                // Person info header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [gradient[0], gradient[1]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontFamily: '.SF Pro Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          personName,
                          style: TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(height: 1, color: context.colors.borderDefault),

                // Remove button
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_remove_rounded,
                          color: AppColors.coralPink,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remove from split',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.coralPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Cancel button ─────────────────────────────────────
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: context.colors.surface1,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.borderDefault),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom tip bottom sheet ───────────────────────────────────────────────

class _CustomTipSheet extends StatefulWidget {
  const _CustomTipSheet({required this.current});
  final Decimal current;

  @override
  State<_CustomTipSheet> createState() => _CustomTipSheetState();
}

class _CustomTipSheetState extends State<_CustomTipSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current custom value if it's not a preset
    const presets = [10, 15, 18, 20, 25];
    final currentInt = widget.current.toBigInt().toInt();
    final isPreset = presets.contains(currentInt) &&
        widget.current == Decimal.fromInt(currentInt);
    _controller = TextEditingController(
        text: isPreset ? '' : widget.current.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0 || parsed > 100) return;
    final d = Decimal.parse(parsed.toStringAsFixed(2));
    Navigator.pop(context, d);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
           Text(
            'Custom Tip',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
           Text(
            'Enter any percentage between 0 and 100.',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Quick option — No Tip
          GestureDetector(
            onTap: () => Navigator.pop(context, Decimal.zero),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.borderDefault),
              ),
              child: Text(
                'No Tip (0%)',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 12',
              suffixText: '%',
              suffixStyle: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryViolet,
              ),
              hintStyle: TextStyle(color: context.colors.textTertiary),
              filled: true,
              fillColor: context.colors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primaryViolet, width: 1.5),
              ),
            ),
            onSubmitted: _submit,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _submit(_controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Apply Tip',
                style: TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rounding row ──────────────────────────────────────────────────────────

class _RoundingRow extends StatelessWidget {
  const _RoundingRow({required this.mode, required this.onChanged});
  final RoundingMode mode;
  final ValueChanged<RoundingMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'ROUND UP EACH SHARE',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: [
            _RoundChip(
              label: 'Off',
              selected: mode == RoundingMode.none,
              onTap: () => onChanged(RoundingMode.none),
            ),
            const SizedBox(width: 8),
            _RoundChip(
              label: '+¢50',
              selected: mode == RoundingMode.up50c,
              onTap: () => onChanged(RoundingMode.up50c),
            ),
            const SizedBox(width: 8),
            _RoundChip(
              label: '+\$1',
              selected: mode == RoundingMode.up1,
              onTap: () => onChanged(RoundingMode.up1),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundChip extends StatelessWidget {
  const _RoundChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primaryViolet : context.colors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryViolet
                : context.colors.borderDefault,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryViolet.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                selected ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Draft restore dialog ──────────────────────────────────────────────────

class _DraftRestoreDialog extends StatelessWidget {
  const _DraftRestoreDialog({
    required this.subtotal,
    required this.currency,
    required this.peopleCount,
  });
  final String subtotal;
  final String currency;
  final int peopleCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Continue last session?',
        style: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
      content: Text(
        '$currency $subtotal · $peopleCount ${peopleCount == 1 ? 'person' : 'people'}',
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 14,
          color: context.colors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Start fresh',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Continue',
            style: TextStyle(
              color: AppColors.primaryViolet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Who pays next banner ──────────────────────────────────────────────────

class _WhoNxtBanner extends ConsumerWidget {
  const _WhoNxtBanner({required this.people});
  final List<dynamic> people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (people.isEmpty) return const SizedBox.shrink();
    final lastPayer =
        ref.read(settingsRepositoryProvider).lastPayerName;
    if (lastPayer == null) return const SizedBox.shrink();
    final names = (people as List).map((p) => p.name as String).toList();
    if (!names.contains(lastPayer)) return const SizedBox.shrink();
    final others = names.where((n) => n != lastPayer).toList();
    final suggestion = others.isNotEmpty ? others.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryViolet.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryViolet.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion != null
                  ? '$lastPayer covered last time — $suggestion\'s turn?'
                  : '$lastPayer covered last time.',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                color: AppColors.primaryViolet,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(settingsRepositoryProvider).clearLastPayer(),
            child: Icon(Icons.close_rounded,
                size: 16, color: AppColors.primaryViolet.withOpacity(0.6)),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: -0.2, end: 0, duration: 300.ms);
  }
}

// ── Flex split toggle ─────────────────────────────────────────────────────

class _FlexSplitToggle extends StatelessWidget {
  const _FlexSplitToggle({required this.enabled, required this.onToggle});
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.warmAmber.withOpacity(0.12)
              : context.colors.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppColors.warmAmber.withOpacity(0.45)
                : context.colors.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.balance_rounded,
              size: 16,
              color: enabled ? AppColors.warmAmber : context.colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Customize who pays what',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: enabled ? AppColors.warmAmber : context.colors.textSecondary,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: enabled ? AppColors.warmAmber : context.colors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.borderDefault),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Flex remainder banner ─────────────────────────────────────────────────

class _FlexRemainderBanner extends StatelessWidget {
  const _FlexRemainderBanner({
    required this.remainder,
    required this.equalCount,
    required this.currencySymbol,
    required this.exceeds,
  });
  final Decimal remainder;
  final int equalCount;
  final String currencySymbol;
  final bool exceeds;

  @override
  Widget build(BuildContext context) {
    final color = exceeds ? AppColors.coralPink : AppColors.emeraldMint;
    final String msg;
    if (exceeds) {
      msg = 'Overrides exceed the total — reduce amounts';
    } else if (equalCount == 0) {
      msg = 'Everyone has a custom amount';
    } else {
      final share = equalCount > 0
          ? (remainder / Decimal.fromInt(equalCount))
              .toDecimal(scaleOnInfinitePrecision: 2)
              .round(scale: 2)
          : Decimal.zero;
      msg =
          '$currencySymbol${remainder.toStringAsFixed(2)} left → $equalCount ${equalCount == 1 ? 'person' : 'people'} × $currencySymbol${share.toStringAsFixed(2)} each';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            exceeds ? Icons.warning_rounded : Icons.info_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual tips toggle ────────────────────────────────────────────────

class _IndividualTipsToggle extends StatelessWidget {
  const _IndividualTipsToggle(
      {required this.enabled, required this.onToggle});
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryViolet.withOpacity(0.12)
              : context.colors.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppColors.primaryViolet.withOpacity(0.4)
                : context.colors.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_pin_rounded,
              size: 16,
              color: enabled
                  ? AppColors.primaryViolet
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Individual tips per person',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: enabled
                    ? AppColors.primaryViolet
                    : context.colors.textSecondary,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primaryViolet
                    : context.colors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.borderDefault),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    enabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
