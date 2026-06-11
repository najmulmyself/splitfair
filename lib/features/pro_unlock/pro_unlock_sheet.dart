import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptics.dart';
import 'iap_provider.dart';

/// Full-screen Pro unlock paywall.
class ProUnlockSheet extends ConsumerWidget {
  const ProUnlockSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapState = ref.watch(iapNotifierProvider);
    final notifier = ref.read(iapNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgBase,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ──────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              child: Column(
                children: [
                  // Hero icon
                  _HeroIcon().animate().fade(duration: 400.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Go Ad-Free with DivvyBill Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                      height: 1.2,
                    ),
                  ).animate().fade(duration: 350.ms, delay: 80.ms),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'One purchase. No subscription. Yours forever.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fade(duration: 350.ms, delay: 120.ms),

                  const SizedBox(height: 32),

                  // Feature bullets
                  _FeatureRow(
                    icon: Icons.block_rounded,
                    iconColor: AppColors.coralPink,
                    text: 'Remove all banner & interstitial ads',
                    delay: 160.ms,
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: AppColors.primaryViolet,
                    text: 'Export any split as a PDF',
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.emeraldMint,
                    text: 'Support independent development',
                    delay: 240.ms,
                  ),

                  const SizedBox(height: 36),

                  // Price
                  _PriceBlock().animate().fade(duration: 350.ms, delay: 280.ms),

                  const SizedBox(height: 28),

                  // Unlock button
                  _UnlockButton(
                    isLoading: iapState.isPurchasing,
                    onTap: iapState.isPurchasing
                        ? null
                        : () {
                            Haptics.heavyImpact();
                            notifier.purchasePro();
                          },
                  ).animate().fade(duration: 350.ms, delay: 320.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      delay: 320.ms,
                      curve: Curves.easeOut),

                  const SizedBox(height: 18),

                  // Restore
                  GestureDetector(
                    onTap: iapState.isPurchasing
                        ? null
                        : () {
                            Haptics.selection();
                            notifier.restore();
                          },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 14,
                          color: context.colors.textTertiary,
                        ),
                        children: [
                          const TextSpan(text: 'Already purchased? '),
                          TextSpan(
                            text: 'Restore',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 350.ms, delay: 360.ms),

                  // Error message
                  if (iapState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      iapState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Close button (last = on top) ──────────────────
            Positioned(
              top: 8,
              right: 12,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surface2,
                    border: Border.all(color: context.colors.borderDefault),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: context.colors.textSecondary, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero icon ─────────────────────────────────────────────────────────────

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B2A8E), Color(0xFF5C3DC8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryViolet.withOpacity(0.45),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
        ),
        // Star icon
        const Icon(Icons.workspace_premium_rounded,
            color: Colors.white, size: 52),
        // Badge (bottom-right)
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
              ),
            ),
            child: const Center(
              child: Text('✦',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feature row ───────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.delay,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.12),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fade(duration: 300.ms, delay: delay)
        .slideX(begin: -0.05, end: 0, duration: 350.ms, delay: delay);
  }
}

// ── Price block ───────────────────────────────────────────────────────────

class _PriceBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
            children: [
              const TextSpan(text: '\$2.99'),
              TextSpan(
                text: ' once',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: context.colors.textSecondary,
                ),
              ),
              TextSpan(
                text: ' — yours forever',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'vs. \$4.99/month elsewhere',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 13,
            color: context.colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ── Unlock button ─────────────────────────────────────────────────────────

class _UnlockButton extends StatelessWidget {
  const _UnlockButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
                )
              : null,
          color: onTap == null ? context.colors.surface2 : null,
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Unlock DivvyBill Pro — \$2.99',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
