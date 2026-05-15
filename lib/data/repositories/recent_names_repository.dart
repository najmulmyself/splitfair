import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Persists the last 20 unique names used in splits.
/// Used to power autocomplete in the Add Person sheet.
class RecentNamesRepository {
  const RecentNamesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'recent_names';
  static const _maxNames = 20;

  /// Returns the list of recent names, most recently used first.
  List<String> getAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    return List<String>.from(json.decode(raw) as List);
  }

  /// Records a name as recently used, placing it at the front.
  /// Deduplicates and enforces the [_maxNames] limit.
  Future<void> add(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final names = getAll()..remove(trimmed);
    names.insert(0, trimmed);
    if (names.length > _maxNames) {
      names.removeRange(_maxNames, names.length);
    }
    await _prefs.setString(_key, json.encode(names));
  }

  /// Clears all saved names.
  Future<void> clear() => _prefs.remove(_key);
}
