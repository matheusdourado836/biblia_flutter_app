import 'dart:io';

import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:biblia_flutter_app/helpers/tutorial_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../data/devocional_provider.dart';
import '../../data/plans_provider.dart';
import '../../models/devocional.dart';
import 'community/feed_screen.dart';

TutorialCoachMark? _coachMark;
List<TargetFocus> _targets = [];
ValueNotifier<bool> _removeBackground = ValueNotifier(false);

final GlobalKey _journeyKey = GlobalKey();
final GlobalKey _communityKey = GlobalKey();
final GlobalKey _plansKey = GlobalKey();

class DevocionaisScreen extends StatefulWidget {
  const DevocionaisScreen({super.key});

  @override
  State<DevocionaisScreen> createState() => _DevocionaisScreenState();
}

class _DevocionaisScreenState extends State<DevocionaisScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Devocionais'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JornadaEspiritual(scrollController: _scrollController,),
                const Comunidade(),
                const PlanosDeLeitura()
              ],
            ),
          ),
          ValueListenableBuilder(valueListenable: _removeBackground, builder: (context, value, _) {
            if(!value) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              );
            }else {
              return const SizedBox();
            }
          })
        ],
      ),
    );
  }
}

class JornadaEspiritual extends StatefulWidget {
  final ScrollController scrollController;
  const JornadaEspiritual({super.key, required this.scrollController});

  @override
  State<JornadaEspiritual> createState() => _JornadaEspiritualState();
}

class _JornadaEspiritualState extends State<JornadaEspiritual> {
  ThemeProvider? _themeProvider;

  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    devocionalProvider.getThematicDevocionais().whenComplete(() {
      _removeBackground.value = true;
      if(!devocionalProvider.tutorials.contains('tutorial 2') && (MediaQuery.of(context).orientation == Orientation.portrait || MediaQuery.of(context).size.height > 600)) {
        initTargets();
        _coachMark = TutorialCoachMark(
          onClickTarget: (target) async {
            if(target.identify == 'journey-key') {
              Scrollable.ensureVisible(_communityKey.currentContext!, duration: const Duration(milliseconds: 600));
            }else if(target.identify == 'community-key') {
              Scrollable.ensureVisible(_plansKey.currentContext!, duration: const Duration(milliseconds: 600));
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
            targets: _targets,
            hideSkip: true
        )..show(context: context);
      }
    });
    super.initState();
  }

  void initTargets() {
    _targets = [
      TargetFocus(
          identify: 'journey-key',
          keyTarget: _journeyKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Descubra novos devocionais temáticos e tenha uma reflexão para fortalecer sua fé',
                      skip: 'Pular',
                      next: 'Próximo',
                      onNext: (() async {
                        c.next();
                        await Scrollable.ensureVisible(_communityKey.currentContext!, duration: const Duration(milliseconds: 600));
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            )
          ]
      ),
      TargetFocus(
          identify: 'community-key',
          keyTarget: _communityKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Venha conhecer nossa comunidade, onde você poderá ver, postar devocionais e suas reflexões pessoais para abençoar e edificar a fé de outras pessoas',
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
          keyTarget: _plansKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.top,
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
    final height = MediaQuery.of(context).size.longestSide;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: _journeyKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jornada Espiritual'),
          const SizedBox(height: 20),
          Consumer<DevocionalProvider>(
            builder: (context, value, _) {
              if(value.thematicDevocionais.isEmpty) {
                return const LoadingWidget();
              }

              return CarouselSlider(
                options: CarouselOptions(
                  padEnds: false,
                  enableInfiniteScroll: false,
                  aspectRatio: (height <= 800) ? 10/4 : Platform.isAndroid ? 16/4 : 12/4,
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
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(thematicDevocional.bgImagem!),
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.25), BlendMode.darken
                                  ),
                                )
                              ),
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

class Comunidade extends StatefulWidget {
  const Comunidade({super.key});

  @override
  State<Comunidade> createState() => _ComunidadeState();
}

class _ComunidadeState extends State<Comunidade> {
  late Widget imageProvider;
  List<Devocional> _devocionais = [];

  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => devocionalProvider.getDevocionais().whenComplete(() => _devocionais = devocionalProvider.devocionais));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _communityKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40.0, bottom: 24.0, left: 16.0),
          child: Text('Faça parte da nossa comunidade'),
        ),
        Container(
          height: 350,
          color: Theme.of(context).cardTheme.color,
          child: Column(
            children: [
              Expanded(
                child: Consumer<DevocionalProvider>(
                  builder: (context, value, _) {
                    if(value.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: PostFeedSkeleton(),
                      );
                    }

                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        enlargeFactor: .5
                      ),
                      items: _devocionais.map((devocional) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  (devocional.bgImagemUser != null && devocional.bgImagemUser!.isNotEmpty)
                                      ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                              devocional.bgImagemUser!,
                                            )
                                        )
                                    ),
                                  )
                                      : const NoBgUser(),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(devocional.nomeAutor!, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white
                                  ),
                                  child: Text(devocional.plainText!, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black),)
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: (() => Navigator.pushNamed(context, 'feed_screen')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ), child: const Text('Explorar'),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class PlanosDeLeitura extends StatefulWidget {
  const PlanosDeLeitura({super.key});

  @override
  State<PlanosDeLeitura> createState() => _PlanosDeLeituraState();
}

class _PlanosDeLeituraState extends State<PlanosDeLeitura> {
  // TODO TEM QUE COLOCAR ISSO NO BANCO DE DADOS ANTES DE LANÇAR A ATUALIZAÇÃO
  static final List<Map<String, dynamic>> _plans = [
    {"label": "Bíblia em 1 ano", "imgPath": "assets/images/one_year_plan.png", "code": PlanType.ONE_YEAR, "duration": 397, "qtdChapters": 3},
    {"label": "Bíblia toda em 3 meses", "imgPath": "assets/images/three_month_plan.jpg","code": PlanType.THREE_MONTHS, "duration": 92, "qtdChapters": 13},
    {"label": "Novo testamento em 2 meses","imgPath": "assets/images/two_month_new_plan.jpg", "code": PlanType.TWO_MONTHS_NEW, "duration": 66, "qtdChapters": 4, "isNewTestament": true},
    {"label": "Antigo testamento em 6 meses","imgPath": "assets/images/six_month_old_plan.png", "code": PlanType.SIX_MONTHS_OLD, "duration": 186, "qtdChapters": 5, "bibleLength": 39}
  ];
  late PlansProvider _plansProvider;
  double percentageValue = 0;

  @override
  void initState() {
    _plansProvider = Provider.of<PlansProvider>(context, listen: false);
    checkStartedPlans();
    super.initState();
  }

  Future<List<bool>> checkStartedPlans() async {
    final List<bool> startedPlans = [];
    for(var plan in _plans) {
      final res = await _plansProvider.checkPlanStartedBybType(planType: plan["code"]);
      startedPlans.add(res);
    }
    return startedPlans;
  }

  Future<double> calculateReadPercentage(int index) async {
    double percentage = 0;
    final res = await _plansProvider.findReadingPlan(planId: _plans[index]["code"].code);
    if(res != null) {
      final totalDays = res.durationDays!;
      final currentDay = res.currentDay!;
      percentage = (currentDay / totalDays) * 100;
    }

    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: _plansKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 24.0),
            child: Text('Planos de leitura'),
          ),
          Consumer<PlansProvider>(
            builder: (context, value, _) {
              return FutureBuilder(
                  future: checkStartedPlans(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidget();
                    }else {
                      return ListView.builder(
                        itemCount: _plans.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if(snapshot.data![index]) {
                            return InkWell(
                              onTap: (() => Navigator.pushNamed(
                                  context,
                                  'plans_base',
                                  arguments: {
                                    "planType": _plans[index]["code"],
                                    "label": _plans[index]["label"],
                                    "qtdChapters": _plans[index]["qtdChapters"],
                                    "duration": _plans[index]["duration"],
                                    "bibleLength": _plans[index]["bibleLength"],
                                    "isNewTestament": _plans[index]["isNewTestament"],
                                  }
                                )
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 72,
                                    width: 72,
                                    margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(_plans[index]["imgPath"]),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.3), BlendMode.darken
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(4)
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_plans[index]["label"], style: const TextStyle(fontSize: 14)),
                                        const SizedBox(height: 8),
                                        FutureBuilder(
                                            future: calculateReadPercentage(index),
                                            builder: (context, snapshot) {
                                              if(snapshot.connectionState == ConnectionState.waiting) {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey,
                                                  highlightColor: Colors.white,
                                                  child: Container(
                                                    height: 10,
                                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius: BorderRadius.circular(50)
                                                    ),
                                                  ),
                                                );
                                              }else {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('${snapshot.data!.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 10)),
                                                    const SizedBox(height: 8),
                                                    ConstrainedBox(
                                                      constraints: const BoxConstraints(
                                                        maxWidth: 250,
                                                      ),
                                                      child: LinearProgressIndicator(
                                                        value: snapshot.data! / 100,
                                                        minHeight: 8,
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }
                                            }
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return InkWell(
                            onTap: (() => Navigator.pushNamed(
                                context,
                                'plans_base',
                                arguments: {
                                  "planType": _plans[index]["code"],
                                  "label": _plans[index]["label"],
                                  "qtdChapters": _plans[index]["qtdChapters"],
                                  "duration": _plans[index]["duration"],
                                  "bibleLength": _plans[index]["bibleLength"],
                                  "isNewTestament": _plans[index]["isNewTestament"],
                                }
                            )),
                            child: Row(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(_plans[index]["imgPath"]),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.3), BlendMode.darken
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                ),
                                Expanded(
                                  child: Text(_plans[index]["label"], style: const TextStyle(fontSize: 14)),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
              );
            },
          ),
        ],
      ),
    );
  }
}

