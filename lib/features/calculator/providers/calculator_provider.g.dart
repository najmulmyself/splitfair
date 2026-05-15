// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calculatorNotifierHash() =>
    r'50dba03210588898a2ddc0005749ae24ed670db7';

/// Manages the full calculator state and exposes computed results.
///
/// Copied from [CalculatorNotifier].
@ProviderFor(CalculatorNotifier)
final calculatorNotifierProvider =
    AutoDisposeNotifierProvider<CalculatorNotifier, CalculatorState>.internal(
  CalculatorNotifier.new,
  name: r'calculatorNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calculatorNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalculatorNotifier = AutoDisposeNotifier<CalculatorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
