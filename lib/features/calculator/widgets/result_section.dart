import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/split_result.dart';
import '../providers/calculator_provider.dart' show FlexOverride, FlexOverrideType;

/// Shows the computed split summary and per-person result cards.
class ResultSection extends StatelessWidget {
  const ResultSection({
    super.key,
    required this.results,
    required this.grandTotal,
    required this.tip,
    required this.currencyCode,
    required this.currencySymbol,
    this.useIndividualTips = false,
    this.perPersonTipBps = const {},
    this.onPersonTipChanged,
    this.useFlexSplit = false,
    this.flexOverrides = const {},
    this.onFlexOverrideChanged,
  });

  final List<SplitResult> results;
  final Decimal grandTotal;
  final Decimal tip;
  final String currencyCode;
  final String currencySymbol;
  final bool useIndividualTips;
  final Map<String, int> perPersonTipBps;
  final void Function(String personId, Decimal pct)? onPersonTipChanged;
  final bool useFlexSplit;
  final Map<String, FlexOverride> flexOverrides;
  /// Called with null to clear the override (back to equal).
  final void Function(String personId, FlexOverride? override)? onFlexOverrideChanged;

  @override
  Widget build(BuildContext context) {
    final avg = results.isEmpty
        ? Decimal.zero
        : (grandTotal / Decimal.fromInt(results.length))
            .toDecimal(scaleOnInfinitePrecision: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'RESULT',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Summary row ───────────────────────────────────────
        _SummaryRow(
          total: grandTotal,
          tip: tip,
          avg: avg,
          currencySymbol: currencySymbol,
        ),

        const SizedBox(height: 10),

        // ── Per-person cards ──────────────────────────────────
        ...results.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final bps = perPersonTipBps[r.person.id];
          final tipPct = bps != null
              ? (Decimal.fromInt(bps) / Decimal.fromInt(100))
                  .toDecimal(scaleOnInfinitePrecision: 1)
              : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PersonResultCard(
              result: r,
              currencySymbol: currencySymbol,
              showTipControl: useIndividualTips,
              individualTipPct: tipPct,
              onTipChanged: onPersonTipChanged != null
                  ? (pct) => onPersonTipChanged!(r.person.id, pct)
                  : null,
              showFlexControl: useFlexSplit,
              flexOverride: flexOverrides[r.person.id],
              onFlexOverrideChanged: onFlexOverrideChanged != null
                  ? (o) => onFlexOverrideChanged!(r.person.id, o)
                  : null,
            )
                .animate()
                .fade(duration: 300.ms, delay: Duration(milliseconds: 80 * i))
                .slideY(
                  begin: 0.12,
                  end: 0,
                  duration: 350.ms,
                  delay: Duration(milliseconds: 80 * i),
                  curve: Curves.easeOut,
                ),
          );
        }),
      ],
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.tip,
    required this.avg,
    required this.currencySymbol,
  });

  final Decimal total;
  final Decimal tip;
  final Decimal avg;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryItem(
            label: 'Total',
            value: '$currencySymbol${total.toStringAsFixed(2)}'),
        _divider(context),
        _SummaryItem(
          label: 'Tip',
          value: '+$currencySymbol${tip.toStringAsFixed(2)}',
          valueColor: AppColors.emeraldMint,
        ),
        _divider(context),
        _SummaryItem(
            label: 'Avg', value: '$currencySymbol${avg.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: context.colors.borderDefault,
      );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Person result card ────────────────────────────────────────────────────

class _PersonResultCard extends StatelessWidget {
  const _PersonResultCard({
    required this.result,
    required this.currencySymbol,
    this.showTipControl = false,
    this.individualTipPct,
    this.onTipChanged,
    this.showFlexControl = false,
    this.flexOverride,
    this.onFlexOverrideChanged,
  });
  final SplitResult result;
  final String currencySymbol;
  final bool showTipControl;
  final Decimal? individualTipPct;
  final ValueChanged<Decimal>? onTipChanged;
  final bool showFlexControl;
  final FlexOverride? flexOverride;
  final void Function(FlexOverride? override)? onFlexOverrideChanged;

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    final gradient = gradients[result.person.colorIndex % gradients.length];
    final isLowest = result.isLowest;
    final isHighest = result.isHighest;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color? cardBg;
    if (isLowest) {
      cardBg = isDark ? const Color(0xFF0D2820) : const Color(0xFFE6FBF5);
    }
    if (isHighest) {
      cardBg = isDark ? const Color(0xFF2A0F18) : const Color(0xFFFFEDF3);
    }
    if (result.isFree) {
      cardBg = isDark ? const Color(0xFF332309) : const Color(0xFFFFF4E3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg ?? context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isFree
              ? AppColors.warmAmber.withOpacity(0.25)
              : isLowest
                  ? AppColors.emeraldMint.withOpacity(0.25)
                  : isHighest
                      ? AppColors.coralPink.withOpacity(0.25)
                      : context.colors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
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
                result.person.name.isNotEmpty
                    ? result.person.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontFamily: '.SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + OWES label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      result.person.name,
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (isLowest) ...[
                      const SizedBox(width: 6),
                      _Badge(label: 'LEAST', color: AppColors.emeraldMint),
                    ],
                    if (isHighest) ...[
                      const SizedBox(width: 6),
                      _Badge(label: 'MOST', color: AppColors.coralPink),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'OWES',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            result.isFree
                ? '🎂 Free!'
                : '$currencySymbol${result.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: '.SF Pro Rounded',
              fontSize: result.isFree ? 18 : 24,
              fontWeight: FontWeight.w700,
              color: result.isFree
                  ? AppColors.warmAmber
                  : context.colors.textPrimary,
            ),
          ),
        ],
          ),
          // Individual tip control
          if (showTipControl && onTipChanged != null) ...[
            const SizedBox(height: 10),
            _IndividualTipControl(
              currentPct: individualTipPct ?? Decimal.fromInt(18),
              onChanged: onTipChanged!,
            ),
          ],
          // Flex split override control
          if (showFlexControl && onFlexOverrideChanged != null) ...[
            const SizedBox(height: 10),
            _FlexOverrideControl(
              flexOverride: flexOverride,
              currencySymbol: currencySymbol,
              onChanged: onFlexOverrideChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Individual tip inline control ─────────────────────────────────────────

const _kTipPresets = [0, 10, 15, 18, 20];

class _IndividualTipControl extends StatelessWidget {
  const _IndividualTipControl(
      {required this.currentPct, required this.onChanged});
  final Decimal currentPct;
  final ValueChanged<Decimal> onChanged;

  bool get _isCustom => !_kTipPresets
      .any((p) => currentPct == Decimal.fromInt(p));

  Future<void> _openCustomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Decimal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomTipSheet(current: _isCustom ? currentPct : null),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Tip %',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        ..._kTipPresets.map((p) {
          final d = Decimal.fromInt(p);
          final sel = !_isCustom && currentPct == d;
          return GestureDetector(
            onTap: () => onChanged(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primaryViolet
                    : context.colors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$p%',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      sel ? Colors.white : context.colors.textSecondary,
                ),
              ),
            ),
          );
        }),
        // Custom chip
        GestureDetector(
          onTap: () => _openCustomSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isCustom
                  ? AppColors.primaryViolet
                  : context.colors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isCustom
                  ? '${currentPct.toStringAsFixed(0)}%'
                  : '···',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isCustom
                    ? Colors.white
                    : context.colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom tip bottom sheet for individual tip control ────────────────────

class _CustomTipSheet extends StatefulWidget {
  const _CustomTipSheet({this.current});
  final Decimal? current;

  @override
  State<_CustomTipSheet> createState() => _CustomTipSheetState();
}

class _CustomTipSheetState extends State<_CustomTipSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.current != null
          ? widget.current!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final val = _ctrl.text.trim();
    final d = double.tryParse(val);
    if (d == null || d < 0 || d > 100) return;
    Navigator.pop(context, Decimal.parse(d.toStringAsFixed(1)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: context.colors.surface1,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Text(
            'Custom tip %',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter percentage',
              hintStyle:
                  TextStyle(color: context.colors.textTertiary),
              suffixText: '%',
              suffixStyle: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryViolet,
              ),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded,
                          color: context.colors.textSecondary,
                          size: 18),
                      onPressed: () =>
                          setState(() => _ctrl.clear()),
                    )
                  : null,
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
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
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

// ── Badge ─────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Flex override control ─────────────────────────────────────────────────

class _FlexOverrideControl extends StatefulWidget {
  const _FlexOverrideControl({
    required this.flexOverride,
    required this.currencySymbol,
    required this.onChanged,
  });
  final FlexOverride? flexOverride;
  final String currencySymbol;
  final void Function(FlexOverride? override) onChanged;

  @override
  State<_FlexOverrideControl> createState() => _FlexOverrideControlState();
}

class _FlexOverrideControlState extends State<_FlexOverrideControl> {
  final _ctrl = TextEditingController();
  FlexOverrideType _type = FlexOverrideType.amount;
  bool _isEqualMode = true;

  @override
  void initState() {
    super.initState();
    if (widget.flexOverride != null) {
      _type = widget.flexOverride!.type;
      _isEqualMode = false;
      _ctrl.text = widget.flexOverride!.value.toStringAsFixed(
          widget.flexOverride!.type == FlexOverrideType.amount ? 2 : 0);
    }
  }

  @override
  void didUpdateWidget(_FlexOverrideControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flexOverride == null && oldWidget.flexOverride != null) {
      // Override was cleared externally — reset to Equal mode.
      setState(() {
        _isEqualMode = true;
        _ctrl.clear();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit(String val) {
    final d = double.tryParse(val);
    if (d == null || d <= 0) {
      widget.onChanged(null);
      return;
    }
    if (_type == FlexOverrideType.percentage && d > 100) return;
    widget.onChanged(
        FlexOverride(type: _type, value: Decimal.parse(d.toStringAsFixed(2))));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Equal chip (clears override)
        _OverrideChip(
          label: 'Equal',
          selected: _isEqualMode,
          color: AppColors.primaryViolet,
          onTap: () {
            setState(() {
              _isEqualMode = true;
              _ctrl.clear();
            });
            widget.onChanged(null);
          },
        ),
        const SizedBox(width: 6),
        // $ chip
        _OverrideChip(
          label: widget.currencySymbol,
          selected: !_isEqualMode && _type == FlexOverrideType.amount,
          color: AppColors.warmAmber,
          onTap: () => setState(() {
            _isEqualMode = false;
            _type = FlexOverrideType.amount;
          }),
        ),
        const SizedBox(width: 6),
        // % chip
        _OverrideChip(
          label: '%',
          selected: !_isEqualMode && _type == FlexOverrideType.percentage,
          color: AppColors.warmAmber,
          onTap: () => setState(() {
            _isEqualMode = false;
            _type = FlexOverrideType.percentage;
          }),
        ),
        const SizedBox(width: 8),
        // Amount input
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              color: context.colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _type == FlexOverrideType.amount
                  ? 'Amount'
                  : 'Percentage',
              hintStyle: TextStyle(
                  color: context.colors.textTertiary, fontSize: 13),
              prefixText: _type == FlexOverrideType.amount
                  ? widget.currencySymbol
                  : null,
              suffixText:
                  _type == FlexOverrideType.percentage ? '%' : null,
              filled: true,
              fillColor: context.colors.surface2,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: AppColors.warmAmber, width: 1.5),
              ),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        setState(() => _ctrl.clear());
                        widget.onChanged(null);
                      },
                      child: Icon(Icons.clear_rounded,
                          size: 16,
                          color: context.colors.textTertiary),
                    )
                  : null,
            ),
            onChanged: (_) {
              setState(() {});
              _commit(_ctrl.text);
            },
            onSubmitted: _commit,
          ),
        ),
      ],
    );
  }
}

class _OverrideChip extends StatelessWidget {
  const _OverrideChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : context.colors.surface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
