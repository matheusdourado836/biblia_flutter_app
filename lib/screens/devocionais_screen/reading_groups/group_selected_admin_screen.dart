import 'dart:async';
import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../data/bible_data.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';

class GroupSelectedAdminScreen extends StatefulWidget {
  final Group group;

  const GroupSelectedAdminScreen({super.key, required this.group});

  @override
  State<GroupSelectedAdminScreen> createState() => _GroupSelectedAdminScreenState();
}

class _GroupSelectedAdminScreenState extends State<GroupSelectedAdminScreen> {
  final BibleData bibleData = BibleData();
  late final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
  List<Map<String, dynamic>> books = [];
  List<List<Map<String, dynamic>>> dailyReadings = [];
  StreamSubscription<List<Message>>? listener;
  List<MyUser> participantes = [];
  int qtdChapters = 0;
  int difference = 0;
  int daysMissed = 0;

  @override
  void initState() {
    super.initState();
    final startDate = widget.group.startDate!;
    difference = DateTime.now().difference(startDate).inDays;
    final daysList = widget.group.dailyReading?.dias.entries.toList() ?? [];
    daysList.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    final daysPassed = daysList.sublist(0, difference);
    daysMissed = daysPassed.where((d) => d.value.capitulos.values.where((listIds) => listIds.length == widget.group.participantes!.length).isEmpty).toList().length;
    listener = groupsProvider.getGroupMessages(widget.group.id!).listen((onMessage) {
      groupsProvider.newMessage(onMessage);
    });
    if(participantes.isEmpty) {
      final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
      groupsProvider.getUsersById(ids: widget.group.participantes ?? []).then((res) {
        if(res?.isNotEmpty ?? false) {
          setState(() => participantes = res!);
        }
      });
    }
    _initializeReadingPlan();
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }

  void _initializeReadingPlan() {
    // Montar a lista de capítulos do grupo
    for (var book in widget.group.books ?? []) {
      final data = bibleData.data[0]["text"].firstWhere((b) => b["name"] == book);
      for (var (index, chapter) in (data["chapters"] as List).indexed) {
        books.add({
          "book": data["name"],
          "chapter": chapter,
          "number": index + 1,
        });
      }
      qtdChapters += (data["chapters"] as List).length;
    }

    // Calcular dias do plano
    final qtdDays = widget.group.endDate!.difference(widget.group.startDate!).inDays;

    // Dividir capítulos pelos dias
    dailyReadings = _generateDailyReadings(books, qtdDays);
  }

  List<List<Map<String, dynamic>>> _generateDailyReadings(List<Map<String, dynamic>> chapters, int days) {
    List<List<Map<String, dynamic>>> plan = [];
    final dailyReading = GroupDailyReading(dias: {});
    final Map<String, DayReading> daysMap = {};

    int chaptersPerDay = chapters.length ~/ days; // Capítulos por dia
    int remainingChapters = chapters.length % days; // Capítulos restantes

    int currentIndex = 0;

    for (int i = 0; i < days; i++) {
      int chaptersForToday = chaptersPerDay + (remainingChapters > 0 ? 1 : 0);
      if (remainingChapters > 0) remainingChapters--;
      Map<String, List<String>> capitulos = {};
      for(var (index, _) in chapters.sublist(currentIndex, currentIndex + chaptersForToday).indexed) {
        capitulos.addAll({(index + 1).toString(): []});
      }
      daysMap.addAll({
        (i + 1).toString(): DayReading(capitulos: capitulos)
      });

      plan.add(chapters.sublist(currentIndex, currentIndex + chaptersForToday));
      currentIndex += chaptersForToday;
    }

    if(widget.group.dailyReading == null) {
      dailyReading.dias = daysMap;
      widget.group.dailyReading = dailyReading;
      final ReadingGroupsProvider groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
      groupsProvider.updateDailyReading(dailyReading, widget.group.id!);
    }

    return plan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(widget.group.nome ?? ''),
            const SizedBox(height: 4),
            if(daysMissed == 0)
              const Text('Leitura em dia', style: TextStyle(fontSize: 12))
            else
              Text(
                  'Leitura atrasada em $daysMissed dias',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
              )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              'group_admin_config_screen',
              arguments: {"group": widget.group, "participantes": participantes}
            ),
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 4 / 4,
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16 , 150),
        itemCount: dailyReadings.length,
        itemBuilder: (context, index) {
          bool allRead = widget.group.dailyReading?.dias[(index + 1).toString()]?.capitulos.values.every((listIds) => listIds.length == widget.group.participantes!.length) ?? false;
          return Stack(
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  'day_selected_screen',
                  arguments: {
                    "day": 'DIA ${index + 1}',
                    "chapters": dailyReadings[index],
                    "group": widget.group
                  },
                ).whenComplete(() => setState(() {})),
                child: Card(
                  child: Center(
                    child: Text(
                      'DIA\n${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                ),
              ),
              if(allRead)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(
                    Icons.check_circle,
                    size: 30,
                    color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                  ),
                )
            ],
          ).animate(
            target: index == difference ? 1 : 0,
            onComplete: (c) {
              if(index == difference) {
                c.repeat();
              }
            }
          )
            .moveY(begin: 10, end: -10, curve: Curves.easeInOut, duration: 800.ms)
            .then()
            .moveY(begin: -10, end: 10, curve: Curves.easeInOut);
        },
      ),
      floatingActionButton: Consumer<ReadingGroupsProvider>(
        builder: (context, value, _) {
          return FloatingActionButton(
            backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
            onPressed: () =>
              Navigator.pushNamed(
                context,
                'chat_screen',
                arguments: {
                  "group": widget.group,
                  "participantes": participantes
                }
              ),
            child: Badge.count(
              count: value.unreadMessages,
              child: Icon(
                Icons.chat_bubble,
                size: 26,
                color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
