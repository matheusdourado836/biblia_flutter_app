import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/theme/thematic_skeleton.dart';
import 'package:biblia_flutter_app/helpers/tutorial_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/devocionais_tutorial.dart';

class JornadaEspiritual extends StatefulWidget {
  final ScrollController scrollController;
  const JornadaEspiritual({super.key, required this.scrollController});

  @override
  State<JornadaEspiritual> createState() => _JornadaEspiritualState();
}

class _JornadaEspiritualState extends State<JornadaEspiritual> {
  TutorialCoachMark? _coachMark;
  ThemeProvider? _themeProvider;

  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => devocionalProvider.getThematicDevocionais().whenComplete(() {
      removeTutorialBackground.value = true;
      if (!mounted) return;
      if(devocionalProvider.thematicDevocionais.isNotEmpty && (!devocionalProvider.tutorials.contains('tutorial 2') && (MediaQuery.of(context).orientation == Orientation.portrait || MediaQuery.of(context).size.height > 600))) {
        initTargets();
        _coachMark = TutorialCoachMark(
            onClickTarget: (target) async {
              if(target.identify == 'journey-key') {
                Scrollable.ensureVisible(communityKey.currentContext!, duration: const Duration(milliseconds: 600));
              }else if(target.identify == 'community-key') {
                Scrollable.ensureVisible(plansKey.currentContext!, duration: const Duration(milliseconds: 600));
              }
            },
            onSkip: () {
              devocionalProvider.markTutorial(2);
              return true;
            },
            onFinish: () {
              devocionalProvider.markTutorial(2);
            },
            colorShadow: (_themeProvider!.isOn) ? Colors.black : Theme.of(context).cardTheme.color!,
            targets: devocionaisTargets,
            hideSkip: true
        )..show(context: context);
      }
    }));
    super.initState();
  }

  void initTargets() {
    devocionaisTargets = [
      TargetFocus(
          identify: 'journey-key',
          keyTarget: journeyKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Conheça a seção de palavras temáticas e sempre tenha uma palavra nova para ser edificado nas áreas de sua vida.',
                      skip: 'Pular',
                      next: 'Próximo',
                      onNext: (() async {
                        c.next();
                        await Scrollable.ensureVisible(communityKey.currentContext!, duration: const Duration(milliseconds: 600));
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            )
          ]
      ),
      TargetFocus(
          identify: 'community-key',
          keyTarget: communityKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Venha conhecer nossa comunidade, onde você poderá interagir e postar devocionais para edificar a fé de outras pessoas',
                      skip: 'Pular',
                      next: 'Próximo',
                      onNext: (() {
                        c.next();
                        widget.scrollController.animateTo(
                          widget.scrollController.position.maxScrollExtent,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                        );
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            )
          ]
      ),
      TargetFocus(
          identify: 'plans-key',
          keyTarget: plansKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Inicie um plano de leitura para te ajudar na sua leitura diária, escolha de acordo com seus objetivos',
                      skip: '',
                      next: 'Finalizar',
                      onNext: (() {
                        c.skip();
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            )
          ]
      ),
    ];
  }

  @override
  void dispose() {
    _coachMark?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: journeyKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jornada Espiritual'),
          const SizedBox(height: 20),
          Consumer<DevocionalProvider>(
            builder: (context, value, _) {
              if(value.isLoadingThematic) {
                return const LoadingWidget();
              }
              if(value.thematicDevocionais.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Não foi possível carregar os devocionais temáticos', textAlign: TextAlign.center,),
                    IconButton(onPressed: () => value.getThematicDevocionais(), icon: const Icon(Icons.refresh))
                  ],
                );
              }

              return CarouselSlider(
                options: CarouselOptions(
                  padEnds: false,
                  enableInfiniteScroll: false,
                  aspectRatio: MediaQuery.of(context).size.width > 500 ? 16/4 : 10/4,
                  viewportFraction: .65
                ),
                items: value.thematicDevocionais.map((thematicDevocional) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: (() {
                        Navigator.pushNamed(context, 'thematic_selected', arguments: {"devocional": thematicDevocional});
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: thematicDevocional.bgImagem!,
                              imageBuilder: (context, image) {
                                return Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: image,
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withValues(alpha: 0.25), BlendMode.darken
                                        ),
                                      )
                                  ),
                                );
                              },
                              placeholder: (context, url) {
                                return const ThematicSkeleton();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(thematicDevocional.titulo!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
