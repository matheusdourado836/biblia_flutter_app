import 'package:biblia_flutter_app/models/book.dart';
import 'package:biblia_flutter_app/models/chapter.dart';
import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:biblia_flutter_app/helpers/progress_dialog.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/select_versions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../data/verses_provider.dart';
import '../../../data/version_provider.dart';
import '../../../helpers/version_to_name.dart';

class VersesAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String bookName;
  final String abbrev;
  final int chapters;
  final int bookIndex;
  final int chapter;
  final ItemPositionsListener itemPositionsListener;

  const VersesAppBar({
    super.key,
    required this.bookName,
    required this.abbrev,
    required this.chapters,
    required this.bookIndex,
    required this.chapter,
    required this.itemPositionsListener
  });

  @override
  State<VersesAppBar> createState() => _VersesAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _VersesAppBarState extends State<VersesAppBar> {
  final start = ValueNotifier(false);
  bool isSearching = false;
  late VersesProvider _versesProvider;

  @override
  void initState() {
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    super.initState();
  }

  void toggleSearch() {
    setState(() {
      allVersesTextSpan = [];
      isSearching = !isSearching;
    });
    start.value = !start.value;
    if (!isSearching) {
      _versesProvider.resetVersesFoundCounter();
      if(_versesProvider.bottomSheetOpened) {
        Navigator.pop(context);
        _versesProvider.clearSelectedVerses(_versesProvider.allVerses![widget.chapter]);
        _versesProvider.openBottomSheet(false);
      }
      setState(() {
        listVerses = [];
        textEditingController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double dx = (width - width * .2) * -1;
    return AppBar(
      titleSpacing: 0,
      leadingWidth: 85,
      toolbarHeight: kToolbarHeight + 20,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(right: 32.0),
        child: IconButton(
          onPressed: (() {
            if(_versesProvider.bottomSheetOpened) {
              Navigator.pop(context);
            }
            _versesProvider
                .clearSelectedVerses(_versesProvider.allVerses![widget.chapter]);
            _versesProvider.resetVersesFoundCounter();
            setState(() {
              textEditingController.text = '';
              listVerses = [];
            });
            _versesProvider.refresh();
            Navigator.pop(context);
          }),
          icon: Icon(Icons.adaptive.arrow_back),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              height: 30,
              width: width * .4,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)),
              child: InkWell(
                onTap: (() {
                  Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                }),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: Text(widget.bookName),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 30,
            width: width * 0.1,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
            ),
            child: InkWell(
              onTap: () {
                _versesProvider.refresh();
                _versesProvider.clearSelectedVerses(_versesProvider.allVerses![widget.chapter]);
                Navigator.pushNamed(context, 'chapter_screen',
                  arguments: {
                    'bookName': widget.bookName,
                    'abbrev': widget.abbrev,
                    'bookIndex': widget.bookIndex,
                    'chapters': widget.chapters
                  });
              },
              child: Center(child: Text(widget.chapter.toString())),
            ),
          ),
          Flexible(
            child: Container(
              height: 30,
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                ),
              ),
              child: Consumer<VersionProvider>(
                builder: (context, value, _) {
                  final theme = Theme.of(context);
                  final textStyle = theme.textTheme.titleSmall!.copyWith(fontSize: 12);

                  List<DropdownMenuItem<String>> buildDropdownItems() {
                    final options = value.options;
                    return options.map((option) {
                      final isDownloaded = value.getDownloadedVersion(versionToName(option));

                      Widget content = isDownloaded && option != 'Multi versão'
                          ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: textStyle.copyWith(
                                color: textStyle.color?.withAlpha(128),
                              ),
                            ),
                          ),
                          const Icon(Icons.download, size: 16),
                        ],
                      )
                          : Center(child: Text(option, style: textStyle));

                      return DropdownMenuItem(
                        value: option,
                        child: content,
                      );
                    }).toList();
                  }

                  return DropdownButton<String>(
                    underline: const SizedBox.shrink(),
                    style: theme.dropdownMenuTheme.textStyle,
                    isExpanded: true,
                    itemHeight: 110.0,
                    value: value.selectedOption,
                    items: buildDropdownItems(),
                    onChanged: (newValue) async {
                      if (newValue == null) return;
                      if(newValue == 'Multi versão') {
                        final book = BookFull(
                          bookIndex: widget.bookIndex,
                          abbrev: widget.abbrev,
                          chapter: widget.chapter,
                          chapters: List.generate(widget.chapters, (i) => Chapter(verses: [])),
                          name: widget.bookName,
                          verseNumber: 1
                        );
                        showDialog(
                          context: context,
                          builder: (context) => SelectVersionsDialog(book: book)
                        );
                        return;
                      }

                      final versionKey = newValue.split(' ')[0].toLowerCase();
                      final versionRaw = newValue.split(' ')[0];
                      final isDownloaded = value.getDownloadedVersion(versionToName(newValue));

                      void handleVersionChange() {
                        if (_versesProvider.bottomSheetOpened) {
                          Navigator.pop(context);
                          _versesProvider.openBottomSheet(false);
                        }

                        _versesProvider.resetVersesFoundCounter();
                        setState(() {
                          listVerses = [];
                          initialVerse = widget.itemPositionsListener.itemPositions.value.first.index + 1;
                        });

                        value.changeVersion(newValue);
                      }

                      void loadVerses() {
                        _versesProvider.clear();
                        _versesProvider.loadVerses(
                          widget.bookIndex,
                          widget.bookName,
                          versionName: versionKey,
                        );
                      }

                      if (isDownloaded) {
                        final result = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => ProgressDialog(
                            versionName: versionToName(newValue),
                            versionNameRaw: versionRaw,
                          ),
                        );

                        if (result ?? false) {
                          handleVersionChange();
                          loadVerses();
                        }
                      } else {
                        handleVersionChange();
                        loadVerses();
                      }
                    },
                    selectedItemBuilder: (_) => value.options.map(
                      (v) => Center(
                        child: Text(v.toUpperCase().split(' ')[0]),
                      )
                    ).toList(),
                  );
                },
              ),
            ),
          )
        ],
      ).animate(target: start.value ? 1 : 0).fadeOut(duration: 1300.ms),
      actions: [
        if(isSearching)
          SearchingVerse(function: toggleSearch, chapter: widget.chapter)
            .animate(target: start.value ? 1 : 0)
            .fadeIn(duration: 1300.ms),
        ValueListenableBuilder(
          valueListenable: start,
          builder: (context, started, _) => IconButton(
            icon: const Icon(Icons.search),
            onPressed: toggleSearch,
          )
          .animate(target: started ? 1 : 0)
          .rotate(duration: 1300.ms)
          .moveX(
            begin: 0,
            end: dx,
            curve: Curves.easeInOut,
            duration: 1300.ms,
          )
        ),
      ],
    );
  }
}
