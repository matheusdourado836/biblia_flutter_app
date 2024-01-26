import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8180030689126961/4121824206';
    }else {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static String? get interstitialAdId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8180030689126961/9341048219';
    }else {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print('AD LOADED'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      print('DEU RUIM CARREGAR O AD $error');
    },
    onAdOpened: (ad) => print('ABRIU HEIN')
  );
}