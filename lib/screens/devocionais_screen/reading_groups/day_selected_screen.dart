import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/group_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/verses_provider.dart';

class DaySelectedScreen extends StatefulWidget {
  final String day;
  final List<Map<String, dynamic>> chapters;
  final Group group;
  const DaySelectedScreen({super.key, required this.day, required this.chapters, required this.group});

  @override
  State<DaySelectedScreen> createState() => _DaySelectedScreenState();
}

class _DaySelectedScreenState extends State<DaySelectedScreen> {
  late final ReadingGroupsProvider _groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
  List<MyUser> participantes = [];
  String userId = '';
  int day = 0;

  @override
  void initState() {
    userId = _groupsProvider.currentUser!.id!;
    day = int.parse(widget.day.split(' ')[1]);
    if(participantes.isEmpty) {
      _groupsProvider.getUsersById(ids: widget.group.participantes ?? []).then((res) {
        if(res?.isNotEmpty ?? false) {
          setState(() {
            participantes = res!;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        actions: [
          if(participantes.isNotEmpty)
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => GroupProgressDialog(
                  group: widget.group,
                  capitulos: widget.group.dailyReading?.dias[day.toString()]?.capitulos ?? {},
                  chaptersLabel: widget.chapters.map((c) => c["number"].toString()).toList(),
                  participantes: participantes
                )
              ).whenComplete(() => setState(() {})),
              icon: const Icon(Icons.info)
            )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.chapters.length,
        itemBuilder: (context, index) {
          final book = widget.chapters[index];
          final isChecked = widget.group.dailyReading?.dias[day.toString()]?.capitulos[(index + 1).toString()]?.contains(userId) ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (newValue) {
                    setState(() {
                      if(newValue ?? false) {
                        widget.group.dailyReading?.dias[day.toString()]?.capitulos[(index + 1).toString()]?.add(userId);
                      }else {
                        widget.group.dailyReading?.dias[day.toString()]?.capitulos[(index + 1).toString()]?.remove(userId);
                      }
                    });
                    _groupsProvider.updateDailyReading(widget.group.dailyReading!, widget.group.id!);
                  }
                ),
                Expanded(
                  child: InkWell(
                    onTap: (() {
                      final BibleData bibleData = BibleData();
                      final versesProvider = Provider.of<VersesProvider>(context, listen: false);
                      versesProvider.clear();
                      final matchBook = bibleData.data[0]["text"].where((element) => element["name"] == book["book"]).first;
                      final bookIndex = bibleData.data[0]["text"].indexOf(matchBook);
                      final chapter = book["number"];
                      versesProvider.loadVerses(bookIndex, matchBook["name"]);
                      Navigator.pushNamed(context, 'verses_screen', arguments: {
                        "bookName": matchBook["name"],
                        "abbrev": matchBook["abbrev"],
                        "bookIndex": bookIndex,
                        "chapters": matchBook["chapters"].length,
                        "chapter": chapter,
                        "verseNumber": 1,
                      });
                    }),
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${book["book"]} capítulo ${book["number"]}', style: Theme.of(context).textTheme.titleLarge,),
                              Icon(Icons.keyboard_arrow_right_rounded, color: Theme.of(context).colorScheme.onError, size: 28),
                            ],
                          ),
                        )
                    ),
                  )
                )
              ],
            ),
          );
        }
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {
              setState(() {
                for(int i = 0; i < widget.chapters.length; i++) {
                  widget.group.dailyReading?.dias[day.toString()]?.capitulos[(i + 1).toString()]!.add(userId);
                }
              });
            },
            child: const Text('Marcar leitura concluída')
          ),
        ),
      ),
    );
  }
}
