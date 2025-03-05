import 'package:biblia_flutter_app/screens/chapter_screen/widgets/chapters_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/chapters_provider.dart';
import '../../data/verses_provider.dart';

class ChapterScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapters;
  const ChapterScreen(
      {super.key,
      required this.bookName,
      required this.chapters,
      required this.abbrev,
      required this.bookIndex});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late final VersesProvider versesProvider;

  @override
  void initState() {
    final chaptersProvider = context.read<ChaptersProvider>();
    versesProvider = context.read<VersesProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if(chaptersProvider.currentBook != widget.bookName) {
          chaptersProvider.currentBook = widget.bookName;
          chaptersProvider.setChaptersRead(widget.bookName, widget.chapters);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false),
          icon: Icon(Icons.adaptive.arrow_back)
        ),
        title: Text(widget.bookName),
        actions: [
          Consumer<ChaptersProvider>(
            builder: (context, value, _) => IconButton(
              onPressed: () {
                if (value.readChapters.isNotEmpty && value.readChapters.every((c) => c)) {
                  value.removeAllChapters(widget.bookName, widget.chapters);
                } else {
                  value.addAllChapters(widget.bookName, widget.chapters);
                }
                versesProvider.refresh();
              },
              icon: value.readChapters.isNotEmpty && value.readChapters.every((c) => c == true)
                ? const Icon(Icons.check_box)
                : const Icon(Icons.check_box_outline_blank_rounded),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: ChapterCard(
        bookIndex: widget.bookIndex,
        chapters: widget.chapters,
        bookName: widget.bookName,
        abbrev: widget.abbrev,
      ),
    );
  }
}