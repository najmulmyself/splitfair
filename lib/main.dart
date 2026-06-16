import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
      child: const DivvyBillApp(),
    ),
  );

  // ── AdMob ────────────────────────────────────────────────────
  // ATT is requested from the first screen's initState so the modal
  // fires only after the root view controller is fully visible (required
  // on iPadOS 26+). Initialise AdMob here without waiting for ATT —
  // the SDK handles the IDFA internally after consent is granted.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MobileAds.instance.initialize().then((_) {
      InterstitialAdService.instance.preload();
    });
  });
}
