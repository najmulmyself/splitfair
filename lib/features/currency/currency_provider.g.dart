// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Copied from [allCurrencies].
@ProviderFor(allCurrencies)
final allCurrenciesProvider = FutureProvider<List<Currency>>.internal(
  allCurrencies,
  name: r'allCurrenciesProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: true,
  retry: null,
);

typedef AllCurrenciesRef = Ref;

/// Copied from [recentCurrencyCodes].
@ProviderFor(recentCurrencyCodes)
final recentCurrencyCodesProvider = Provider<List<String>>.internal(
  recentCurrencyCodes,
  name: r'recentCurrencyCodesProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: true,
  retry: null,
);

typedef RecentCurrencyCodesRef = Ref;

/// Copied from [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    NotifierProvider<CurrencyNotifier, String>.internal(
  CurrencyNotifier.new,
  name: r'currencyNotifierProvider',
  dependencies: null,
  $allTransitiveDependencies: null,
  from: null,
  argument: null,
  isAutoDispose: true,
  retry: null,
);

typedef _$CurrencyNotifier = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
