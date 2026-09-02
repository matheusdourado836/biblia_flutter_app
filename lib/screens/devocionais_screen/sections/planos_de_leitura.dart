import 'package:biblia_flutter_app/models/plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/devocionais_tutorial.dart';

class PlanosDeLeitura extends StatefulWidget {
  const PlanosDeLeitura({super.key});

  @override
  State<PlanosDeLeitura> createState() => _PlanosDeLeituraState();
}

class _PlanosDeLeituraState extends State<PlanosDeLeitura> {
  late final List<Plan> _plans;
  late PlansProvider _plansProvider;
  double percentageValue = 0;

  @override
  void initState() {
    _plansProvider = Provider.of<PlansProvider>(context, listen: false);
    getPlans().whenComplete(() => checkStartedPlans());
    super.initState();
  }
  
  Future<void> getPlans() async {
    await _plansProvider.getPlans();
    _plans = _plansProvider.plans;
  }

  Future<List<bool>> checkStartedPlans() async {
    final List<bool> startedPlans = [];
    for(var plan in _plansProvider.plans) {
      final res = await _plansProvider.checkPlanStartedBybType(planType: plan.planType);
      startedPlans.add(res);
    }
    return startedPlans;
  }

  Future<double> calculateReadPercentage(int index) async {
    double percentage = 0;
    final res = await _plansProvider.findReadingPlan(planId: _plans[index].planType.code);
    if(res != null) {
      final totalDays = res.durationDays!;
      final currentDay = res.currentDay!;
      percentage = (currentDay / totalDays) * 100;
    }

    return percentage;
  }

  Widget imageSkeleton() => Shimmer.fromColors(
    baseColor: Colors.grey,
    highlightColor: Colors.white,
    child: Container(
      height: 72,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(50)
      ),
    ),
  );
  
  Widget planBgImage(Plan plan) {
    if(plan.imgPath.startsWith('assets')) {
      return Container(
        height: 72,
        width: 72,
        margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(plan.imgPath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3), BlendMode.darken
              ),
            ),
            borderRadius: BorderRadius.circular(4)
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: plan.imgPath,
      imageBuilder: (context, image) {
        return Container(
          height: 72,
          width: 72,
          margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
          decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3), BlendMode.darken
                ),
              ),
              borderRadius: BorderRadius.circular(4)
          ),
        );
      },
      placeholder: (context, url) {
        return imageSkeleton();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: plansKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 24.0),
            child: Text('Planos de leitura'),
          ),
          Consumer<PlansProvider>(
            builder: (context, value, _) {
              if(value.plans.isEmpty) {
                return imageSkeleton();
              }
              return FutureBuilder(
                  future: checkStartedPlans(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) {
                      return imageSkeleton();
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
                                  arguments: {"plan": _plans[index]}
                                )
                              ),
                              child: Row(
                                children: [
                                  planBgImage(_plans[index]),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_plans[index].label, style: const TextStyle(fontSize: 14)),
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
                                arguments: {"plan": _plans[index]}
                            )),
                            child: Row(
                              children: [
                                planBgImage(_plans[index]),
                                Expanded(
                                  child: Text(_plans[index].label, style: const TextStyle(fontSize: 14)),
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
