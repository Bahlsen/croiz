import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocktail/mocktail.dart';

class MockBannerAd extends Mock implements BannerAd {}

class FakeMonetizationService implements MonetizationService {
  @override
  String get bannerAdUnitId => 'test-banner-id';

  @override
  String get interstitialAdUnitId => 'test-interstitial-id';

  @override
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final ad = MockBannerAd();
    // ignore: unnecessary_lambdas
    when(() => ad.load()).thenAnswer((_) async {});
    // ignore: unnecessary_lambdas
    when(() => ad.dispose()).thenAnswer((_) async {});
    return ad;
  }

  @override
  void showInterstitialAd() {}

  @override
  final ValueNotifier<bool> isAdShowing = ValueNotifier<bool>(false);

  @override
  Future<void> waitForAdDismissed() async {
    // Immediately return in tests since we never actually show ads
  }
}
