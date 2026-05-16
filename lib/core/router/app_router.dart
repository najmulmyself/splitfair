import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/calculator/calculator_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/share/share_sheet.dart';
import '../../features/currency/currency_selector_sheet.dart';
import '../../features/pro_unlock/pro_unlock_sheet.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/history/history_screen.dart';

part 'app_router.g.dart';

/// Named route paths.
abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const calculator = '/';
  static const share = '/share';
  static const currency = '/currency';
  static const history = '/history';
  static const receiptScanner = '/receipt-scanner';
  static const proUnlock = '/pro-unlock';
  static const settings = '/settings';
}

/// Provides the [GoRouter] instance.
/// The router redirects to onboarding if this is the first launch.
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final onboardingComplete = ref.watch(onboardingNotifierProvider).isComplete;

  return GoRouter(
    initialLocation:
        onboardingComplete ? AppRoutes.calculator : AppRoutes.onboarding,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.calculator,
        name: 'calculator',
        builder: (context, state) => const CalculatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.share,
        name: 'share',
        builder: (context, state) => const ShareSheet(),
      ),
      GoRoute(
        path: AppRoutes.currency,
        name: 'currency',
        builder: (context, state) => const CurrencySelectorSheet(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.receiptScanner,
        name: 'receiptScanner',
        builder: (context, state) => const _PlaceholderScreen(title: 'Scanner'),
      ),
      GoRoute(
        path: AppRoutes.proUnlock,
        name: 'proUnlock',
        builder: (context, state) => const ProUnlockSheet(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Temporary placeholder scaffold used until real screens are implemented.
/// Remove this class when all screens are built.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
