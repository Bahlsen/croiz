import 'dart:io';

import 'package:croiz/features/monetization/providers/subscription_provider.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:flutter/foundation.dart';
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
    _checkAndLoadAd();
  }

  void _checkAndLoadAd() {
    // If premium, don't load
    final isPremium = ref.read(subscriptionProvider).value ?? false;
    if (isPremium) {
      return;
    }

    _loadAd();
  }

  void _loadAd() {
    // Prevent multiple loads or reloading after failure immediately
    if (_isAdLoaded || _adLoadFailed || _bannerAd != null) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    try {
      final adService = ref.read(monetizationServiceProvider);

      // Ensure we are on a supported platform before trying to create ad
      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint('BannerAdWidget: Platform not supported for ads');
        _adLoadFailed = true;
        return;
      }

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
          debugPrint('BannerAdWidget: Failed to load ad: $error');
          setState(() {
            _isAdLoaded = false;
            _adLoadFailed = true;
          });
          ad.dispose();
          _bannerAd = null;
        },
      )..load();
    } on Object catch (e) {
      debugPrint('BannerAdWidget: Error creating ad: $e');
      if (mounted) {
        setState(() {
          _adLoadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumAsync = ref.watch(subscriptionProvider);
    final isPremium = isPremiumAsync.value ?? false;

    // If User is Premium, hide ads logic
    if (isPremium) {
      if (_bannerAd != null) {
        _bannerAd?.dispose();
        _bannerAd = null;
        _isAdLoaded = false;
      }
      return const SizedBox.shrink();
    }

    // Attempt load if not loaded and not failed
    if (!_isAdLoaded && !_adLoadFailed && _bannerAd == null) {
      _loadAd();
    }

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
