import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/app_bar.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verses_widget.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verses_floating_action_button.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../data/version_provider.dart';
import '../../helpers/loading_widget.dart';

int initialVerse = 0;

class VersesScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapters;
  final int chapter;
  final int verseNumber;
  final bool? readingPlan;

  const VersesScreen(
      {super.key,
      required this.chapter,
      required this.verseNumber,
      required this.bookName,
      required this.abbrev,
      required this.chapters,
      required this.bookIndex,
      this.readingPlan
      });

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  late final versesProvider = Provider.of<VersesProvider>(context, listen: false);
  late final PageController _pageController;
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int _chapters = 0;
  int _chapter = 0;
  String verseColor = 'Colors.transparent';
  final EventBus eventBus = EventBus();

  Future<void> refreshData() async {
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    await versesProvider.loadUserData();
    versesProvider.loadVerses(widget.bookIndex, widget.bookName, versionName: versionProvider.selectedOption.toLowerCase().split(' ')[0]);
  }

  @override
  initState() {
    eventBus.on().listen((event) {
      if(event == 'Refresh') {
        refreshData();
      }
    });
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    initialVerse = widget.verseNumber;
    allVersesTextSpan = [];
    if(versesProvider.currentBook != widget.bookName) {
      versesProvider.currentBook = widget.bookName;
      versesProvider.getReadChapters(bookName: widget.bookName, qtdChapters: _chapters);
    }
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if(themeProvider.themeMode == null) {
      themeProvider.getThemeMode();
    }
    _pageController = PageController(initialPage: _chapter - 1);
    super.initState();
  }

  @override
  dispose() {
    _pageController.dispose();
    eventBus.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VersesAppBar(
        bookName: widget.bookName,
        abbrev: widget.abbrev,
        bookIndex: widget.bookIndex,
        chapter: _chapter,
        chapters: _chapters,
        itemPositionsListener: itemPositionsListener,
      ),
      body: Consumer<VersesProvider>(
        builder: (context, value, _) {
          if((value.allVerses?.isEmpty ?? true) || value.allVerses![widget.chapter] == null) {
            return const LoadingWidget();
          }
          return PageView.builder(
            controller: _pageController,
            itemCount: _chapters,
            itemBuilder: (BuildContext context, int i) {
              return VersesWidget(
                bookName: widget.bookName,
                abbrev: widget.abbrev,
                bookIndex: widget.bookIndex,
                chapters: widget.chapters,
                chapter: i + 1,
                verseColors: verseColor,
                listVerses: value.allVerses!,
                readingPlan: widget.readingPlan,
                itemPositionsListener: itemPositionsListener,
                eventBus: eventBus,
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
      ),
      floatingActionButton: Consumer<VersesProvider>(
        builder: (context, item, child) {
          return VersesFloatingActionButton(
            bookName: widget.bookName,
            chapter: _chapter,
            chapters: _chapters,
            verses: item.allVerses?[_chapter] ?? [],
            pageController: _pageController,
            readingPlan: widget.readingPlan,
          );
        },
      ),
    );
  }
}