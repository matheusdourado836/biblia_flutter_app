import 'package:flutter/material.dart';

class ThreeMonthsPlanScreen extends StatelessWidget {
  const ThreeMonthsPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bíblia em 3 meses'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: const _InitPlanWidget(),
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

  void generateDateList() {
    DateTime today = DateTime.now();
    DateTime endDate = today.add(const Duration(days: 91));
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
    return '$day de \n$month';
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
          const Text(
            'Você deseja aprofundar sua intimidade com Deus e mergulhar ainda mais na riqueza das Escrituras? '
            'Apresentamos um plano de leitura da Bíblia em 3 meses, especialmente pensado para cristãos maduros que buscam uma conexão mais profunda com o Senhor.\n'
            'Este plano exigente, porém extremamente gratificante, guia você através de aproximadamente 13 capítulos diários. '
            'A cada dia, você será desafiado e inspirado, fortalecendo sua fé e ampliando seu entendimento das Escrituras.\n\n'
            'Reserve um tempo diário dedicado a essa leitura e permita que a Palavra de Deus penetre profundamente em seu coração. '
            'Este é um compromisso significativo, mas a recompensa será uma relação mais íntima e pessoal com Deus.'
            'Vamos juntos explorar e celebrar a beleza e a profundidade da Palavra de Deus!',
            textAlign: TextAlign.center),
          const Spacer(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  fixedSize: Size(MediaQuery.of(context).size.width * .85, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () => setState(() => showList = true), child: const Text('Iniciar plano'))
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
  List<GlobalKey> listKeys = [];
  final ScrollController _controller = ScrollController();

  void goTo({required int index}) async {
    await Scrollable.ensureVisible(listKeys[index].currentContext!, duration: const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    listKeys = List.generate(widget.daysList.length, (index) => GlobalKey());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: GridView.builder(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.daysList.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
              (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 130.0,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1 / 1),
          itemBuilder: (context, i) {
            return Stack(
              key: listKeys[i],
              children: <Widget>[
                Card(
                  elevation: 1.0,
                  child: InkWell(
                    onTap: (() => Navigator.pushNamed(context, 'selected_day', arguments: {"day": i, "chaptersLength": 13})),
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
    );
  }
}