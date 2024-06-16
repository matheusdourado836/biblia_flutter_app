import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/init_plan_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/format_date.dart';
import '../../../../helpers/loading_widget.dart';
import '../../../../models/enums.dart';

late PlansProvider _planProvider;

class ThreeMonthsPlanScreen extends StatefulWidget {
  const ThreeMonthsPlanScreen({super.key});

  @override
  State<ThreeMonthsPlanScreen> createState() => _ThreeMonthsPlanScreenState();
}

class _ThreeMonthsPlanScreenState extends State<ThreeMonthsPlanScreen> {

  @override
  void initState() {
    _planProvider = Provider.of<PlansProvider>(context, listen: false);
    _planProvider.checkIfPlanStarted(planType: PlanType.THREE_MONTHS);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bíblia em 3 meses'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<PlansProvider>(
        builder: (context, value, _) {
          if(value.loading) {
            return const LoadingWidget();
          }

          if(!value.startedThreeMonths) {
            return InitPlanWidget(planType: PlanType.THREE_MONTHS, onPressed: () => value.startReadingPlan(planId: PlanType.THREE_MONTHS));
          }

          return const _DaysList();
        },
      ),
    );
  }
}

class _DaysList extends StatefulWidget {
  const _DaysList();

  @override
  State<_DaysList> createState() => _DaysListState();
}

class _DaysListState extends State<_DaysList> {

  @override
  void initState() {
    _planProvider.getDailyReads(progressId: PlanType.THREE_MONTHS.code);
    _planProvider.generateChapters(13);
    //listKeys = List.generate(dateList.length, (index) => GlobalKey());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<PlansProvider>(
        builder: (context, value, _) {
          if(value.loading || value.dailyReadsGrouped.isEmpty || value.currentPlan ==  null) {
            return const Center(
              child: LoadingWidget(),
            );
          }
          return const DaysByMonthList();
        },
      ),
    );
  }
}

class DaysByMonthList extends StatefulWidget {
  const DaysByMonthList({super.key});

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
  List<GlobalKey> listKeys = [];

  void generateDateList() {
    final day = int.parse(_planProvider.currentPlan!.startDate!.split('/')[0]);
    final month = int.parse(_planProvider.currentPlan!.startDate!.split('/')[1]);
    final year = int.parse(_planProvider.currentPlan!.startDate!.split('/')[2]);
    DateTime startedDay = DateTime(year, month, day);
    DateTime endDate = startedDay.add(const Duration(days: 91));
    List<Map<String, dynamic>> dates = [];

    for (DateTime date = startedDay; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      dates.add({"date": planStringDate(date), "year": date.year});
    }

    setState(() {
      dateList = dates;
    });
  }

  void goTo({required int index}) async {
    await Scrollable.ensureVisible(listKeys[index].currentContext!, duration: const Duration(milliseconds: 500));
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
    super.initState();
    generateDateList();
    daysByMonth = _organizeDaysByMonth(dateList);
    months = daysByMonth.keys.toList();
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
    bool addedNextYearHeader = false;
    return Consumer<PlansProvider>(
      builder: (context, value, _) {
        return ListView.builder(
          itemCount: months.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            String month = months[index];
            bool isNextYearHeaderNeeded = false;

            // Check if the next year header is needed
            if (!addedNextYearHeader && month == 'janeiro' && index > 0) {
              String previousMonth = months[index - 1];
              if (monthOrder.indexOf(previousMonth) == monthOrder.length - 1) {
                isNextYearHeaderNeeded = true;
                addedNextYearHeader = true;
              }
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
                            maxCrossAxisExtent:
                            (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 130.0,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 1 / 1
                        ),
                        itemBuilder: (context, i) {
                          final element = dateList.where((element) => element["date"] == daysByMonth[month]![i]["date"] && element["year"] == daysByMonth[month]![i]["year"]);
                          final index = element.isNotEmpty ? dateList.indexOf(element.first) : 0;
                          return Stack(
                            //key: listKeys[i],
                            children: <Widget>[
                              Card(
                                elevation: 1.0,
                                child: InkWell(
                                  onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": index, "chaptersLength": 13, "qtdDays": 92, "dailyRead": value.dailyReads})),
                                  child: Center(
                                    child: Text(
                                      daysByMonth[month]![i]["date"],
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  child: value.dailyReadsGrouped[index].where((element) => element.completed == 1).length == 13
                                      ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                                  )
                                      : null),
                            ],
                          );
                        }
                    ),
                    // GridView.builder(
                    //     controller: _controller,
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     shrinkWrap: true,
                    //     itemCount: daysByMonth[month]!.length,
                    //     padding: const EdgeInsets.all(12.0),
                    //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    //         maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 150.0,
                    //         crossAxisSpacing: 10.0,
                    //         mainAxisSpacing: 10.0,
                    //         childAspectRatio: 1 / 1
                    //     ),
                    //     itemBuilder: (context, i) {
                    //       final element = dateList.where((element) => element["date"] == daysByMonth[month]![i]["date"] && element["year"] == daysByMonth[month]![i]["year"]);
                    //       final index = element.isNotEmpty ? dateList.indexOf(element.first) : 0;
                    //       return Stack(
                    //         //key: firstSubListKeys[i],
                    //         children: <Widget>[
                    //           Card(
                    //             child: InkWell(
                    //               onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": index, "chaptersLength": 3, "qtdDays": 397, "dailyRead": value.dailyReads})),
                    //               child: Center(
                    //                 child: Text(
                    //                   daysByMonth[month]![i]["date"],
                    //                   style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           SizedBox(
                    //               child: value.dailyReadsGrouped[index].where((element) => element.completed == 1).length == 3
                    //                   ? Icon(
                    //                 Icons.check_circle,
                    //                 color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                    //               )
                    //                   : null),
                    //         ],
                    //       );
                    //     })
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}