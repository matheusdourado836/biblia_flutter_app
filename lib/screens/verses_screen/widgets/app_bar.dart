import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:biblia_flutter_app/helpers/progress_dialog.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../data/verses_provider.dart';
import '../../../data/version_provider.dart';
import '../../../helpers/version_to_name.dart';
import 'verses_widget.dart';

class VersesAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String bookName;
  final String abbrev;
  final int chapters;
  final int bookIndex;
  final int chapter;

  const VersesAppBar(
      {super.key,
      required this.bookName,
      required this.abbrev,
      required this.chapters,
      required this.bookIndex,
      required this.chapter});

  @override
  State<VersesAppBar> createState() => _VersesAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _VersesAppBarState extends State<VersesAppBar> {
  final GlobalKey containerKey = GlobalKey();
  final start = ValueNotifier(false);
  bool isSearching = false;
  late VersesProvider _versesProvider;
  double position = 0;

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
                Navigator.pushNamedAndRemoveUntil(context, 'chapter_screen', (route) => false,
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
              constraints: const BoxConstraints(
                maxWidth: 250
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
              ),
              child: Consumer<VersionProvider>(
                builder: (context, value, _) {
                  return DropdownButton(
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    isExpanded: true,
                    itemHeight: 120.0,
                    value: value.selectedOption,
                    items: value.options.map((option) {
                      value.setListItem(option.split(' ')[0]);
                      if(value.getDownloadedVersion(versionToName(option))) {
                        final versionName = option.toLowerCase().split(' ')[0];
                        final versionNameRaw = option.split(' ')[0];
                        return DropdownMenuItem(
                          value: option,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => ProgressDialog(versionName: versionToName(option), versionNameRaw: versionNameRaw,))
                                  .then((res) {
                                    if(res ?? false) {
                                      if (_versesProvider.bottomSheetOpened) {
                                        Navigator.pop(context);
                                        _versesProvider.openBottomSheet(false);
                                      }
                                      _versesProvider.resetVersesFoundCounter();
                                      setState(() {
                                        listVerses = [];
                                        initialVerse = itemPositionsListener.itemPositions.value.first.index + 1;
                                      });
                                      value.changeVersion(option);
                                      value.loadBibleData().whenComplete(() {
                                        _versesProvider.clear();
                                        _versesProvider.loadVerses(widget.bookIndex, widget.bookName, versionName: versionName);
                                        Navigator.pop(context);
                                      });
                                    }
                                });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12, color: Theme.of(context).textTheme.titleSmall!.color!.withOpacity(.5)),
                                  ),
                                ),
                                const Icon(Icons.download, size: 16,)
                              ],
                            ),
                          ),
                        );
                      }
                      return DropdownMenuItem(
                        value: option,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 4, right: 4),
                          child: Center(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12),
                              )
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      final versionName = newValue!.toLowerCase().split(' ')[0];
                      if (_versesProvider.bottomSheetOpened) {
                        Navigator.pop(context);
                        _versesProvider.openBottomSheet(false);
                      }
                      _versesProvider.resetVersesFoundCounter();
                      setState(() {
                        listVerses = [];
                        initialVerse = itemPositionsListener.itemPositions.value.first.index + 1;
                      });
                      _versesProvider.clear();
                      value.changeVersion(newValue.toString());
                      _versesProvider.loadVerses(widget.bookIndex, widget.bookName, versionName: versionName);
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return value.versionsList;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ).animate(target: start.value ? 1 : 0)
          .fadeOut(duration: 1300.ms),
      actions: [
        (isSearching) ? SearchingVerse(function: toggleSearch, chapter: widget.chapter)
            .animate(target: start.value ? 1 : 0)
            .fadeIn(duration: 1300.ms) : Container(),
        ValueListenableBuilder(
            valueListenable: start,
            builder: (context, started, _) => IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: toggleSearch,
                )
                    .animate(
                      target: started ? 1 : 0,
                    )
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
