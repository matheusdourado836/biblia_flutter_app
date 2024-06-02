import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/bible_data.dart';

class SelectedDayWidget extends StatefulWidget {
  final int day;
  final int chaptersLength;
  const SelectedDayWidget({super.key, required this.day, required this.chaptersLength});

  @override
  State<SelectedDayWidget> createState() => _SelectedDayWidgetState();
}

class _SelectedDayWidgetState extends State<SelectedDayWidget> {
  final BibleData _bibleData = BibleData();
  late final PageController _controller;
  int i = 1;
  int chapter = 0;
  List<String> chapters = [];
  List<List<String>> chaptersDivided = [];

  List<List<String>> partitionList(List<String> list) {
    List<List<String>> partitions = [];

    for (int i = 0; i < list.length; i += widget.chaptersLength) {
      int end = (i + widget.chaptersLength < list.length) ? i + widget.chaptersLength : list.length;
      partitions.add(list.sublist(i, end));
    }

    return partitions;
  }

  @override
  void initState() {
    i = widget.day + 1;
    _controller = PageController(initialPage: widget.day);
    for (var book in _bibleData.data[0]) {
      for (var i = 0; i < book["chapters"].length; i++) {
        chapters.add('${book["name"]} ${i + 1}');
      }
    }
    chaptersDivided = partitionList(chapters);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dia $i de ${chaptersDivided.length - 1}'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (page) => setState(() => i = page + 1),
        itemCount: chaptersDivided.length - 1,
        itemBuilder: (context, index) {
          if(chaptersDivided[index + 1].length < widget.chaptersLength) {
            for(var i = 0; i < chaptersDivided[index + 1].length; i++) {
              if(!chaptersDivided[index].contains(chaptersDivided[index + 1][i])) {
                chaptersDivided[index].add(chaptersDivided[index + 1][i]);
              }
            }
          }
          return ListView.builder(
            itemCount: chaptersDivided[index].length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: (() {
                  final versesProvider = Provider.of<VersesProvider>(context, listen: false);
                  final book = _bibleData.data[0].where((element) => element["name"] == chaptersDivided[index][i].split(' ')[0]).first;
                  final bookIndex = _bibleData.data[0].indexOf(book);
                  final chapter = int.parse(chaptersDivided[index][i].split(' ')[1]);
                  versesProvider.loadVerses(bookIndex, book["name"]);
                  Navigator.pushNamed(context, 'verses_screen', arguments: {
                    "bookName": book["name"],
                    "abbrev": book["abbrev"],
                    "bookIndex": bookIndex,
                    "chapters": book["chapters"].length,
                    "chapter": chapter,
                    "verseNumber": 1,
                  });
                }),
                child: Row(
                  children: [
                    Checkbox(value: false, onChanged: ((value) {})),
                    Text(chaptersDivided[index][i])
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
