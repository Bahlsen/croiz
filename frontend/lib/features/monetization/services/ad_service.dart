import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

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

  final String _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  final String _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  final String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  final String _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  // Track if showInterstitialAd() was called while ad was loading
  bool _pendingShowRequest = false;
  bool _pendingShowRewardedRequest = false;

  // Track puzzles loaded for interstitial trigger
  static const String _puzzlesLoadedKey = 'puzzles_loaded_count';
  int _puzzlesLoadedCount = 0;

  /// Notifies listeners when a fullscreen ad is showing.
  /// true = ad is showing, false = no ad showing
  final ValueNotifier<bool> isAdShowing = ValueNotifier<bool>(false);

  /// Completer that resolves when the current ad is dismissed.
  /// Returns null if no ad is showing.
  Completer<void>? _adDismissedCompleter;

  /// Returns a future that completes when the current fullscreen ad is dismissed.
  /// If no ad is showing, returns immediately.
  Future<void> waitForAdDismissed() async {
    if (!isAdShowing.value && _adDismissedCompleter == null) {
      return;
    }
    // Wait for the ad to be dismissed
    await _adDismissedCompleter?.future;
  }

  Future<void> _initGoogleMobileAds() async {
    try {
      if (kIsWeb) {
        return;
      } // Ads not supported on web in this implementation
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
      _loadRewardedAd();

      final prefs = await SharedPreferences.getInstance();
      _puzzlesLoadedCount = prefs.getInt(_puzzlesLoadedKey) ?? 0;
    } on Object catch (e) {
      _logger.e('Error initializing Google Mobile Ads', error: e);
    }
  }

  /// Increments the puzzle loaded count and persists it.
  Future<void> incrementPuzzleLoadCount() async {
    _puzzlesLoadedCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_puzzlesLoadedKey, _puzzlesLoadedCount);
  }

  /// Returns true if an interstitial ad should be shown based on load count.
  /// Logic: After loading 3 puzzles (1, 2, 3), the 4th (count=4) triggers ad.
  bool get shouldShowInterstitial =>
      _puzzlesLoadedCount > 0 && _puzzlesLoadedCount % 4 == 0;

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

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _androidRewardedId;
    } else if (Platform.isIOS) {
      return _iosRewardedId;
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
            onAdShowedFullScreenContent: (ad) {
              _logger.i('Interstitial ad showing.');
              isAdShowing.value = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _logger.i('Interstitial ad dismissed.');
              isAdShowing.value = false;
              _adDismissedCompleter?.complete();
              _adDismissedCompleter = null;
              ad.dispose();
              _pendingShowRequest = false;
              _loadInterstitialAd(); // Load the next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _logger.e('Interstitial ad failed to show: $error');
              isAdShowing.value = false;
              _adDismissedCompleter?.complete();
              _adDismissedCompleter = null;
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

  void _loadRewardedAd() {
    if (kIsWeb) {
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _logger.i('Rewarded ad loaded.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _logger.i('Rewarded ad showing.');
              isAdShowing.value = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _logger.i('Rewarded ad dismissed.');
              isAdShowing.value = false;
              _adDismissedCompleter?.complete();
              _adDismissedCompleter = null;
              ad.dispose();
              _pendingShowRewardedRequest = false;
              _loadRewardedAd(); // Load the next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _logger.e('Rewarded ad failed to show: $error');
              isAdShowing.value = false;
              _adDismissedCompleter?.complete();
              _adDismissedCompleter = null;
              ad.dispose();
              _pendingShowRewardedRequest = false;
              _loadRewardedAd();
            },
          );

          if (_pendingShowRewardedRequest) {
            _logger.i('Showing pending rewarded ad...');
            // NOTE: We cannot easily await the result here as this is a void callback.
            // So for now we just show it.
            // Ideally the UI would retry or wait for readiness.
            showRewardedAd();
          }
        },
        onAdFailedToLoad: (error) {
          _logger.w('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
          _pendingShowRewardedRequest = false;
        },
      ),
    );
  }

  /// Shows the interstitial ad if it's ready.
  /// If the ad is still loading, marks it to be shown automatically when ready.
  Future<void> showInterstitialAd() async {
    if (isAdShowing.value) {
      _logger.w('An ad is already showing, ignoring request.');
      return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _logger.i('Showing interstitial ad...');
      _adDismissedCompleter = Completer<void>();
      await _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      _pendingShowRequest = false;
      await _adDismissedCompleter?.future;
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

  /// Shows the rewarded ad if it's ready.
  /// Returns check if reward was granted.
  Future<bool> showRewardedAd() async {
    if (isAdShowing.value) {
      _logger.w('An ad is already showing, ignoring request.');
      return false;
    }

    if (_isRewardedAdReady && _rewardedAd != null) {
      _logger.i('Showing rewarded ad...');
      var rewardEarned = false;
      _adDismissedCompleter = Completer<void>();
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          _logger.i('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _isRewardedAdReady = false;
      _rewardedAd = null;
      _pendingShowRewardedRequest = false;
      await _adDismissedCompleter?.future;
      return rewardEarned;
    } else {
      _logger.w(
        'Rewarded ad not ready (ready: $_isRewardedAdReady, ad: ${_rewardedAd != null})',
      );
      // Mark pending request
      _pendingShowRewardedRequest = true;
      // Try to load one if it was null
      if (_rewardedAd == null && !kIsWeb) {
        _loadRewardedAd();
      }
      return false;
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
