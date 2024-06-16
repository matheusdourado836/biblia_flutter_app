import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/init_plan_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/format_date.dart';

late PlansProvider _plansProvider;

class OneYearPlanScreen extends StatefulWidget {
  const OneYearPlanScreen({super.key});

  @override
  State<OneYearPlanScreen> createState() => _OneYearPlanScreenState();
}

class _OneYearPlanScreenState extends State<OneYearPlanScreen> {

  @override
  void initState() {
    _plansProvider = Provider.of<PlansProvider>(context, listen: false);
    _plansProvider.checkIfPlanStarted(planType: PlanType.ONE_YEAR);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bíblia em 1 ano'),
        actions: [
          PopupMenuButton(
            color: Theme.of(context).colorScheme.secondary,
            itemBuilder: (context) {
              return [
                  PopupMenuItem(
                    child: TextButton.icon(
                      onPressed: (() {
                        _plansProvider.dropDb();
                      }),
                      icon: const Icon(Icons.notifications, color: Colors.white,), label: const Text('Ativar notificações', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton.icon(
                      onPressed: (() {
                        _plansProvider.dropDb();
                      }),
                      icon: const Icon(Icons.info, color: Colors.white), label: const Text('Informações', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton.icon(
                        onPressed: (() {
                          _plansProvider.dropDb();
                        }),
                        icon: const Icon(Icons.delete, color: Colors.white), label: const Text('Cancelar plano', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ];
            })
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<PlansProvider>(
        builder: (context, value, _) {
          if(value.loading) {
            return const LoadingWidget();
          }

          if(!value.startedOneYear) {
            return InitPlanWidget(planType: PlanType.ONE_YEAR, onPressed: () => value.startReadingPlan(planId: PlanType.ONE_YEAR));
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
    _plansProvider.getDailyReads(progressId: PlanType.ONE_YEAR.code);
    _plansProvider.generateChapters(3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<PlansProvider>(
        builder: (context, value, _) {
          if(value.loading || value.dailyReadsGrouped.isEmpty || value.dailyReadsGrouped.where((element) => element.isEmpty).isNotEmpty || value.currentPlan ==  null) {
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

  void generateDateList() {
    final day = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[0]);
    final month = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[1]);
    final year = int.parse(_plansProvider.currentPlan!.startDate!.split('/')[2]);
    DateTime startedDay = DateTime(year, month, day);
    DateTime endDate = startedDay.add(const Duration(days: 396));
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
                                  onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": index, "chaptersLength": 3, "qtdDays": 397, "dailyRead": value.dailyReads})),
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
                                  child: value.dailyReadsGrouped.length > 1 && value.dailyReadsGrouped[index].where((element) => element.completed == 1).length >= 3
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
    );
  }
}