import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import '../../../core/theme/app_colors.dart';

/// Displays an AdMob adaptive banner ad.
///
/// Visibility rules:
/// - Only shown when [isVisible] is true (caller controls this).
/// - Caller must enforce session-count threshold before passing isVisible=true.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.isVisible = true});

  /// Controls whether the banner is rendered.
  final bool isVisible;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _loadAd();
  }

  @override
  void didUpdateWidget(BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible && _ad == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    if (!mounted) return;
    _ad = BannerAd(
      adUnitId: AdConfig.bannerId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _ad = null;
        },
      ),
    );
    await _ad!.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || !_isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }
    return Container(
      color: AppColors.adBackground,
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
