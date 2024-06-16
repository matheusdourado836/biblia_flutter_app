import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:biblia_flutter_app/models/enums.dart';
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
        title: Text('Dia $i de ${widget.qtdDays - 1}'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<PlansProvider>(
        builder: (context, value, _) {
          return PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => i = page + 1),
            itemCount: value.chaptersDivided.length - 1,
            itemBuilder: (context, index) {
              if(value.chaptersDivided[index + 1].length < widget.chaptersLength) {
                for(var i = 0; i < value.chaptersDivided[index + 1].length; i++) {
                  if(!value.chaptersDivided[index].contains(value.chaptersDivided[index + 1][i])) {
                    value.chaptersDivided[index].add(value.chaptersDivided[index + 1][i]);
                    value.dailyReadsGrouped[index].add(value.dailyReadsGrouped[index + 1][i]);
                  }
                }
              }
              return ListView.builder(
                itemCount: value.chaptersDivided[index].length,
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: (() {
                      final versesProvider = Provider.of<VersesProvider>(context, listen: false);
                      final book = _bibleData.data[0].where((element) => element["name"] == extractBookAndChapter(value.chaptersDivided[index][i])["bookName"]).first;
                      final bookIndex = _bibleData.data[0].indexOf(book);
                      final chapter = int.parse(extractBookAndChapter(value.chaptersDivided[index][i])["chapter"]!);
                      versesProvider.loadVerses(bookIndex, book["name"]);
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
                    child: Row(
                      children: [
                        Checkbox(
                            value: value.dailyReadsGrouped[index][i].completed == 1,
                            onChanged: ((newValue) {
                              bool allRead = value.dailyReadsGrouped[index].every((element) => element.completed == 1);
                              if(allRead) {
                                value.dailyReadsGrouped[index][i].completed == 0 ? value.dailyReadsGrouped[index][i].completed = 1 : value.dailyReadsGrouped[index][i].completed = 0;
                                setState(() {});
                                value.markChapter(value.dailyReadsGrouped[index][i].chapter!, read: value.dailyReadsGrouped[index][i].completed ?? 0, progressId: widget.dailyRead[i].progressId!, update: true);
                                value.updateCurrentDay(planId: widget.dailyRead[i].progressId!, action: 0);
                              }else {
                                value.dailyReadsGrouped[index][i].completed == 0 ? value.dailyReadsGrouped[index][i].completed = 1 : value.dailyReadsGrouped[index][i].completed = 0;
                                setState(() {});
                                bool allRead = value.dailyReadsGrouped[index].every((element) => element.completed == 1);
                                value.markChapter(value.dailyReadsGrouped[index][i].chapter!, read: value.dailyReadsGrouped[index][i].completed ?? 0, progressId: widget.dailyRead[i].progressId!, update: (allRead) ? true : null);
                                value.checkIfCompletedDailyRead(planId: widget.dailyRead[i].progressId!, qtdChapterRequired: value.dailyReadsGrouped[index].length);
                              }
                            })
                        ),
                        Text(value.chaptersDivided[index][i])
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
