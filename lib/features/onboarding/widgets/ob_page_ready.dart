import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import 'ob_splash.dart';

/// Onboarding page 3 — "Ready in 30 seconds."
/// Shows floating feature icons around the SF logo, plus feature chips.
class ObPageReady extends StatefulWidget {
  const ObPageReady({super.key, required this.isActive});

  final bool isActive;

  @override
  State<ObPageReady> createState() => _ObPageReadyState();
}

class _ObPageReadyState extends State<ObPageReady>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cx = constraints.maxWidth / 2;
      final cy = constraints.maxHeight * 0.42;

      return Stack(
        children: [
          // ── Floating icon: Globe / Currency (top-right) ──────
          Positioned(
            top: cy - 120,
            left: cx + 70,
            child: _FloatingIconBubble(
              icon: Icons.language_rounded,
              color: AppColors.primaryViolet,
              bgColor: const Color(0xFF1A1040),
              ctrl: _floatCtrl,
              phase: 0.0,
            )
                .animate(target: widget.isActive ? 1 : 0)
                .fade(duration: 400.ms, delay: 600.ms)
                .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 500.ms,
                    delay: 600.ms,
                    curve: Curves.elasticOut),
          ),

          // ── Floating icon: Phone / No WiFi (far right) ───────
          Positioned(
            top: cy - 30,
            left: cx + 110,
            child: _FloatingIconBubble(
              icon: Icons.wifi_off_rounded,
              color: AppColors.coralPink,
              bgColor: const Color(0xFF2E1020),
              ctrl: _floatCtrl,
              phase: 0.6,
            )
                .animate(target: widget.isActive ? 1 : 0)
                .fade(duration: 400.ms, delay: 750.ms)
                .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 500.ms,
                    delay: 750.ms,
                    curve: Curves.elasticOut),
          ),

          // ── Floating icon: Mic (bottom-left) ─────────────────
          Positioned(
            top: cy + 70,
            left: cx - 150,
            child: _FloatingIconBubble(
              icon: Icons.mic_rounded,
              color: AppColors.emeraldMint,
              bgColor: const Color(0xFF0E2820),
              ctrl: _floatCtrl,
              phase: 1.2,
            )
                .animate(target: widget.isActive ? 1 : 0)
                .fade(duration: 400.ms, delay: 500.ms)
                .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 500.ms,
                    delay: 500.ms,
                    curve: Curves.elasticOut),
          ),

          // ── Floating icon: Phone (top-left) ──────────────────
          Positioned(
            top: cy - 80,
            left: cx - 155,
            child: _FloatingIconBubble(
              icon: Icons.smartphone_rounded,
              color: AppColors.warmAmber,
              bgColor: const Color(0xFF221810),
              ctrl: _floatCtrl,
              phase: 1.8,
            )
                .animate(target: widget.isActive ? 1 : 0)
                .fade(duration: 400.ms, delay: 680.ms)
                .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 500.ms,
                    delay: 680.ms,
                    curve: Curves.elasticOut),
          ),

          // ── Central SF logo ───────────────────────────────────
          Positioned(
            top: cy - 50,
            left: 0,
            right: 0,
            child: Center(child: ObLogoMark(size: 72)),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 500.ms, delay: 200.ms)
              .scale(
                  begin: const Offset(0.6, 0.6),
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut),

          // ── Feature chips row ─────────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Wrap(
                spacing: 8,
                children: const [
                  _FeatureChip(
                    icon: Icons.language_rounded,
                    label: '30 Currencies',
                    color: AppColors.primaryViolet,
                  ),
                  _FeatureChip(
                    icon: Icons.wifi_off_rounded,
                    label: 'Offline',
                    color: AppColors.emeraldMint,
                  ),
                  _FeatureChip(
                    icon: Icons.shield_rounded,
                    label: 'No Account',
                    color: AppColors.coralPink,
                  ),
                ],
              ),
            ),
          )
              .animate(target: widget.isActive ? 1 : 0)
              .fade(duration: 450.ms, delay: 800.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 450.ms,
                  delay: 800.ms,
                  curve: Curves.easeOut),
        ],
      );
    });
  }
}

// ── Floating icon bubble ──────────────────────────────────────────────────

class _FloatingIconBubble extends StatelessWidget {
  const _FloatingIconBubble({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.ctrl,
    required this.phase,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final AnimationController ctrl;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) {
        final t = (ctrl.value + phase / (2 * math.pi)) % 1.0;
        final dy = math.sin(t * 2 * math.pi) * 7.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.30),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Feature chip ─────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
