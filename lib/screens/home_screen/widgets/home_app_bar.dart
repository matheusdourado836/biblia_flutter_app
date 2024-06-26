import 'dart:math';
import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../data/theme_provider.dart';
import '../../../helpers/alert_dialog.dart';
import '../../../helpers/tutorial_widget.dart';
import '../../../models/book.dart';
import '../../../services/bible_service.dart';

TutorialCoachMark? _coachMark;
List<TargetFocus> _targets = [];

final GlobalKey _randomVerseKey = GlobalKey();
final GlobalKey _searchBookKey = GlobalKey();

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Book> books;
  const HomeAppBar({super.key, required this.books});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  ThemeProvider? _themeProvider;
  final TextEditingController _controller = TextEditingController();
  InterstitialAd? _interstitialAd;
  final start = ValueNotifier(false);
  late final ChaptersProvider provider;

  @override
  void initState() {
    provider = Provider.of<ChaptersProvider>(context, listen: false);
    _createInterstitialAd();
    Future.delayed(const Duration(seconds: 1), () {
      showTutorial();
    });
    super.initState();
  }

  void showTutorial() {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    initTargets();
    _coachMark = TutorialCoachMark(
        colorShadow: (_themeProvider!.isOn) ? Colors.black : Theme.of(context).cardTheme.color!,
        targets: _targets,
        hideSkip: true
    )..show(context: context);
  }

  void initTargets() {
    _targets = [
      TargetFocus(
          identify: 'search-book-key',
          keyTarget: _searchBookKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Clique aqui para pesquisar pelo livro desejado de forma rápida ',
                      skip: 'Pular',
                      next: 'Próximo',
                      onNext: (() {
                        c.next();
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            ),
          ]
      ),
      TargetFocus(
          identify: 'random-verse-key',
          keyTarget: _randomVerseKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Experimente clicar aqui para receber um versículo aleatório para ler ou '
                          'compartilhar nas redes sociais',
                      skip: 'Fechar',
                      next: 'Próximo',
                      onNext: (() {
                        c.skip();
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            ),
          ]
      ),
    ];
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

  void toggleSearch() {
    start.value = !start.value;
    if(!start.value) {
      provider.toggleSearch(false);
      _controller.text = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    _coachMark?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    return AppBar(
      titleSpacing: 0,
      centerTitle: true,
      title: ValueListenableBuilder(
          valueListenable: start,
          builder: (context, value, _) {
            if(value) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Digite o livro aqui...'
                      ),
                      onChanged: (value) {
                        if(start.value && _controller.text.isNotEmpty) {
                          provider.toggleSearch(true);
                        }
                        provider.updateSearch(widget.books, value.trim());
                      },
                    ),
                  ).animate().fade(),
                  IconButton(onPressed: (() => toggleSearch()), icon: const Icon(Icons.close)),
                ],
              );
            }

            return const Text('BibleWise').animate().fade();
          }),
      actions: [
        ValueListenableBuilder(
            valueListenable: start,
            builder: (context, value, _) {
              return IconButton(key: _searchBookKey, onPressed: (() => toggleSearch()), icon: const Icon(Icons.search))
                  .animate(target: (start.value) ? 1 : 0)
                  .fade(begin: 1, end: 0);
            }
        ),
        IconButton(
          key: _randomVerseKey,
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