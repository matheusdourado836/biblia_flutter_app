import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/widgets/chapters_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/chapters_provider.dart';
import '../../data/theme_provider.dart';
import '../../data/verses_provider.dart';

late VersesProvider versesProvider;
late ChaptersProvider chaptersProvider;

class ChapterScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapters;
  const ChapterScreen(
      {Key? key,
      required this.bookName,
      required this.chapters,
      required this.abbrev,
      required this.bookIndex})
      : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final BooksDao booksDao = BooksDao();
  bool isSelected = false;

  @override
  void initState() {
    booksDao.find(widget.bookName).then((value) {
      if (value.isNotEmpty) {
        if (value[0]["finishedReading"] == 1) {
          setState(() {
            isSelected = true;
          });
        }
      }
    });
    booksDao.saveChapters(widget.bookName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    versesProvider = Provider.of<VersesProvider>(context, listen: false);
    chaptersProvider = Provider.of<ChaptersProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.getThemeMode();
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.bookName),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                isSelected = !isSelected;
                versesProvider.bookIsReadCheckBox(isSelected);
              });
              if (isSelected) {
                chaptersProvider.addAllChapters(widget.bookName, widget.chapters);
              } else {
                chaptersProvider.removeAllChapters(widget.bookName, widget.chapters);
              }
              versesProvider.refresh();
            },
            icon: isSelected
                ? const Icon(
                    Icons.check_box,
                  )
                : const Icon(Icons.check_box_outline_blank_rounded),
          ),
        ],
      ),
      body: Container(
        height: height,
        color: Theme.of(context).primaryColor,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChapterCard(
              bookIndex: widget.bookIndex,
              chapters: widget.chapters,
              bookName: widget.bookName,
              abbrev: widget.abbrev,
            )),
      ),
    );
  }
}