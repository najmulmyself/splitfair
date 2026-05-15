import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/currency.dart';
import '../../core/constants/app_assets.dart';

/// Loads and parses currency data from [AppAssets.currenciesJson].
class CurrencyDataSource {
  CurrencyDataSource._();

  static final instance = CurrencyDataSource._();

  List<Currency>? _cache;

  /// Loads all currencies from the bundled JSON asset.
  /// Result is cached after first load.
  Future<List<Currency>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(AppAssets.currenciesJson);
    final list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => Currency.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// Returns a currency by its ISO code, or null if not found.
  Future<Currency?> findByCode(String code) async {
    final all = await loadAll();
    try {
      return all.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
