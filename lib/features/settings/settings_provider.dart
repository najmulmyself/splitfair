import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/recent_names_repository.dart';

part 'settings_provider.g.dart';

/// Provides the [SharedPreferences] instance.
/// Must be overridden in [ProviderScope] after async initialization in main.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope',
  );
}

/// Provides the [SettingsRepository].
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
}

/// Provides the [RecentNamesRepository].
@Riverpod(keepAlive: true)
RecentNamesRepository recentNamesRepository(RecentNamesRepositoryRef ref) {
  return RecentNamesRepository(ref.watch(sharedPreferencesProvider));
}

/// Manages app settings state.
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  SettingsState build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return SettingsState(
      defaultTipPercentage: repo.defaultTipPercentage,
      defaultCurrency: repo.defaultCurrency,
      tipOnSubtotal: repo.tipOnSubtotal,
      rememberNames: repo.rememberNames,
      themeMode: repo.themeMode,
      isPro: repo.isPro,
    );
  }

  /// Sets the default tip percentage and persists it.
  Future<void> setDefaultTipPercentage(String value) async {
    await _repo.setDefaultTipPercentage(value);
    state = state.copyWith(defaultTipPercentage: value);
  }

  /// Sets the default currency and persists it.
  Future<void> setDefaultCurrency(String code) async {
    await _repo.setDefaultCurrency(code);
    state = state.copyWith(defaultCurrency: code);
  }

  /// Toggles tip calculation base.
  Future<void> setTipOnSubtotal(bool value) async {
    await _repo.setTipOnSubtotal(value);
    state = state.copyWith(tipOnSubtotal: value);
  }

  /// Toggles the remember names feature.
  Future<void> setRememberNames(bool value) async {
    await _repo.setRememberNames(value);
    state = state.copyWith(rememberNames: value);
  }

  /// Sets the UI theme mode ('dark', 'light', or 'system').
  Future<void> setThemeMode(String mode) async {
    await _repo.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  /// Marks the user as Pro (called after successful IAP).
  Future<void> setIsPro(bool value) async {
    await _repo.setIsPro(value);
    state = state.copyWith(isPro: value);
  }
}

/// Snapshot of app settings.
class SettingsState {
  const SettingsState({
    required this.defaultTipPercentage,
    required this.defaultCurrency,
    required this.tipOnSubtotal,
    required this.rememberNames,
    required this.themeMode,
    required this.isPro,
  });

  final String defaultTipPercentage;
  final String defaultCurrency;
  final bool tipOnSubtotal;
  final bool rememberNames;
  final String themeMode;
  final bool isPro;

  SettingsState copyWith({
    String? defaultTipPercentage,
    String? defaultCurrency,
    bool? tipOnSubtotal,
    bool? rememberNames,
    String? themeMode,
    bool? isPro,
  }) => SettingsState(
    defaultTipPercentage: defaultTipPercentage ?? this.defaultTipPercentage,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    tipOnSubtotal: tipOnSubtotal ?? this.tipOnSubtotal,
    rememberNames: rememberNames ?? this.rememberNames,
    themeMode: themeMode ?? this.themeMode,
    isPro: isPro ?? this.isPro,
  );
}
