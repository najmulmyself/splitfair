import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const _kPresets = [10, 15, 18, 20, 25];

/// Tip percentage preset chips + "calculate on subtotal / total" toggle.
class TipSection extends StatelessWidget {
  const TipSection({
    super.key,
    required this.selectedTip,
    required this.tipOnSubtotal,
    required this.onTipSelected,
    required this.onToggleTipBase,
    required this.onMoreTap,
  });

  final Decimal selectedTip;
  final bool tipOnSubtotal;
  final ValueChanged<Decimal> onTipSelected;
  final ValueChanged<bool> onToggleTipBase;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ─────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'TIP',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // ── Preset chips ─────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ..._kPresets.map((pct) {
              final d = Decimal.fromInt(pct);
              final isSelected = selectedTip == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _TipChip(
                    label: '$pct%',
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
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'CALCULATE TIP ON',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _TipBaseToggle(
          onSubtotal: tipOnSubtotal,
          onChanged: onToggleTipBase,
        ),
      ],
    );
  }
}

// ── Tip chip ──────────────────────────────────────────────────────────────

class _TipChip extends StatelessWidget {
  const _TipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryViolet : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryViolet : AppColors.borderDefault,
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
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
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: const Text(
          '···',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
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
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
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
          color: active ? AppColors.surface3 : Colors.transparent,
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
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
