import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// Provider for the MonetizationService.
/// Using a simple provider as we want this service to be a singleton that persists.
final monetizationServiceProvider = Provider<MonetizationService>(
  (ref) => MonetizationService(),
);

class MonetizationService {
  MonetizationService() {
    _initGoogleMobileAds();
  }

  final Logger _logger = Logger();

  // Test Ad Unit IDs provided by Google
  final String _androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  final String _iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  final String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  final String _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  // Track if showInterstitialAd() was called while ad was loading
  bool _pendingShowRequest = false;

  Future<void> _initGoogleMobileAds() async {
    try {
      if (kIsWeb) {
        return;
      } // Ads not supported on web in this implementation
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
    } on Object catch (e) {
      _logger.e('Error initializing Google Mobile Ads', error: e);
    }
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerId;
    } else if (Platform.isIOS) {
      return _iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialId;
    } else if (Platform.isIOS) {
      return _iosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  void _loadInterstitialAd() {
    if (kIsWeb) {
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _logger.i('Interstitial ad loaded.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _logger.i('Interstitial ad dismissed.');
              ad.dispose();
              _pendingShowRequest = false;
              _loadInterstitialAd(); // Load the next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _logger.e('Interstitial ad failed to show: $error');
              ad.dispose();
              _pendingShowRequest = false;
              _loadInterstitialAd();
            },
          );

          // If there was a pending show request, show the ad immediately
          if (_pendingShowRequest) {
            _logger.i('Showing pending interstitial ad...');
            _pendingShowRequest = false;
            showInterstitialAd();
          }
        },
        onAdFailedToLoad: (error) {
          _logger.w('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          _pendingShowRequest = false;
          // Retry logic could go here, but for now we rely on the next attempt or simple reload
        },
      ),
    );
  }

  /// Shows the interstitial ad if it's ready.
  /// If the ad is still loading, marks it to be shown automatically when ready.
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _logger.i('Showing interstitial ad...');
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      _pendingShowRequest = false;
    } else {
      _logger.w(
        'Interstitial ad not ready (ready: $_isInterstitialAdReady, ad: ${_interstitialAd != null}), will show when loaded...',
      );
      // Mark that we want to show the ad as soon as it's ready
      _pendingShowRequest = true;
      // Try to load one if it was null
      if (_interstitialAd == null && !kIsWeb) {
        _loadInterstitialAd();
      }
    }
  }

  /// Helper to create detailed Banner Ad
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) => BannerAd(
    adUnitId: bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad,
    ),
  );
}
