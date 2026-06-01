import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] for all app settings persistence.
/// All keys are defined as constants to prevent typos.
class SettingsRepository {
  const SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  // ── Keys ──────────────────────────────────────────────────────
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyDefaultTipPercentage = 'default_tip_percentage';
  static const _keyDefaultCurrency = 'default_currency';
  static const _keyTipOnSubtotal = 'tip_on_subtotal';
  static const _keyRememberNames = 'remember_names';
  static const _keyRecentNames = 'recent_names';
  static const _keyRecentCurrencies = 'recent_currencies';
  static const _keySessionCount = 'session_count';
  static const _keyIsPro = 'is_pro';
  static const _keyThemeMode = 'theme_mode';

  // ── Onboarding ───────────────────────────────────────────────
  bool get isOnboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_keyOnboardingComplete, true);

  // ── Default tip ──────────────────────────────────────────────
  String get defaultTipPercentage =>
      _prefs.getString(_keyDefaultTipPercentage) ?? '18';

  Future<void> setDefaultTipPercentage(String value) =>
      _prefs.setString(_keyDefaultTipPercentage, value);

  // ── Default currency ─────────────────────────────────────────
  String get defaultCurrency =>
      _prefs.getString(_keyDefaultCurrency) ?? 'USD';

  Future<void> setDefaultCurrency(String code) =>
      _prefs.setString(_keyDefaultCurrency, code);

  // ── Tip calculation preference ───────────────────────────────
  bool get tipOnSubtotal => _prefs.getBool(_keyTipOnSubtotal) ?? true;

  Future<void> setTipOnSubtotal(bool value) =>
      _prefs.setBool(_keyTipOnSubtotal, value);

  // ── Remember names ───────────────────────────────────────────
  bool get rememberNames => _prefs.getBool(_keyRememberNames) ?? true;

  Future<void> setRememberNames(bool value) =>
      _prefs.setBool(_keyRememberNames, value);

  // ── Recent names ─────────────────────────────────────────────
  List<String> get recentNames {
    final raw = _prefs.getString(_keyRecentNames);
    if (raw == null) return [];
    return List<String>.from(json.decode(raw) as List);
  }

  Future<void> saveRecentNames(List<String> names) =>
      _prefs.setString(_keyRecentNames, json.encode(names));

  Future<void> clearRecentNames() => _prefs.remove(_keyRecentNames);

  // ── Recent currencies ────────────────────────────────────────
  List<String> get recentCurrencies {
    final raw = _prefs.getString(_keyRecentCurrencies);
    if (raw == null) return [];
    return List<String>.from(json.decode(raw) as List);
  }

  Future<void> saveRecentCurrencies(List<String> codes) =>
      _prefs.setString(_keyRecentCurrencies, json.encode(codes));

  // ── Session count (for ad frequency gating) ──────────────────
  int get sessionCount => _prefs.getInt(_keySessionCount) ?? 0;

  Future<void> incrementSessionCount() =>
      _prefs.setInt(_keySessionCount, sessionCount + 1);

  // ── Pro status ───────────────────────────────────────────────
  bool get isPro => _prefs.getBool(_keyIsPro) ?? false;

  Future<void> setIsPro(bool value) => _prefs.setBool(_keyIsPro, value);

  // ── Theme mode ───────────────────────────────────────────────
  /// Returns 'dark', 'light', or 'system'.
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  // ── Draft session ─────────────────────────────────────────────
  static const _keyDraft = 'calculator_draft';

  String? get draft => _prefs.getString(_keyDraft);

  Future<void> saveDraft(String json) => _prefs.setString(_keyDraft, json);

  Future<void> clearDraft() => _prefs.remove(_keyDraft);
}
