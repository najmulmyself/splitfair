import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_provider.dart';
import 'widgets/ob_splash.dart';
import 'widgets/ob_page_hook.dart';
import 'widgets/ob_page_trust.dart';
import 'widgets/ob_page_ready.dart';

/// Full onboarding flow:
///   1. Animated splash (auto-advances after ~2.4 s)
///   2. Three swipeable onboarding pages (Hook → Trust → Ready)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _showSplash = true;

  // Splash exit animation
  late final AnimationController _splashExitCtrl;
  late final Animation<double> _splashFade;
  late final Animation<double> _splashScale;

  // Content enter animation (reused per page)
  late final AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _splashExitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _splashFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _splashExitCtrl, curve: Curves.easeIn),
    );
    _splashScale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _splashExitCtrl, curve: Curves.easeIn),
    );

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Auto-advance from splash after 2.4 s
    Future.delayed(const Duration(milliseconds: 2400), _exitSplash);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _splashExitCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _exitSplash() async {
    if (!mounted) return;
    await _splashExitCtrl.forward();
    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  Future<void> _nextPage() async {
    if (_currentPage < 2) {
      await _pageCtrl.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingNotifierProvider.notifier).complete();
    if (!mounted) return;
    context.go(AppRoutes.calculator);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── Mesh background ─────────────────────────────────
          const _MeshBackground(),

          // ── Onboarding pages (hidden behind splash initially) ─
          if (!_showSplash) _buildPageFlow(),

          // ── Splash overlay ───────────────────────────────────
          if (_showSplash)
            AnimatedBuilder(
              animation: _splashExitCtrl,
              builder: (context, child) => Opacity(
                opacity: _splashFade.value,
                child: Transform.scale(
                  scale: _splashScale.value,
                  child: child,
                ),
              ),
              child: const ObSplash(),
            ),
        ],
      ),
    );
  }

  Widget _buildPageFlow() {
    return Column(
      children: [
        // ── Top nav ────────────────────────────────────────────
        _TopNav(
          showBack: _currentPage > 0,
          onBack: () => _pageCtrl.animateToPage(
            _currentPage - 1,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
          ),
          onSkip: _finish,
        ).animate().fade(begin: 0, duration: 300.ms, delay: 100.ms),

        // ── Illustration area ───────────────────────────────────
        Expanded(
          flex: 55,
          child: PageView(
            controller: _pageCtrl,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              ObPageHook(isActive: _currentPage == 0),
              ObPageTrust(isActive: _currentPage == 1),
              ObPageReady(isActive: _currentPage == 2),
            ],
          ),
        ),

        // ── Bottom content card ─────────────────────────────────
        _BottomContent(
          page: _currentPage,
          onNext: _nextPage,
        ).animate().fade(begin: 0, duration: 400.ms, delay: 150.ms).slideY(
            begin: 0.12,
            end: 0,
            duration: 400.ms,
            delay: 150.ms,
            curve: Curves.easeOut),
      ],
    );
  }
}

// ── Mesh background ─────────────────────────────────────────────────────────

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.35),
              radius: 1.1,
              colors: [
                Color(0xFF16103A),
                AppColors.bgBase,
              ],
            ),
          ),
        ),
        // Violet blob top-left
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.meshViolet,
            ),
          ),
        ),
        // Coral blob bottom-right
        Positioned(
          bottom: -60,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.meshCoral,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Top navigation bar ───────────────────────────────────────────────────────

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.showBack,
    required this.onBack,
    required this.onSkip,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, top + 8, 12, 0),
      child: Row(
        children: [
          // Back button
          AnimatedOpacity(
            opacity: showBack ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !showBack,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Skip button
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom content (text + dots + CTA) ──────────────────────────────────────

const _pageContent = [
  (
    title: 'Split bills the fair way.',
    subtitle:
        'Not split equally — split for what each person actually ordered.',
  ),
  (
    title: 'No account. No signup. Ever.',
    subtitle:
        'Open the app and split. Your data stays on your phone — not our servers.',
  ),
  (
    title: 'Ready in 30 seconds.',
    subtitle: 'Works offline. Any currency. Any kind of bill.',
  ),
];

class _BottomContent extends StatelessWidget {
  const _BottomContent({required this.page, required this.onNext});

  final int page;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final content = _pageContent[page];
    final isLast = page == 2;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, 16, 28, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Headline ──────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              content.title,
              key: ValueKey('title_$page'),
              style: const TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Subtitle ──────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              content.subtitle,
              key: ValueKey('sub_$page'),
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                height: 1.5,
                color: AppColors.textPrimary.withOpacity(0.55),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Progress dots ─────────────────────────────────────
          Row(
            children: List.generate(
              3,
              (i) => _ProgressDot(active: i == page),
            ),
          ),
          const SizedBox(height: 22),

          // ── CTA button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isLast
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF7C5CFF), Color(0xFF9B7FFF)],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isLast
                        ? const Color(0xFFFF6B9D).withOpacity(0.35)
                        : const Color(0xFF7C5CFF).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    isLast ? 'Start Splitting' : 'Next',
                    key: ValueKey('btn_$isLast'),
                    style: const TextStyle(
                      fontFamily: '.SF Pro Display',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress dot ─────────────────────────────────────────────────────────────

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 6),
      width: active ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryViolet
            : AppColors.textPrimary.withOpacity(0.20),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
