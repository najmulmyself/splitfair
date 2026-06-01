import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
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
  });

  final List<SplitResult> results;
  final Decimal grandTotal;
  final Decimal tip;
  final String currencyCode;
  final String currencySymbol;

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
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PersonResultCard(result: r, currencySymbol: currencySymbol)
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
  const _PersonResultCard({required this.result, required this.currencySymbol});
  final SplitResult result;
  final String currencySymbol;

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
      child: Row(
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
