// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allCurrenciesHash() => r'c06761ff959a61205a01b24ca1460ee8fb43d534';

/// Provides the full list of available currencies from the JSON asset.
///
/// Copied from [allCurrencies].
@ProviderFor(allCurrencies)
final allCurrenciesProvider =
    AutoDisposeFutureProvider<List<Currency>>.internal(
  allCurrencies,
  name: r'allCurrenciesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCurrenciesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllCurrenciesRef = AutoDisposeFutureProviderRef<List<Currency>>;
String _$recentCurrencyCodesHash() =>
    r'f7c41ef69d9e87b330195967a0fa4312ac78db2c';

/// Provides the list of recently used currency codes (max 3).
///
/// Copied from [recentCurrencyCodes].
@ProviderFor(recentCurrencyCodes)
final recentCurrencyCodesProvider = AutoDisposeProvider<List<String>>.internal(
  recentCurrencyCodes,
  name: r'recentCurrencyCodesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentCurrencyCodesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentCurrencyCodesRef = AutoDisposeProviderRef<List<String>>;
String _$currencyNotifierHash() => r'7b34226d1a47e7616f696ba1fc024689f7c342e1';

/// Manages the currently selected currency.
///
/// Copied from [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    AutoDisposeNotifierProvider<CurrencyNotifier, String>.internal(
  CurrencyNotifier.new,
  name: r'currencyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrencyNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
