import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/calculator_provider.dart';

/// The top "BILL TOTAL" card showing the entered amount, tax controls,
/// and currency badge.
class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.billBuffer,
    required this.taxBuffer,
    required this.isEditingBill,
    required this.isEditingTax,
    required this.taxMode,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyFlag,
    required this.onTap,
    required this.onTaxTap,
    required this.onCurrencyTap,
    required this.onTaxModeChanged,
  });

  final String billBuffer;
  final String taxBuffer;
  final bool isEditingBill;
  final bool isEditingTax;
  final TaxInputMode taxMode;
  final String currencyCode;
  final String currencySymbol;
  final String currencyFlag;
  final VoidCallback onTap;
  final VoidCallback onTaxTap;
  final VoidCallback onCurrencyTap;
  final ValueChanged<TaxInputMode> onTaxModeChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        decoration: BoxDecoration(
          color: context.colors.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEditingBill
                ? AppColors.primaryViolet.withOpacity(0.6)
                : context.colors.borderDefault,
            width: isEditingBill ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isEditingBill
                  ? AppColors.primaryViolet.withOpacity(0.15)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────
            Row(
              children: [
                Text(
                  'BILL TOTAL',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                _CurrencyBadge(
                  flag: currencyFlag,
                  code: currencyCode,
                  onTap: onCurrencyTap,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Amount display ───────────────────────────────
            _BillAmountDisplay(
              buffer: billBuffer,
              isEditing: isEditingBill,
              currencySymbol: currencySymbol,
            ),

            const SizedBox(height: 12),

            // ── Tax row ──────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: onTaxTap,
                  child: Text(
                    '+ TAX',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _TaxModeToggle(
                  mode: taxMode,
                  onChanged: onTaxModeChanged,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTaxTap,
                  child: Text(
                    _taxDisplay,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: taxBuffer.isNotEmpty && taxBuffer != '0'
                          ? context.colors.textPrimary
                          : context.colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _taxDisplay {
    if (taxBuffer.isEmpty || taxBuffer == '0') {
      return taxMode == TaxInputMode.percent ? '0%' : '${currencySymbol}0';
    }
    if (taxMode == TaxInputMode.percent) {
      return '$taxBuffer%';
    } else {
      return '$currencySymbol$taxBuffer';
    }
  }
}

// ── Amount display ────────────────────────────────────────────────────────

class _BillAmountDisplay extends StatefulWidget {
  const _BillAmountDisplay({
    required this.buffer,
    required this.isEditing,
    required this.currencySymbol,
  });
  final String buffer;
  final bool isEditing;
  final String currencySymbol;

  @override
  State<_BillAmountDisplay> createState() => _BillAmountDisplayState();
}

class _BillAmountDisplayState extends State<_BillAmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorCtrl;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (intPart, decPart, hasTypedDec) = _parse(widget.buffer);
    final isEmpty = widget.buffer.isEmpty;

    // Scale font size down as integer digits grow to prevent card overflow.
    final intDigits = intPart == '0' ? 1 : intPart.length;
    final double intFontSize = switch (intDigits) {
      <= 3 => 62.0,
      4 => 54.0,
      5 => 46.0,
      _ => 38.0,
    };
    final double decFontSize = (intFontSize * 0.58).ceilToDouble();
    final double symFontSize = (intFontSize * 0.46).ceilToDouble();

    final bigStyle = TextStyle(
      fontFamily: '.SF Pro Rounded',
      fontSize: intFontSize,
      fontWeight: FontWeight.w800,
      height: 1.0,
      color: context.colors.textPrimary,
    );
    final symbolStyle = TextStyle(
      fontFamily: '.SF Pro Rounded',
      fontSize: symFontSize,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: context.colors.textPrimary,
    );
    final decStyle = TextStyle(
      fontFamily: '.SF Pro Rounded',
      fontSize: decFontSize,
      fontWeight: FontWeight.w700,
      height: 1.0,
      color: context.colors.textPrimary,
    );
    final dimDecStyle = decStyle.copyWith(
      color: context.colors.textPrimary.withOpacity(0.25),
    );
    final emptyStyle = bigStyle.copyWith(
      color: context.colors.textPrimary.withOpacity(0.18),
    );

    // Cursor widget — reused in two positions.
    Widget cursorWidget() => AnimatedBuilder(
          animation: _cursorCtrl,
          builder: (_, __) => Opacity(
            opacity: _cursorCtrl.value > 0.5 ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 1),
              child: Text('|',
                  style: decStyle.copyWith(color: AppColors.primaryViolet)),
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Currency symbol
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(widget.currencySymbol,
              style: isEmpty
                  ? symbolStyle.copyWith(
                      color: context.colors.textPrimary.withOpacity(0.18))
                  : symbolStyle),
        ),
        const SizedBox(width: 2),

        // Integer part
        Text(intPart, style: isEmpty ? emptyStyle : bigStyle),

        // Cursor sits HERE when no decimal typed (next key → integer)
        if (widget.isEditing && !hasTypedDec) cursorWidget(),

        // Decimal part
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: hasTypedDec
              ? Text(
                  '.${decPart.padRight(2, '0').substring(0, 2)}',
                  style: decStyle,
                )
              : Text('.00',
                  style: isEmpty
                      ? dimDecStyle.copyWith(
                          color: context.colors.textPrimary.withOpacity(0.18))
                      : dimDecStyle),
        ),

        // Cursor sits HERE when decimal is being typed (next key → cents)
        if (widget.isEditing && hasTypedDec) cursorWidget(),
      ],
    );
  }

  static (String intPart, String decPart, bool hasTypedDec) _parse(
      String buffer) {
    if (buffer.isEmpty) return ('0', '00', false);
    if (!buffer.contains('.')) return (buffer, '00', false);
    final parts = buffer.split('.');
    return (parts[0].isEmpty ? '0' : parts[0], parts[1], true);
  }
}

// ── Tax mode toggle ───────────────────────────────────────────────────────

class _TaxModeToggle extends StatelessWidget {
  const _TaxModeToggle({required this.mode, required this.onChanged});
  final TaxInputMode mode;
  final ValueChanged<TaxInputMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: '%',
            active: mode == TaxInputMode.percent,
            onTap: () => onChanged(TaxInputMode.percent),
          ),
          _Pill(
            label: '\$',
            active: mode == TaxInputMode.dollar,
            onTap: () => onChanged(TaxInputMode.dollar),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryViolet : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Currency badge ────────────────────────────────────────────────────────

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({
    required this.flag,
    required this.code,
    required this.onTap,
  });
  final String flag;
  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: context.colors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.colors.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              code,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
