// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: false,
  retry: null,
);

typedef SharedPreferencesRef = Ref;

/// Copied from [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: false,
  retry: null,
);

typedef SettingsRepositoryRef = Ref;

/// Copied from [recentNamesRepository].
@ProviderFor(recentNamesRepository)
final recentNamesRepositoryProvider = Provider<RecentNamesRepository>.internal(
  recentNamesRepository,
  name: r'recentNamesRepositoryProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: false,
  retry: null,
);

typedef RecentNamesRepositoryRef = Ref;

/// Copied from [SettingsNotifier].
@ProviderFor(SettingsNotifier)
final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>.internal(
  SettingsNotifier.new,
  name: r'settingsNotifierProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: true,
  retry: null,
);

typedef _$SettingsNotifier = Notifier<SettingsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
