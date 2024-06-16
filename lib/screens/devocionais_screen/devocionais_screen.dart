import 'dart:math';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/tutorial_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../data/devocional_provider.dart';
import '../../data/plans_provider.dart';
import 'community/feed_screen.dart';

TutorialCoachMark? _coachMark;
List<TargetFocus> _targets = [];

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
  ThemeProvider? _themeProvider;

  @override
  void initState() {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Future.delayed(const Duration(seconds: 1), () {
      showTutorial();
    });
    super.initState();
  }

  void showTutorial() {
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
                onNext: (() {
                  c.next();
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
              align: ContentAlign.top,
              builder: (context, c) {
                return TutorialWidget(
                    text: 'Venha conhecer nossa comunidade, onde você poderá ver, postar devocionais e suas reflexões pessoais para abençoar e edificar a fé de outras pessoas',
                    skip: 'Pular',
                    next: 'Próximo',
                    onNext: (() {
                      c.next();
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
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
                    skip: 'Pular',
                    next: 'Próximo',
                    onNext: (() {
                      c.next();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Devocionais'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JornadaEspiritual(),
            Comunidade(),
            PlanosDeLeitura()
          ],
        ),
      ),
    );
  }
}

class JornadaEspiritual extends StatefulWidget {
  const JornadaEspiritual({super.key});

  @override
  State<JornadaEspiritual> createState() => _JornadaEspiritualState();
}

class _JornadaEspiritualState extends State<JornadaEspiritual> {
  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    devocionalProvider.getThematicDevocionais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: _journeyKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jornada Espiritual'),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Consumer<DevocionalProvider>(
              builder: (context, value, _) {
                if(value.thematicDevocionais.isEmpty) {
                  return const LoadingWidget();
                }

                return CarouselSlider(
                  options: CarouselOptions(
                    height: 120,
                    padEnds: false,
                    enableInfiniteScroll: false,
                    aspectRatio: 16/9,
                    viewportFraction: .58
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
                            Container(
                              height: 80,
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
                            const SizedBox(height: 8),
                            Text(thematicDevocional.titulo!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
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

  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    devocionalProvider.getDevocionais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40.0, bottom: 24.0, left: 16.0),
          child: Text('Faça parte da nossa comunidade'),
        ),
        Container(
          key: _communityKey,
          height: 300,
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
                        height: 300,
                        autoPlay: true,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        enlargeFactor: .5
                      ),
                      items: value.devocionais.map((devocional) {
                        return Container(
                          padding: const EdgeInsets.all(12),
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
                                  const SizedBox(width: 15),
                                  Text(devocional.nomeAutor!)
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white
                                  ),
                                  child: Text(devocional.texto!, maxLines: 5, style: const TextStyle(color: Colors.black),)
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
  static final List<Map<String, dynamic>> _plans = [
    {"label": "Bíblia em 1 ano", "route": "one_year", "code": PlanType.ONE_YEAR},
    {"label": "Bíblia toda em 3 meses", "route": "three_months", "code": PlanType.THREE_MONTHS},
    {"label": "Novo testamento em 2 meses", "route": "one_year", "code": PlanType.SIX_MONTHS},
    {"label": "Mais um que não sei", "route": "one_year", "code": PlanType.ONE_YEAR}
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
                              onTap: (() => Navigator.pushNamed(context, _plans[index]["route"], arguments: {"code": _plans[index]["code"]})),
                              child: Row(
                                children: [
                                  Container(
                                    height: 72,
                                    width: 72,
                                    margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                                        borderRadius: BorderRadius.circular(4)
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_plans[index]["label"]),
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
                                                    LinearProgressIndicator(
                                                      value: snapshot.data! / 100,
                                                      minHeight: 8,
                                                      borderRadius: BorderRadius.circular(2),
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
                            onTap: (() => Navigator.pushNamed(context, _plans[index]["route"], arguments: {"code": _plans[index]["code"]})),
                            child: Row(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                ),
                                Expanded(
                                  child: Text(_plans[index]["label"]),
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

