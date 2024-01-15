import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/app_bar.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/loading_verses_widget.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verses_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/loading_widget.dart';

int initialVerse = 0;

class VersesScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapters;
  final int chapter;
  final int verseNumber;

  const VersesScreen(
      {Key? key,
      required this.chapter,
      required this.verseNumber,
      required this.bookName,
      required this.abbrev,
      required this.chapters,
      required this.bookIndex})
      : super(key: key);

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  PageController _pageController = PageController();
  int _chapters = 0;
  int _chapter = 0;
  bool notScrolling = true;
  String verseColor = 'Colors.transparent';

  @override
  initState() {
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    initialVerse = widget.verseNumber;
    allVersesTextSpan = [];
    super.initState();
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageController = PageController(initialPage: _chapter - 1);
    return Scaffold(
      appBar: VersesAppBar(
        bookName: widget.bookName,
        abbrev: widget.abbrev,
        bookIndex: widget.bookIndex,
        chapter: _chapter,
        chapters: _chapters,
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (ScrollEndNotification notification) {
          if (notification.metrics.pixels ==
              notification.metrics.maxScrollExtent) {
            setState(() {
              notScrolling = false;
            });
          } else {
            setState(() {
              notScrolling = true;
            });
          }
          return true;
        },
        child: Consumer<VersionProvider>(
          builder: (context, versionValue, _) {
            return Consumer<VersesProvider>(
              builder: (context, value, _) {
                if(value.allVerses == null || value.allVerses!.isEmpty || value.allVerses![widget.chapter] == null) {
                  return const LoadingWidget();
                }
                return PageView.builder(
                  controller: _pageController,
                  itemCount: _chapters,
                  itemBuilder: (BuildContext context, int i) {
                    return LoadingVersesWidget(
                      bookName: widget.bookName,
                      abbrev: widget.abbrev,
                      bookIndex: widget.bookIndex,
                      chapter: i + 1,
                      verseColors: verseColor,
                      listVerses: value.allVerses!,
                    );
                  },
                  onPageChanged: (page) {
                    value.resetVersesFoundCounter();
                    setState(() {
                      textEditingController.text = '';
                      listVerses = [];
                      allVersesTextSpan = [];
                    });
                    if(value.bottomSheetOpened) {
                      Navigator.pop(context);
                      value.openBottomSheet(false);
                      value.clearSelectedVerses(value.allVerses![_chapter]);
                    }
                    setState(() {
                      _chapter = page + 1;
                      initialVerse = 1;
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Consumer<VersesProvider>(
        builder: (context, item, child) {
          return VersesFloatingActionButton(
            notScrolling: notScrolling,
            chapter: _chapter,
            chapters: _chapters,
            pageController: _pageController
          );
        },
      ),
    );
  }
}