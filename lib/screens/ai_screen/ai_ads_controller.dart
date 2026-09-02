import 'dart:math';

import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Concentra o ciclo de vida dos anúncios da tela de IA (intersticial de
/// entrada e premiado que libera perguntas extras), que antes ficava
/// misturado com a UI em `ai_screen.dart`.
class AiAdsController {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  final Random _random;

  AiAdsController({Random? random}) : _random = random ?? Random();

  bool get hasRewardedAd => _rewardedAd != null;

  /// Exibe o intersticial em ~1 de cada 3 aberturas da tela.
  bool get shouldShowInterstitial => _random.nextInt(3) == 1;

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdMobService.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdFailedToShowFullScreenContent: (ad, err) => ad.dispose(),
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
          );
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) => _rewardedAd = null,
      ),
    );
  }

  void showRewardedAd(void Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward) {
    _rewardedAd?.show(onUserEarnedReward: onUserEarnedReward);
  }

  void loadAndShowInterstitial() {
    InterstitialAd.load(
      adUnitId: AdMobService.aiInterstitialAdId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _showInterstitial();
        },
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitial() {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    ad.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
