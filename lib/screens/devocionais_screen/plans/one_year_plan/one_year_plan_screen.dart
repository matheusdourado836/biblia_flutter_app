import 'package:biblia_flutter_app/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneYearPlanScreen extends StatefulWidget {
  const OneYearPlanScreen({super.key});

  @override
  State<OneYearPlanScreen> createState() => _OneYearPlanScreenState();
}

class _OneYearPlanScreenState extends State<OneYearPlanScreen> {
  bool _started = false;

  List<String> dateList = [];

  void generateDateList() {
    DateTime today = DateTime.now();
    DateTime endDate = today.add(const Duration(days: 397));
    List<String> dates = [];

    for (DateTime date = today; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      dates.add(formatDate(date));
    }

    setState(() {
      dateList = dates;
    });
  }

  String formatDate(DateTime date) {
    List<String> monthNames = [
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
      'dezembro'
    ];
    String day = date.day.toString().padLeft(2, '0');
    String month = monthNames[date.month - 1];
    return '$day de $month';
  }

  void checkIfExists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final oneYearCode = prefs.getInt("one_year");
    (oneYearCode == null) ? _started = false : _started = true;
    setState(() => _started);
  }

  void cancelPlan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("one_year");
  }

  @override
  void initState() {
    generateDateList();
    checkIfExists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bíblia em 1 ano'),
        actions: [
          IconButton(
              onPressed: (() {
                cancelPlan();
              }),
              icon: const Icon(Icons.delete)
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: (_started) ? _DaysList(daysList: dateList) : const _InitPlanWidget(),
    );
  }
}

class _InitPlanWidget extends StatefulWidget {
  const _InitPlanWidget({super.key});

  @override
  State<_InitPlanWidget> createState() => _InitPlanWidgetState();
}

class _InitPlanWidgetState extends State<_InitPlanWidget> {
  bool showList = false;
  List<String> dateList = [];

  void startPlan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("one_year", PlanType.ONE_YEAR.code);
  }

  void generateDateList() {
    DateTime today = DateTime.now();
    DateTime endDate = today.add(const Duration(days: 397));
    List<String> dates = [];

    for (DateTime date = today; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
      dates.add(formatDate(date));
    }

    setState(() {
      dateList = dates;
    });
  }

  String formatDate(DateTime date) {
    List<String> monthNames = [
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
      'dezembro'
    ];
    String day = date.day.toString().padLeft(2, '0');
    String month = monthNames[date.month - 1];
    return '$day de $month';
  }

  @override
  void initState() {
    generateDateList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (showList)
        ? _DaysList(
            daysList: dateList,
          )
        : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    'Você deseja aprofundar seu conhecimento e fortalecer sua fé? Junte-se a nós no Plano de Leitura da Bíblia em 1 Ano! '
                    'Este plano é perfeito para quem quer explorar as Escrituras de forma consistente e reflexiva, dedicando apenas alguns minutos por dia.\n\n'
                    'Dividimos a Bíblia em leituras diárias acessíveis. '
                    'Cada dia traz novas lições e inspirações, proporcionando uma jornada espiritual contínua e significativa ao longo do ano.\n\n'
                    'Comece hoje mesmo e transforme seu ${DateTime.now().year} com a Palavra de Deus!\n\n'
                    'Reserve um momento diário para essa leitura e descubra as maravilhas que a Bíblia tem a oferecer. '
                    'Participe dessa jornada e permita que a Palavra ilumine seu caminho todos os dias.',
                    textAlign: TextAlign.center, style: const TextStyle(height: 1.5),),
                const Spacer(),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        fixedSize: Size(MediaQuery.of(context).size.width * .85, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () => startPlan(), child: const Text('Iniciar plano'))
              ],
            ),
        );
  }
}

class _DaysList extends StatefulWidget {
  final List<String> daysList;
  const _DaysList({super.key, required this.daysList});

  @override
  State<_DaysList> createState() => _DaysListState();
}

class _DaysListState extends State<_DaysList> {
  List<GlobalKey> firstSubListKeys = [];
  List<GlobalKey> secondSubListKeys = [];
  List<String> firstSubList = [];

  List<String> secondSubList = [];

  final ScrollController _controller = ScrollController();

  void splitDateList(List<String> dates) {
    int index = dates.indexOf('31 de dezembro') + 1;

    firstSubList = dates.sublist(0, index);
    secondSubList = dates.sublist(index, dates.length);
  }

  void goTo({required int index, required int sublist}) async {
    sublist == 1
        ? await Scrollable.ensureVisible(firstSubListKeys[index].currentContext!,
            duration: const Duration(milliseconds: 500))
        : await Scrollable.ensureVisible(secondSubListKeys[index].currentContext!,
            duration: const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    splitDateList(widget.daysList);
    firstSubListKeys = List.generate(firstSubList.length, (index) => GlobalKey());
    secondSubListKeys = List.generate(secondSubList.length, (index) => GlobalKey());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: firstSubList.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 150.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1 / 1),
              itemBuilder: (context, i) {
                return Stack(
                  key: firstSubListKeys[i],
                  children: <Widget>[
                    Card(
                      elevation: 1.0,
                      child: InkWell(
                        onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": i, "chaptersLength": 3})),
                        child: Center(
                          child: Text(
                            widget.daysList[i],
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        child: true
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                              )
                            : null),
                  ],
                );
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 24, 0, 24),
            child: Text(DateTime.now().add(const Duration(days: 365)).year.toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: secondSubList.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 150.0,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1 / 1),
              itemBuilder: (context, i) {
                return Stack(
                  key: secondSubListKeys[i],
                  children: <Widget>[
                    Card(
                      elevation: 1.0,
                      child: InkWell(
                        onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": firstSubList.length + i, "chaptersLength": 3})),
                        child: Center(
                          child: Text(
                            secondSubList[i],
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        child: true
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                              )
                            : null),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
