// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'3ac0a5e7baf05283ee34f00385692ae1c33755b8';

/// Provides the [SharedPreferences] instance.
/// Must be overridden in [ProviderScope] after async initialization in main.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$settingsRepositoryHash() =>
    r'f1c415fc7b7b99b8a9badc17e065ac74312b3378';

/// Provides the [SettingsRepository].
///
/// Copied from [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsRepositoryRef = ProviderRef<SettingsRepository>;
String _$recentNamesRepositoryHash() =>
    r'd1c8e6f2b82df136eb23b0c1ea0eeb252913f72b';

/// Provides the [RecentNamesRepository].
///
/// Copied from [recentNamesRepository].
@ProviderFor(recentNamesRepository)
final recentNamesRepositoryProvider = Provider<RecentNamesRepository>.internal(
  recentNamesRepository,
  name: r'recentNamesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentNamesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentNamesRepositoryRef = ProviderRef<RecentNamesRepository>;
String _$settingsNotifierHash() => r'7e37321fe2cc6f2165cc35a575dd2af98e54a3f7';

/// Manages app settings state.
///
/// Copied from [SettingsNotifier].
@ProviderFor(SettingsNotifier)
final settingsNotifierProvider =
    AutoDisposeNotifierProvider<SettingsNotifier, SettingsState>.internal(
  SettingsNotifier.new,
  name: r'settingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsNotifier = AutoDisposeNotifier<SettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
