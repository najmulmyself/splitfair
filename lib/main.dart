import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'data/models/person.dart';
import 'data/models/split_item.dart';
import 'data/models/split_session.dart';
import 'data/models/split_mode.dart';
import 'features/settings/settings_provider.dart';
import 'shared/widgets/admob/interstitial_ad_service.dart';
import 'app.dart';

/// Entry point. Initialises all services before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Hive ──────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(SplitItemAdapter());
  Hive.registerAdapter(SplitModeAdapter());
  Hive.registerAdapter(SplitSessionAdapter());
  await Hive.openBox<SplitSession>('split_history');

  // ── SharedPreferences ────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();

  // ── Run ──────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SplitFairApp(),
    ),
  );

  // ── AdMob + ATT (after first frame so prompt is visible) ─────
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (Platform.isIOS) {
      // Show ATT prompt — required before AdMob accesses IDFA on iOS 14.5+
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    MobileAds.instance.initialize().then((_) {
      InterstitialAdService.instance.preload();
    });
  });
}
