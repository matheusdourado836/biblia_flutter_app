import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
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

  const DaySelectedScreen({
    super.key,
    required this.day,
    required this.chapters,
    required this.group,
  });

  @override
  State<DaySelectedScreen> createState() => _DaySelectedScreenState();
}

class _DaySelectedScreenState extends State<DaySelectedScreen> {
  late final UserProvider _userProvider = Provider.of<UserProvider>(context, listen: false);
  late final String userId;
  late final int day;

  List<MyUser> participantes = [];

  @override
  void initState() {
    super.initState();
    userId = _userProvider.currentUser!.id!;
    day = int.parse(widget.day.split(' ')[1]);

    _loadParticipantes();
  }

  Future<void> _loadParticipantes() async {
    final res = await _userProvider.getUsersById(ids: widget.group.participantes ?? []);
    if (res?.isNotEmpty ?? false) {
      setState(() => participantes = res!);
    }
  }

  void _toggleChapter(int chapterIndex, bool isChecked) {
    final chapterKey = (chapterIndex + 1).toString();
    final capitulos = widget.group.dailyReading?.dias[day.toString()]?.capitulos;

    if (capitulos == null) return;

    setState(() {
      if (isChecked) {
        capitulos[chapterKey]?.add(userId);
      } else {
        capitulos[chapterKey]?.remove(userId);
      }
    });

    _userProvider.updateDailyReading(
        groupId: widget.group.id!,
        dayId: day.toString(),
        chapterId: chapterKey,
        userId: userId,
        isRead: isChecked
    );
  }

  void _markAllChaptersAsRead() {
    final capitulos = widget.group.dailyReading?.dias[day.toString()]?.capitulos;
    if (capitulos == null) return;

    setState(() {
      for (int i = 0; i < widget.chapters.length; i++) {
        capitulos[(i + 1).toString()]?.add(userId);
      }
    });

    _userProvider.markAllChaptersRead(
      groupId: widget.group.id!,
      dayId: day.toString(),
      chapterIds: widget.chapters.length,
      userId: userId,
    );
  }

  void _openChapter(Map<String, dynamic> book) {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);

    versesProvider.clear();

    final matchBook = versesProvider.bibleData[0]["text"].firstWhere((e) => e["name"] == book["book"]);
    final bookIndex = versesProvider.bibleData[0]["text"].indexOf(matchBook);
    final chapterNumber = book["number"];

    versesProvider.loadVerses(
      bookIndex,
      matchBook["name"],
      versionName: versionProvider.selectedOption,
    );

    Navigator.pushNamed(context, 'verses_screen', arguments: {
      "bookName": matchBook["name"],
      "abbrev": matchBook["abbrev"],
      "bookIndex": bookIndex,
      "chapters": matchBook["chapters"].length,
      "chapter": chapterNumber,
      "verseNumber": 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    final capitulos = widget.group.dailyReading?.dias[day.toString()]?.capitulos ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        actions: [
          if (participantes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => GroupProgressDialog(
                  group: widget.group,
                  day: day,
                  capitulos: capitulos,
                  chaptersLabel: widget.chapters.map((c) => c["number"].toString()).toList(),
                  participantes: participantes,
                ),
              ).whenComplete(() => setState(() {})),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.chapters.length,
        itemBuilder: (_, index) {
          final book = widget.chapters[index];
          final chapterKey = (index + 1).toString();
          final isChecked = capitulos[chapterKey]?.contains(userId) ?? false;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (newValue) => _toggleChapter(index, newValue ?? false),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _openChapter(book),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${book["book"]} capítulo ${book["number"]}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Theme.of(context).colorScheme.onError,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _markAllChaptersAsRead,
            child: const Text('Marcar leitura concluída'),
          ),
        ),
      ),
    );
  }
}