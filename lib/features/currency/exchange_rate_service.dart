import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches and caches USD-base exchange rates from open.er-api.com (free, no key).
/// Falls back to cached data when offline. Refreshes when cache is > 24 h old.
class ExchangeRateService {
  ExchangeRateService._();
  static final instance = ExchangeRateService._();

  static const _cacheKey = 'exchange_rates_json';
  static const _tsKey = 'exchange_rates_ts';
  static const _ttl = Duration(hours: 24);
  static const _baseUrl = 'https://open.er-api.com/v6/latest/USD';

  Map<String, double>? _cache;

  /// Returns rates as {currencyCode: rateVsUsd}.
  /// Returns null if no network and no cached data.
  Future<Map<String, double>?> getRates() async {
    if (_cache != null) return _cache;
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_tsKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age < _ttl.inMilliseconds) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        _cache = _parse(raw);
        return _cache;
      }
    }
    return _fetch(prefs);
  }

  Future<Map<String, double>?> _fetch(SharedPreferences prefs) async {
    try {
      final response =
          await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = response.body;
        _cache = _parse(body);
        await prefs.setString(_cacheKey, body);
        await prefs.setInt(
            _tsKey, DateTime.now().millisecondsSinceEpoch);
        return _cache;
      }
    } catch (_) {
      // Network error — try stale cache
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        _cache = _parse(raw);
        return _cache;
      }
    }
    return null;
  }

  Map<String, double> _parse(String raw) {
    final obj = json.decode(raw) as Map<String, dynamic>;
    final rates = obj['rates'] as Map<String, dynamic>? ?? {};
    return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  /// Invalidate in-memory cache (call after forced refresh).
  void invalidate() => _cache = null;
}
