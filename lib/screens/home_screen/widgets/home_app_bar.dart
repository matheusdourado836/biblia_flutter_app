import 'dart:math';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../../helpers/alert_dialog.dart';
import '../../../services/bible_service.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    _createInterstitialAd();
    super.initState();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      )
    );
  }

  void _showInterstitialAd() {
    if(_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
          Navigator.pushNamed(context, 'random_verse_screen');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
          Navigator.pushNamed(context, 'random_verse_screen');
        }
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  bool showAd() {
    Random random = Random();

    int randomInt = random.nextInt(2);

    bool randomBool = randomInt == 1;

    return randomBool;
  }

  @override
  Widget build(BuildContext context) {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    return AppBar(
      centerTitle: true,
      title: const Text('BibleWise'),
      actions: [
        IconButton(
          onPressed: () {
            versesProvider.clear();
            BibleService().checkInternetConnectivity().then((value) => {
                  if (value) {
                    if(showAd()) {
                      _showInterstitialAd()
                    }else {
                      Navigator.pushNamed(context, 'random_verse_screen')
                    }
                  }
                  else {
                      alertDialog(content: 'Você precisa estar conectado a internet para receber um versiculo aleatório')
                  }
                });
          },
          tooltip: 'Versículo Aleatório',
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
    );
  }
}