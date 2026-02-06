import 'dart:async';
import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocktail/mocktail.dart';

class MockBannerAd extends Mock implements BannerAd {}

class FakeMonetizationService implements MonetizationService {
  bool autoDismiss = true;

  @override
  String get bannerAdUnitId => 'test-banner-id';

  @override
  String get interstitialAdUnitId => 'test-interstitial-id';

  @override
  String get rewardedAdUnitId => 'test-rewarded-id';

  @override
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final ad = MockBannerAd();
    when(() => ad.size).thenReturn(AdSize.banner);

    // ignore: unnecessary_lambdas
    when(() => ad.load()).thenAnswer((_) async {
      onAdLoaded(ad);
    });
    // ignore: unnecessary_lambdas
    when(() => ad.dispose()).thenAnswer((_) async {});
    return ad;
  }

  @override
  Future<void> showInterstitialAd() async {}

  Completer<void>? _adCompleter;

  void simulateAdDismissal() {
    _adCompleter?.complete();
    _adCompleter = null;
    isAdShowing.value = false;
  }

  @override
  Future<bool> showRewardedAd() async {
    isAdShowing.value = true;
    _adCompleter = Completer<void>();
    if (autoDismiss) {
      simulateAdDismissal();
    }
    await _adCompleter!.future;
    return true;
  }

  @override
  Future<void> incrementPuzzleLoadCount() async {}

  @override
  bool get shouldShowInterstitial => false;

  @override
  final ValueNotifier<bool> isAdShowing = ValueNotifier<bool>(false);

  @override
  Future<void> waitForAdDismissed() => Future.value();
}
