import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

/// Singleton service that manages interstitial ad preloading and display.
///
/// Preloads the next ad immediately after showing one to minimise wait time.
/// Enforces a maximum of one interstitial per session and respects the
/// session-count threshold defined in [AdConfig].
class InterstitialAdService {
  InterstitialAdService._();

  static final instance = InterstitialAdService._();

  InterstitialAd? _ad;
  bool _isLoaded = false;
  bool _shownThisSession = false;

  /// Preloads an interstitial ad in the background.
  /// Call this on app startup and after each display.
  Future<void> preload() async {
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _isLoaded = false;
              preload(); // Preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              _isLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoaded = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if all conditions are met.
  ///
  /// Will not show if:
  /// - Already shown this session
  /// - User is Pro (caller must check [isPro] before calling)
  /// - Ad is not loaded
  Future<void> show() async {
    if (_shownThisSession || !_isLoaded || _ad == null) return;
    _shownThisSession = true;
    await _ad!.show();
  }

  /// Resets the session flag. Call this when starting a new split session.
  void resetSession() => _shownThisSession = false;

  /// Whether an ad has already been shown this session.
  bool get shownThisSession => _shownThisSession;
}
