import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const _kPresets = [10, 15, 18, 20, 25];
const _kLabels = ['Poor', 'Fair', 'Good', 'Great', 'Best'];

/// Tip percentage preset chips + "calculate on subtotal / total" toggle
/// + country tipping guide link.
class TipSection extends StatelessWidget {
  const TipSection({
    super.key,
    required this.selectedTip,
    required this.tipOnSubtotal,
    required this.onTipSelected,
    required this.onToggleTipBase,
    required this.onMoreTap,
    this.onGuideTap,
    this.hasTax = false,
    this.tipSavings,
  });

  final Decimal selectedTip;
  final bool tipOnSubtotal;
  final ValueChanged<Decimal> onTipSelected;
  final ValueChanged<bool> onToggleTipBase;
  final VoidCallback onMoreTap;
  final VoidCallback? onGuideTap;
  /// True when user has entered a tax amount.
  final bool hasTax;
  /// Dollar difference between tipping on total vs subtotal. Non-null when hasTax.
  final Decimal? tipSavings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'TIP',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Preset chips ─────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ..._kPresets.asMap().entries.map((e) {
              final i = e.key;
              final pct = e.value;
              final d = Decimal.fromInt(pct);
              final isSelected = selectedTip == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _TipChip(
                    label: '$pct%',
                    sublabel: _kLabels[i],
                    selected: isSelected,
                    onTap: () => onTipSelected(d),
                  ),
                ),
              );
            }),
            _MoreButton(onTap: onMoreTap),
          ],
        ),

        const SizedBox(height: 12),

        // ── Calculate tip on ──────────────────────────────────
        Row(
          children: [
            Text(
              'CALCULATE TIP ON',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.colors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            if (onGuideTap != null)
              GestureDetector(
                onTap: onGuideTap,
                child: Text(
                  '🌍 Tip guide',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryViolet,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _TipBaseToggle(
          onSubtotal: tipOnSubtotal,
          onChanged: onToggleTipBase,
        ),

        // Context line below toggle
        const SizedBox(height: 6),
        if (!hasTax)
          Text(
            'Add tax above to see the savings difference.',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              color: context.colors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          )
        else if (tipSavings != null && tipSavings! > Decimal.zero) ...[
          Row(
            children: [
              Icon(
                tipOnSubtotal
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                size: 13,
                color: tipOnSubtotal
                    ? AppColors.emeraldMint
                    : context.colors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                tipOnSubtotal
                    ? 'Saving \$${tipSavings!.toStringAsFixed(2)} by not tipping on tax'
                    : 'Tipping on tax costs \$${tipSavings!.toStringAsFixed(2)} extra',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 11,
                  color: tipOnSubtotal
                      ? AppColors.emeraldMint
                      : context.colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Tip chip ──────────────────────────────────────────────────────────────

class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryViolet : context.colors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryViolet
                : context.colors.borderDefault,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryViolet.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: selected
                    ? Colors.white.withOpacity(0.75)
                    : context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── More button ───────────────────────────────────────────────────────────

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.borderDefault),
        ),
        child: Text(
          '···',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Subtotal / Total segmented toggle ────────────────────────────────────

class _TipBaseToggle extends StatelessWidget {
  const _TipBaseToggle({required this.onSubtotal, required this.onChanged});
  final bool onSubtotal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Subtotal',
              active: onSubtotal,
              isLeft: true,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Total',
              active: !onSubtotal,
              isLeft: false,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: active ? context.colors.surface3 : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? context.colors.textPrimary
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
