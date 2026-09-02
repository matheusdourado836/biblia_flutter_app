import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/models/book.dart';
import 'package:biblia_flutter_app/screens/multi_version_screen/add_version_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../data/bible_data.dart';
import '../../data/theme_provider.dart';
import '../../data/verses_provider.dart';
import '../../helpers/progress_dialog.dart';
import '../../models/chapter.dart';
import '../../themes/theme_colors.dart';
import '../verses_screen/widgets/verse_area.dart';

class MultiVersionScreen extends StatefulWidget {
  final BookFull book;
  final String verision1;
  final String verision2;
  const MultiVersionScreen({
    super.key,
    required this.book,
    required this.verision1,
    required this.verision2
  });

  @override
  State<MultiVersionScreen> createState() => _MultiVersionScreenState();
}

class _MultiVersionScreenState extends State<MultiVersionScreen> {
  static final BibleData _bibleData = BibleData();
  late final PageController _pageController;
  late final versesProvider = Provider.of<VersesProvider>(context, listen: false);
  List<String> _downloadedVersions = [];
  final ScrollController sharedScrollController = ScrollController();
  List<List<Chapter>> _versions = [];
  int _chapter = 0;
  final List<List<ItemScrollController>> _itemsControllers = [];
  final List<List<ItemPositionsListener>> _itemsListeners = [];

  Future<void> loadVersions() async {
    // Com o carregamento sob demanda, as duas versões precisam estar em
    // memória antes de montar as colunas.
    await _bibleData.ensureVersionsLoaded(
      [versionToName(widget.verision1), versionToName(widget.verision2)],
    );
    if (!mounted) return;
    final version1 = versesProvider.loadVerses(widget.book.bookIndex ?? 0, widget.book.name ?? '', versionName: widget.verision1, forMultiVersion: true);
    final versionMapped = version1.entries.map((entry) => Chapter.fromJson(entry.value)).toList();
    final version2 = versesProvider.loadVerses(widget.book.bookIndex ?? 0, widget.book.name ?? '', versionName: widget.verision2, forMultiVersion: true);
    final version2Mapped = version2.entries.map((entry) => Chapter.fromJson(entry.value)).toList();

    setState(() {
      _versions = [versionMapped, version2Mapped];
      for(int i = 0; i < (widget.book.chapters?.length ?? 0); i++) {
        _itemsControllers.add(List.generate(_versions.length, (_) => ItemScrollController()));
        _itemsListeners.add(List.generate(_versions.length, (_) => ItemPositionsListener.create()));
      }
    });
  }

  Future<void> addVersion() async {
    final version = await showDialog(context: context, builder: (context) => const AddVersionDialog());
    if (!mounted) return;
    if(version != null && version is String) {
      if(!_downloadedVersions.contains(versionToName(version))) {
        final versionProvider = Provider.of<VersionProvider>(context, listen: false);
        final res = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ProgressDialog(
            versionName: versionToName(version),
            versionNameRaw: version,
          ),
        );
        if(res != true) return;
        await versionProvider.loadBibleData();
      }
      await _bibleData.ensureVersionLoaded(versionToName(version));
      if (!mounted) return;
      final chapters = versesProvider.loadVerses(widget.book.bookIndex ?? 0, widget.book.name ?? '', versionName: version, forMultiVersion: true);
      final chaptersMapped = chapters.entries.map((entry) => Chapter.fromJson(entry.value)).toList();
      setState(() {
        _versions.add(chaptersMapped);
        _itemsControllers[_chapter - 1].add(ItemScrollController());
        _itemsListeners[_chapter - 1].add(ItemPositionsListener.create());
      });
    }
  }
  
  void goToIndex(int index) {
    for(var c in _itemsControllers[_chapter - 1]) {
      if(c.isAttached) {
        c.scrollTo(index: index, duration: const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void initState() {
    _downloadedVersions = _bibleData.downloadedVersions;
    _pageController = PageController(initialPage: (widget.book.chapter ?? 0) - 1);
    _chapter = widget.book.chapter ?? 1;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadVersions());
    super.initState();
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${widget.book.name ?? ''} $_chapter'),
        actions: [
          IconButton(
            onPressed: addVersion,
            icon: const Icon(Icons.add)
          )
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.book.chapters?.length ?? 0,
        itemBuilder: (context, i) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ..._versions.map((v) => Expanded(
                      child: _VerseWidget(
                        book: widget.book,
                        chapter: v[i],
                        version: nameToVersion(v[i].verses.first.version!).toUpperCase(),
                        itemScrollController: _itemsControllers[i][_versions.indexWhere((element) => element[i].verses.first.version == v[i].verses.first.version)],
                        itemPositionsListener: _itemsListeners[i][_versions.indexWhere((element) => element[i].verses.first.version == v[i].verses.first.version)],
                        removeVersion: () {
                          final version = v[i].verses.first.version;
                          setState(() {
                            _versions.removeWhere((element) => element[i].verses.first.version == version);
                            _itemsControllers[i].removeLast();
                            _itemsListeners[i].removeLast();
                          });
                          if(_versions.isEmpty) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                child: ListView.builder(
                  itemCount: _versions.firstOrNull?[_chapter - 1].verses.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => goToIndex(index),
                      child: Container(
                        height: 50,
                        width: 25,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                          borderRadius: BorderRadiusDirectional.circular(8)
                        ),
                        child: Text((index + 1).toString(), style: TextStyle(color: Theme.of(context).buttonTheme.colorScheme?.onSurface),),
                      ),
                    );
                  }
                ),
              )
            ],
          );
        },
        onPageChanged: (page) {
          setState(() => _chapter = page + 1);
        },
      ),
    );
  }
}

class _VerseWidget extends StatefulWidget {
  final BookFull book;
  final Chapter chapter;
  final String version;
  final ItemPositionsListener itemPositionsListener;
  final ItemScrollController itemScrollController;
  final Function() removeVersion;
  const _VerseWidget({
    required this.book,
    required this.chapter,
    required this.version,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.removeVersion,
  });

  @override
  State<_VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<_VerseWidget> {
  final ThemeColors themeColors = ThemeColors();
  final EventBus eventBus = EventBus();
  bool isOn = false;

  @override
  void initState() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    isOn = themeProvider.isOn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12.0),
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: .6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.version, style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: widget.removeVersion, icon: const Icon(Icons.delete))
            ],
          ),
        ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: widget.itemScrollController,
            itemPositionsListener: widget.itemPositionsListener,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: widget.chapter.verses.length,
            itemBuilder: (context, index) {
              final verse = widget.chapter.verses[index];
              final bool isSelected = verse.isSelected ?? false;
              final Color verseColor = isSelected ? theme.highlightColor : verse.verseColor ?? Colors.transparent;
              final bool isHighlighted = verseColor == theme.highlightColor;
              final textOnColoredBackground = isHighlighted ? themeColors.coloredVerse(isOn) : themeColors.coloredVerse(true);
              final textStyle = (verseColor == Colors.transparent) ? themeColors.verseColor(isOn) : textOnColoredBackground;
              final List<TextSpan> versesDefault = [TextSpan(text: verse.text, style: textStyle)];

              final verseWidget = InkWell(
                onTap: () {},
                child: isOn
                    ? VerseArea(
                        chapter: widget.book.chapter ?? 0,
                        verseNumber: verse.verseNumber ?? 0,
                        verse: versesDefault,
                        verseColor: verseColor,
                        annotation: verse.annotation,
                        eventBus: eventBus,
                      )
                    : VerseAreaDark(
                        chapter: widget.book.chapter ?? 0,
                        verseNumber: verse.verseNumber ?? 0,
                        verse: versesDefault,
                        verseColor: verseColor,
                        annotation: verse.annotation,
                        eventBus: eventBus,
                      ),
              );

              return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: verseWidget
              );
            },
          ),
        ),
        // Expanded(
        //   child: ListView.builder(
        //     controller: widget.scrollController,
        //     physics: const BouncingScrollPhysics(),
        //     padding: const EdgeInsets.all(8.0),
        //     itemCount: widget.chapter.verses.length,
        //     itemBuilder: (context, index) {
        //       final verse = widget.chapter.verses[index];
        //       final bool isSelected = verse.isSelected ?? false;
        //       final Color verseColor = isSelected ? theme.highlightColor : verse.verseColor ?? Colors.transparent;
        //       final bool isHighlighted = verseColor == theme.highlightColor;
        //       final textOnColoredBackground = isHighlighted ? themeColors.coloredVerse(isOn) : themeColors.coloredVerse(true);
        //       final textStyle = (verseColor == Colors.transparent) ? themeColors.verseColor(isOn) : textOnColoredBackground;
        //       final List<TextSpan> versesDefault = [TextSpan(text: verse.text, style: textStyle)];
        //
        //       final verseWidget = InkWell(
        //         onTap: () {},
        //         child: isOn
        //             ? VerseArea(
        //           chapter: widget.book.chapter ?? 0,
        //           verseNumber: verse.verseNumber ?? 0,
        //           verse: versesDefault,
        //           verseColor: verseColor,
        //           annotation: verse.annotation,
        //         )
        //             : VerseAreaDark(
        //           chapter: widget.book.chapter ?? 0,
        //           verseNumber: verse.verseNumber ?? 0,
        //           verse: versesDefault,
        //           verseColor: verseColor,
        //           annotation: verse.annotation,
        //         ),
        //       );
        //
        //       return Padding(
        //         padding: const EdgeInsets.all(2.0),
        //         child: verseWidget
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
