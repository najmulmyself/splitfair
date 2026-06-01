import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/split_result.dart';

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
  });

  final List<SplitResult> results;
  final Decimal grandTotal;
  final Decimal tip;
  final String currencyCode;
  final String currencySymbol;
  final bool useIndividualTips;
  final Map<String, int> perPersonTipBps;
  final void Function(String personId, Decimal pct)? onPersonTipChanged;

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
  });
  final SplitResult result;
  final String currencySymbol;
  final bool showTipControl;
  final Decimal? individualTipPct;
  final ValueChanged<Decimal>? onTipChanged;

  @override
  Widget build(BuildContext context) {
    final gradients = AppColors.personGradients;
    final gradient = gradients[result.person.colorIndex % gradients.length];
    final isLowest = result.isLowest;
    final isHighest = result.isHighest;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color? cardBg;
    Color amountColor = context.colors.textPrimary;
    if (isLowest) {
      cardBg = isDark ? const Color(0xFF0D2820) : const Color(0xFFE6FBF5);
    }
    if (isHighest) {
      cardBg = isDark ? const Color(0xFF2A0F18) : const Color(0xFFFFEDF3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg ?? context.colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowest
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
            '$currencySymbol${result.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: '.SF Pro Rounded',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
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
                  : 'Custom',
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
