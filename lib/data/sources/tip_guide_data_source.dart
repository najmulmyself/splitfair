import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../core/constants/app_assets.dart';

/// Represents a country-specific tipping guide entry.
class CountryTipGuide {
  /// Country name.
  final String country;

  /// Country flag emoji.
  final String flag;

  /// Typical tip range as a human-readable string (e.g. '15–20%').
  final String typical;

  /// Optional note about local tipping customs.
  final String? note;

  const CountryTipGuide({
    required this.country,
    required this.flag,
    required this.typical,
    this.note,
  });

  /// Deserialize from JSON.
  factory CountryTipGuide.fromJson(Map<String, dynamic> json) =>
      CountryTipGuide(
        country: json['country'] as String,
        flag: json['flag'] as String,
        typical: json['typical'] as String,
        note: json['note'] as String?,
      );
}

/// Loads country-specific tipping guide data from [AppAssets.countryTipsJson].
class TipGuideDataSource {
  TipGuideDataSource._();

  static final instance = TipGuideDataSource._();

  List<CountryTipGuide>? _cache;

  /// Loads all tipping guides from the bundled JSON asset.
  /// Result is cached after first load.
  Future<List<CountryTipGuide>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(AppAssets.countryTipsJson);
    final list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => CountryTipGuide.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
