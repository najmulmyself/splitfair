import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

/// Animated splash content: interlocking S·F logo + taglines.
/// Parent decides when to show/hide this widget.
class ObSplash extends StatelessWidget {
  const ObSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // ── Interlocking S·F circles ────────────────────────
          _LogoMark()
              .animate()
              .scale(
                begin: const Offset(0.55, 0.55),
                end: const Offset(1, 1),
                duration: 700.ms,
                delay: 200.ms,
                curve: Curves.elasticOut,
              )
              .fade(begin: 0, duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 28),

          // ── DivvyBill ────────────────────────────────────────
          Text(
            'DivvyBill',
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fade(begin: 0, duration: 400.ms, delay: 700.ms).slideY(
              begin: 0.15,
              end: 0,
              duration: 400.ms,
              delay: 700.ms,
              curve: Curves.easeOut),

          const SizedBox(height: 10),

          // ── Tagline ──────────────────────────────────────────
          Text(
            'FAIR  ·  FAST  ·  OFFLINE',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary.withOpacity(0.45),
              letterSpacing: 3.0,
            ),
          ).animate().fade(begin: 0, duration: 350.ms, delay: 950.ms),

          const Spacer(flex: 3),

          // ── Version tag ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: Text(
              'v1.0 — made for the table, not the cloud',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary.withOpacity(0.28),
              ),
            ),
          ).animate().fade(begin: 0, duration: 300.ms, delay: 1200.ms),
        ],
      ),
    );
  }
}

/// The interlocking SF logomark.
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    const overlap = 28.0;
    return SizedBox(
      width: size * 2 - overlap,
      height: size,
      child: Stack(
        children: [
          // S circle (violet)
          Positioned(
            left: 0,
            child: _LogoCircle(
              label: 'D',
              gradient: const LinearGradient(
                colors: [Color(0xFF9B7FFF), Color(0xFF6A3FE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              size: size,
            ),
          ),
          // F circle (coral→amber)
          Positioned(
            right: 0,
            child: _LogoCircle(
              label: 'B',
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

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({
    required this.label,
    required this.gradient,
    required this.size,
  });

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
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Exposes the logo mark so it can be reused on other onboarding pages.
class ObLogoMark extends StatelessWidget {
  const ObLogoMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final overlap = size * 0.29;
    return SizedBox(
      width: size * 2 - overlap,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _LogoCircle(
              label: 'D',
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
            child: _LogoCircle(
              label: 'B',
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
