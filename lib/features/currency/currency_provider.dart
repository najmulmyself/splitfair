import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/currency.dart';
import '../../data/sources/currency_data_source.dart';
import '../../data/repositories/settings_repository.dart';
import '../settings/settings_provider.dart';

part 'currency_provider.g.dart';

/// Provides the full list of available currencies from the JSON asset.
@riverpod
Future<List<Currency>> allCurrencies(AllCurrenciesRef ref) =>
    CurrencyDataSource.instance.loadAll();

/// Manages the currently selected currency.
@riverpod
class CurrencyNotifier extends _$CurrencyNotifier {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  String build() {
    return ref.watch(settingsRepositoryProvider).defaultCurrency;
  }

  /// Selects a currency and persists it as the default.
  Future<void> select(String currencyCode) async {
    await _repo.setDefaultCurrency(currencyCode);
    // Add to recents
    final recents = _repo.recentCurrencies;
    final updated = [currencyCode, ...recents.where((c) => c != currencyCode)]
        .take(3)
        .toList();
    await _repo.saveRecentCurrencies(updated);
    state = currencyCode;
  }
}

/// Provides the list of recently used currency codes (max 3).
@riverpod
List<String> recentCurrencyCodes(RecentCurrencyCodesRef ref) {
  return ref.watch(settingsRepositoryProvider).recentCurrencies;
}
