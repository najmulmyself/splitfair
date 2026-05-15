import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

/// Onboarding page 2 — "No account. No signup. Ever."
/// Shows a calculator/numpad mockup with trust badges.
class ObPageTrust extends StatelessWidget {
  const ObPageTrust({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // ── Main numpad card ─────────────────────────────────
          Positioned(
            top: constraints.maxHeight * 0.06,
            child: _NumpadCard(),
          )
              .animate(target: isActive ? 1 : 0)
              .fade(duration: 500.ms, delay: 100.ms)
              .slideY(
                  begin: -0.1,
                  end: 0,
                  duration: 550.ms,
                  delay: 100.ms,
                  curve: Curves.easeOutCubic),

          // ── NO SIGNUP pill (top-right) ───────────────────────
          Positioned(
            top: constraints.maxHeight * 0.02,
            right: 28,
            child: _NoSignupBadge(),
          )
              .animate(target: isActive ? 1 : 0)
              .fade(duration: 350.ms, delay: 550.ms)
              .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 400.ms,
                  delay: 550.ms,
                  curve: Curves.elasticOut),
        ],
      );
    });
  }
}

// ── Numpad card ─────────────────────────────────────────────────────────────

class _NumpadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Display area ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BILL TOTAL',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withOpacity(0.45),
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        fontFamily: '.SF Mono',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                    const Text(
                      '163',
                      style: TextStyle(
                        fontFamily: '.SF Mono',
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    Text(
                      '.40',
                      style: TextStyle(
                        fontFamily: '.SF Mono',
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary.withOpacity(0.55),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Numpad grid ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Column(
              children: [
                _NumRow(keys: const ['1', '2', '3']),
                _NumRow(keys: const ['4', '5', '6']),
                _NumRow(keys: const ['7', '8', '9']),
                _NumRow(keys: const ['.', '0', '⌫']),
              ],
            ),
          ),

          // ── 100% on-device badge ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            child: _OnDeviceBadge(),
          ),
        ],
      ),
    );
  }
}

class _NumRow extends StatelessWidget {
  const _NumRow({required this.keys});
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: keys
            .map(
              (k) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NumKey(label: k),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isBackspace
            ? AppColors.primaryViolet.withOpacity(0.18)
            : AppColors.surface3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBackspace
              ? AppColors.primaryViolet.withOpacity(0.3)
              : AppColors.borderDefault,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: isBackspace ? 16 : 18,
            fontWeight: FontWeight.w500,
            color:
                isBackspace ? AppColors.primaryViolet : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OnDeviceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.emeraldMint.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.emeraldMint.withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.emeraldMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '100% on-device',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.emeraldMint.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSignupBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coralPink.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.coralPink.withOpacity(0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.coralPink,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'NO SIGNUP',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.coralPink,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
