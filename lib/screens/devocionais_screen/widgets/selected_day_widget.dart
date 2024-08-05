import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/bible_data.dart';

class SelectedDayWidget extends StatefulWidget {
  final int day;
  final int chaptersLength;
  final int qtdDays;
  final List<DailyRead> dailyRead;
  const SelectedDayWidget({super.key, required this.chaptersLength, required this.dailyRead, required this.qtdDays, required this.day});

  @override
  State<SelectedDayWidget> createState() => _SelectedDayWidgetState();
}

class _SelectedDayWidgetState extends State<SelectedDayWidget> {
  final BibleData _bibleData = BibleData();
  late final PageController _controller;
  List<List<DailyRead>> dailyReads = [];
  int i = 1;

  @override
  void initState() {
    i =  widget.day + 1;
    _controller = PageController(initialPage: widget.day);
    super.initState();
  }

  Map<String, String> extractBookAndChapter(String input) {
    List<String> parts = input.split(' ');
    String chapter = parts.removeLast();
    String bookName = parts.join(' ');
    return {
      'bookName': bookName,
      'chapter': chapter
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dia $i de ${widget.qtdDays}'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<PlansProvider>(
        builder: (context, value, _) {
          dailyReads = value.dailyReadsGrouped;
          return PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => i = page + 1),
            itemCount: value.chaptersDivided.length,
            itemBuilder: (context, index) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 16, right: 12),
                itemCount: value.chaptersDivided[index].length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Checkbox(
                            value: dailyReads[index][i].completed == 1,
                            onChanged: ((newValue) {
                              bool allRead = dailyReads[index].every((element) => element.completed == 1);
                              if(allRead) {
                                dailyReads[index][i].completed == 0 ? dailyReads[index][i].completed = 1 : dailyReads[index][i].completed = 0;
                                setState(() {});
                                value.markChapter(dailyReads[index][i].chapter!, read: dailyReads[index][i].completed ?? 0, progressId: widget.dailyRead[i].progressId!, update: true);
                                value.updateCurrentDay(planId: widget.dailyRead[i].progressId!, action: 0);
                              }else {
                                dailyReads[index][i].completed == 0 ? dailyReads[index][i].completed = 1 : dailyReads[index][i].completed = 0;
                                bool allRead = dailyReads[index].every((element) => element.completed == 1);
                                setState(() {});
                                value.markChapter(dailyReads[index][i].chapter!, read: dailyReads[index][i].completed ?? 0, progressId: widget.dailyRead[i].progressId!, update: (allRead) ? true : null);
                                value.checkIfCompletedDailyRead(planId: widget.dailyRead[i].progressId!, qtdChapterRequired: dailyReads[index].length);
                              }
                            })
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (() {
                              final versesProvider = Provider.of<VersesProvider>(context, listen: false);
                              final versionProvider = Provider.of<VersionProvider>(context, listen: false);
                              final book = _bibleData.data[0]["text"].where((element) => element["name"] == extractBookAndChapter(value.chaptersDivided[index][i])["bookName"]).first;
                              final bookIndex = _bibleData.data[0]["text"].indexOf(book);
                              final chapter = int.parse(extractBookAndChapter(value.chaptersDivided[index][i])["chapter"]!);
                              versesProvider.loadVerses(bookIndex, book["name"], versionName: versionProvider.selectedOption);
                              Navigator.pushNamed(context, 'verses_screen', arguments: {
                                "bookName": book["name"],
                                "abbrev": book["abbrev"],
                                "bookIndex": bookIndex,
                                "chapters": book["chapters"].length,
                                "chapter": chapter,
                                "verseNumber": 1,
                                "reading_plan": true,
                              });
                            }),
                            child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value.chaptersDivided[index][i], style: Theme.of(context).textTheme.titleLarge,),
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
                },
              );
            },
          );
        },
      ),
    );
  }
}
