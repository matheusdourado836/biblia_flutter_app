import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8180030689126961/3284191155';
    }else {
      return 'ca-app-pub-8180030689126961/2494838145';
    }
  }

  static String? get interstitialAdId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-8180030689126961/1302430618';
    }else {
      return 'ca-app-pub-8180030689126961/1263331730';
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print('AD LOADED'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      print('DEU RUIM CARREGAR O AD $error ${ad.adUnitId}');
    },
    onAdOpened: (ad) => print('ABRIU HEIN')
  );
}