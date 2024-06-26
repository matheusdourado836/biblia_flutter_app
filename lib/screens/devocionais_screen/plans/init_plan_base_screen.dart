import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/init_plan_widget.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/format_date.dart';
import '../widgets/cancel_plan_dialog.dart';

late PlansProvider _plansProvider;

class InitPlanBaseScreen extends StatefulWidget {
  final PlanType planType;
  final String label;
  final int qtdChapters;
  final int duration;
  final int? bibleLength;
  final bool? isNewTestament;
  final bool? openedFromNotification;
  const InitPlanBaseScreen({super.key, required this.planType, required this.qtdChapters, this.openedFromNotification, required this.duration, this.bibleLength, required this.label, this.isNewTestament});

  @override
  State<InitPlanBaseScreen> createState() => _InitPlanBaseScreenState();
}

class _InitPlanBaseScreenState extends State<InitPlanBaseScreen> {
  @override
  void initState() {
    _plansProvider = Provider.of<PlansProvider>(context, listen: false);
    _plansProvider.checkIfPlanStarted(planType: widget.planType);
    _plansProvider.checkPlanNotificationStatus(planType: widget.planType);
    checkNotificationPermission();
    super.initState();
  }

  void checkNotificationPermission() async {
    var notification = Permission.notification;
    var status = await notification.isDenied;
    if (status) {
      notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<PlansProvider>(
          builder: (context, value, _) {
            if(value.loading) {
              return const LoadingWidget();
            }

            if(value.currentPlan != null) {
              return _DaysList(planType: widget.planType, qtdChapters: widget.qtdChapters, duration: widget.duration, bibleLength: widget.bibleLength, isNewTestament: widget.isNewTestament,);
            }

            return InitPlanWidget(
                planType: widget.planType,
                onPressed: () => value.startReadingPlan(planId: widget.planType, durationDays: widget.duration, bibleLength: widget.bibleLength, isNewTestament: widget.isNewTestament)
            );
          }
      ),
    );
  }
}

class _DaysList extends StatefulWidget {
  final PlanType planType;
  final int qtdChapters;
  final int duration;
  final int? bibleLength;
  final bool? isNewTestament;
  const _DaysList({required this.planType, required this.qtdChapters, required this.duration, this.bibleLength, this.isNewTestament});

  @override
  State<_DaysList> createState() => _DaysListState();
}

class _DaysListState extends State<_DaysList> {

  @override
  void initState() {
    _plansProvider.getDailyReads(progressId: widget.planType.code);
    _plansProvider.generateChapters(widget.qtdChapters, widget.planType, bibleLength: widget.bibleLength, isNewTestament: widget.isNewTestament);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
              PopupMenuButton(
                  color: Theme.of(context).colorScheme.secondary,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: Consumer<PlansProvider>(
                          builder: (context, value, _) {
                            return TextButton.icon(
                              onPressed: (() {
                                if(!value.planNotificationStatus) {

                                }
                                value.updatePlanNotification(planType: widget.planType, status: !value.planNotificationStatus);
                              }),
                              icon: Icon(
                                  (!value.planNotificationStatus) ? Icons.notifications : Icons.notifications_off,
                                  color: Colors.white
                              ),
                              label: Text(!value.planNotificationStatus ? 'Ativar notificações' : 'Desativar notificações', style: const TextStyle(color: Colors.white),),
                            );
                          },
                        ),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: TextButton.icon(
                          onPressed: (() {
                            _plansProvider.dropDb(planType: widget.planType, progressId: widget.planType.code);
                          }),
                          icon: const Icon(Icons.info, color: Colors.white), label: const Text('Informações', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        child: TextButton.icon(
                          onPressed: (() => showDialog(
                              context: context,
                              builder: (context) => CancelPlanDialog(
                                  execute: (() {
                                    Navigator.pop(context, true);
                                    _plansProvider.dropDb(planType: widget.planType, progressId: widget.planType.code);
                                    setState(() {});
                                  })
                              )
                          ).then((value) => (value) ? Navigator.pop(context) : null)
                          ),
                          icon: const Icon(Icons.delete, color: Colors.white), label: const Text('Cancelar plano', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ];
                  })
            ],
          ),
        ),
        Expanded(
          child: Consumer<PlansProvider>(
            builder: (context, value, _) {
              if(value.loading || value.dailyReadsGrouped.isEmpty || value.dailyReadsGrouped.where((element) => element.isEmpty).isNotEmpty) {
                return const Center(
                  child: LoadingWidget(),
                );
              }

              return DaysByMonthList(qtdChapters: widget.qtdChapters, duration: widget.duration,);
            },
          ),
        )
      ],
    );
  }
}

class DaysByMonthList extends StatefulWidget {
  final int qtdChapters;
  final int duration;
  const DaysByMonthList({super.key, required this.duration, required this.qtdChapters});

  @override
  State<DaysByMonthList> createState() => _DaysByMonthListState();
}

class _DaysByMonthListState extends State<DaysByMonthList> {
  final ScrollController _controller = ScrollController();
  final DateTime now = DateTime.now();
  List<Map<String, dynamic>> dateList = [];
  late Map<String, List<Map<String, dynamic>>> daysByMonth;
  late List<String> months;
  final List<String> monthOrder = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  void generateDateList() {
    final day = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[0]);
    final month = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[1]);
    final year = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[2]);
    DateTime startedDay = DateTime(year, month, day);
    DateTime endDate = startedDay.add(Duration(days: widget.duration));
    List<Map<String, dynamic>> dates = [];

    for (DateTime date = startedDay; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      dates.add({"date": planStringDate(date), "year": date.year});
    }

    setState(() {
      dateList = dates;
    });
  }

  // void goTo({required int index, required int sublist}) async {
  //   sublist == 1
  //       ? await Scrollable.ensureVisible(firstSubListKeys[index].currentContext!,
  //           duration: const Duration(milliseconds: 500))
  //       : await Scrollable.ensureVisible(secondSubListKeys[index].currentContext!,
  //           duration: const Duration(milliseconds: 500));
  // }

  @override
  void initState() {
    generateDateList();
    daysByMonth = _organizeDaysByMonth(dateList);
    months = daysByMonth.keys.toList();
    super.initState();
  }

  Map<String, List<Map<String, dynamic>>> _organizeDaysByMonth(List<Map<String, dynamic>> days) {
    Map<String, List<Map<String, dynamic>>> daysByMonth = {};

    for (var day in days) {
      // Separar o dia e o mês
      List<String> parts = day["date"].split('de\n');
      String month = parts[1].trim();
      int year = day["year"];
      if (!daysByMonth.containsKey(month)) {
        daysByMonth[month] = [];
        daysByMonth[month]!.add({"date": day["date"], "year": year});
      }else if(daysByMonth[month]!.every((element) => element["year"] == year)) {
        daysByMonth[month]!.add({"date": day["date"], "year": year});
      }else {
        final List<Map<String, dynamic>> nextYearList = List.generate(dateList.where((element) => element["date"] == day["date"] && element["year"] == year).length, (index) => {"date": day["date"], "year": year});
        if(!daysByMonth.containsKey('$month*')) {
          daysByMonth['$month*'] = [];
        }
        daysByMonth['$month*']!.add(nextYearList.first);
      }
    }
    return daysByMonth;
  }

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Consumer<PlansProvider>(
        builder: (context, value, _) {
          return ListView.builder(
            itemCount: months.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              String month = months[index];
              bool isNextYearHeaderNeeded = false;
      
              // Check if the next year header is needed
              if(month == 'janeiro' && index > 0) {
                isNextYearHeaderNeeded = months[index - 1] == 'dezembro';
              }
      
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNextYearHeaderNeeded)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 38.0),
                      alignment: Alignment.center,
                      child: Text(
                        now.add(const Duration(days: 365)).year.toString(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    initiallyExpanded: now.month == monthOrder.indexOf(month) + 1,
                    title: Text(month.replaceAll('*', ''), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    children: [
                      GridView.builder(
                          controller: _controller,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: daysByMonth[month]!.length,
                          padding: const EdgeInsets.all(12.0),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 150.0,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1 / 1
                          ),
                          itemBuilder: (context, i) {
                            final element = dateList.where((element) => element["date"] == daysByMonth[month]![i]["date"] && element["year"] == daysByMonth[month]![i]["year"]);
                            final index = element.isNotEmpty ? dateList.indexOf(element.first) : 0;
                            return Stack(
                              //key: firstSubListKeys[i],
                              children: <Widget>[
                                Card(
                                  child: InkWell(
                                    onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": index, "chaptersLength": widget.qtdChapters, "qtdDays": widget.duration, "dailyRead": value.dailyReads})),
                                    child: Center(
                                      child: Text(
                                        daysByMonth[month]![i]["date"],
                                        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    child: value.dailyReadsGrouped.length > 1 && value.dailyReadsGrouped[index].where((element) => element.completed == 1).length >=  widget.qtdChapters
                                        ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                                    )
                                        : null),
                              ],
                            );
                          })
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}