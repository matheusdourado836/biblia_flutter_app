import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/widgets/chapters_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/saved_verses_provider.dart';

class ChapterScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int chapters;
  const ChapterScreen({Key? key, required this.bookName, required this.chapters, required this.abbrev}) : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool isSelected = false;
  late SavedVersesProvider _savedVersesProvider;

  @override
  void initState() {
    BooksDao().find(widget.bookName).then((value) {
      if(value.isNotEmpty) {
        if(value[0]["finishedReading"] == 1) {
          setState(() {
            isSelected = true;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _savedVersesProvider = Provider.of<SavedVersesProvider>(context);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.bookName)),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                isSelected = !isSelected;
                _savedVersesProvider.bookIsReadCheckBox(isSelected);
              });
              if(isSelected) {
                await BooksDao().save(widget.bookName, 1);
              }else {
                await BooksDao().delete(widget.bookName);
              }
              _savedVersesProvider.refresh();
            },
            icon: isSelected ? const Icon(Icons.check_box,) : const Icon(Icons.check_box_outline_blank_rounded),
          ),
        ],
      ),
      body: Container(
        height: height,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChapterCard(chapters: widget.chapters, bookName: widget.bookName, abbrev: widget.abbrev,)
        ),
      ),
    );
  }
}
