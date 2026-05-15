import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/settings_repository.dart';
import '../settings/settings_provider.dart';

part 'onboarding_provider.g.dart';

/// Manages onboarding flow state.
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  OnboardingState build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return OnboardingState(
      isComplete: repo.isOnboardingComplete,
      currentPage: 0,
    );
  }

  /// Advances to the next onboarding page.
  void nextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  /// Navigates to a specific onboarding page.
  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Marks onboarding as complete and persists the flag.
  Future<void> complete() async {
    await _repo.setOnboardingComplete();
    state = state.copyWith(isComplete: true);
  }
}

/// Snapshot of the onboarding flow state.
class OnboardingState {
  const OnboardingState({
    required this.isComplete,
    required this.currentPage,
  });

  /// True if onboarding has been completed at least once.
  final bool isComplete;

  /// Index of the currently visible onboarding page (0-based).
  final int currentPage;

  OnboardingState copyWith({bool? isComplete, int? currentPage}) =>
      OnboardingState(
        isComplete: isComplete ?? this.isComplete,
        currentPage: currentPage ?? this.currentPage,
      );
}
