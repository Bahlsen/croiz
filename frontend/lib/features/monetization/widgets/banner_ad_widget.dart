import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  // Track if we failed to load to avoid infinite retry loops or flickering
  bool _adLoadFailed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _loadAd() {
    // Prevent multiple loads or reloading after failure immediately
    if (_isAdLoaded || _adLoadFailed) {
      return;
    }

    final adService = ref.read(monetizationServiceProvider);

    _bannerAd = adService.createBannerAd(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _isAdLoaded = true;
          _adLoadFailed = false;
        });
      },
      onAdFailedToLoad: (ad, error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isAdLoaded = false;
          _adLoadFailed = true;
        });
        ad.dispose();
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return empty SizedBox if not loaded to hide gracefully
    return const SizedBox.shrink();
  }
}
