/// AdMob ad unit IDs configuration.
/// Toggle between test and production IDs using the PRODUCTION build flag.
abstract class AdConfig {
  // ── Test IDs (use during development ONLY) ──────────────────
  static const testBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const testInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  // ── Production IDs (replace before App Store submission) ────
  static const productionBannerId = 'ca-app-pub-3549493907002564/7116339196';
  static const productionInterstitialId = 'ca-app-pub-3549493907002564/6830084496';

  // ── Active IDs (toggle with build flag) ─────────────────────
  static bool get _isProduction =>
      const bool.fromEnvironment('PRODUCTION');

  /// The active banner ad unit ID.
  static String get bannerId =>
      _isProduction ? productionBannerId : testBannerId;

  /// The active interstitial ad unit ID.
  static String get interstitialId =>
      _isProduction ? productionInterstitialId : testInterstitialId;

  /// Number of sessions before ads start showing.
  static const adFreeSessionThreshold = 3;
}
