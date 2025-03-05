import 'dart:io';
import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verse_area.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';
import '../../../data/bible_data_controller.dart';
import '../../../data/chapters_provider.dart';
import '../../../models/annotation.dart';
import '../../../models/daily_read.dart';
import '../verses_screen.dart';

ItemScrollController? itemScrollController;
DailyRead? dailyRead;
bool isLastDay = false;

class VersesWidget extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapters;
  final int chapter;
  final String verseColors;
  final bool? readingPlan;
  final Map<int, dynamic> listVerses;
  final ItemPositionsListener itemPositionsListener;

  const VersesWidget({
    super.key,
    required this.bookName,
    required this.abbrev,
    required this.bookIndex,
    required this.chapters,
    required this.chapter,
    required this.verseColors,
    required this.listVerses,
    this.readingPlan,
    required this.itemPositionsListener
  });

  @override
  State<VersesWidget> createState() => _VersesWidgetState();
}

class _VersesWidgetState extends State<VersesWidget> {
  List<Map<String, dynamic>> listMap = [];
  final ThemeColors themeColors = ThemeColors();
  final BibleDataController bibleDataController = BibleDataController();
  int _chapter = 1;
  PlansProvider? _planProvider;
  late VersesProvider _versesProvider;
  bool _isChapterRead = false;

  Future<void> setChapterRead() async {
    setState(() => _isChapterRead = !_isChapterRead);
    final chaptersProvider = Provider.of<ChaptersProvider>(context, listen: false);
    await chaptersProvider.setChapterRead(widget.bookName, widget.chapter.toString(), widget.chapters, _isChapterRead);
    _versesProvider.readChapters[widget.chapter - 1] = _isChapterRead;
  }

  @override
  void initState() {
    if(widget.readingPlan != null) {
      _planProvider = Provider.of<PlansProvider>(context, listen: false);
      dailyRead = _planProvider!.dailyReads.firstWhere((element) => element.chapter == '${widget.bookName} ${widget.chapter}');
      isLastDay = _planProvider!.dailyReadsGrouped[_planProvider!.dailyReadsGrouped.length - 2].contains(dailyRead);
    }
    _chapter = widget.chapter;
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    itemScrollController = ItemScrollController();
    super.initState();
  }

  @override
  void dispose() {
    itemScrollController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isChapterRead = _versesProvider.readChapters.isEmpty ? false : _versesProvider.readChapters[_chapter - 1];
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    listMap = widget.listVerses[_chapter]
        .where((verse) => verse["verse"].toString().isNotEmpty)
        .toList();

    return Consumer<ThemeProvider>(
      builder: (context, themeValue, _) {
        return ScrollablePositionedList.builder(
          initialScrollIndex: initialVerse - 1,
          itemScrollController: itemScrollController,
          itemPositionsListener: widget.itemPositionsListener,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          itemCount: listMap.length,
          itemBuilder: (context, index) {
            final verseItem = listMap[index];
            final bool isSelected = verseItem["isSelected"];
            final Color verseColor = isSelected ? theme.highlightColor : verseItem["verseColor"];
            final bool isHighlighted = verseColor == theme.highlightColor;
            final textOnColoredBackground = isHighlighted ? themeColors.coloredVerse(themeValue.isOn) : themeColors.coloredVerse(true);
            final textStyle = (verseColor == Colors.transparent) ? themeColors.verseColor(themeValue.isOn) : textOnColoredBackground;
            final List<TextSpan> versesDefault = allVersesTextSpan.isEmpty
                ? [TextSpan(text: verseItem["verse"], style: textStyle)]
                : allVersesTextSpan[index][index + 1];

            final verseWidget = InkWell(
              onTap: () => onTap(index),
              child: themeValue.themeMode == ThemeMode.light
                ? VerseArea(
                    chapter: _chapter,
                    verseNumber: verseItem["verseNumber"],
                    verse: versesDefault,
                    verseColor: verseColor,
                    annotation: verseItem["annotation"],
                  )
                : VerseAreaDark(
                    chapter: _chapter,
                    verseNumber: verseItem["verseNumber"],
                    verse: versesDefault,
                    verseColor: verseColor,
                    annotation: verseItem["annotation"],
                  ),
            );

            if ((index + 1) == listMap.length) {
              return Column(
                children: [
                  verseWidget,
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 180),
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.readingPlan == null) {
                          setChapterRead();
                        } else {
                          final currentPlan = PlanType.fromCode(dailyRead!.progressId!);
                          dailyRead!.completed = dailyRead!.completed == 1 ? 0 : 1;
                          _planProvider!.markChapter(
                            dailyRead!.chapter!,
                            read: dailyRead!.completed!,
                            progressId: dailyRead!.progressId!,
                            update: true,
                          );
                          _planProvider!.checkIfCompletedDailyRead(
                            planId: dailyRead!.progressId!,
                            qtdChapterRequired: planTypeToChapters(planType: currentPlan, lastDay: isLastDay ? true : null),
                          );
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.surface,
                        fixedSize: Size(screenWidth * .85, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.readingPlan == null
                          ? (_isChapterRead ? 'Desmarcar como lido' : 'Marcar como lido')
                          : (dailyRead!.completed == 1 ? 'Desmarcar leitura diária' : 'Marcar leitura diária'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: verseWidget
            );
          },
        );
      },
    );
  }

  void onTap(int index) {
    final isSelected = !listMap[index]["isSelected"];
    final verseColor = listMap[index]["verseColor"];
    final bool isEditing = verseColor != Colors.transparent;

    Widget colorContainer(BuildContext ctx, Color themeColor, String colorString) => InkWell(
      onTap: (() {
        _versesProvider.openBottomSheet(false);
        if (listMap[index]["verseColor"] != Colors.transparent) {
          setState(() => listMap[index]["isEditing"] = true);
        }
        _versesProvider.updateColors(listMap, themeColor, colorString);
        _versesProvider.refresh();
        Navigator.pop(ctx);
      }),
      child: RoundContainer(color: themeColor),
    );

    if(listMap.where((element) => element["isSelected"]).isEmpty) {
      _versesProvider.openBottomSheet(true);
      showBottomSheet(
        context: context,
        enableDrag: false,
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        builder: (BuildContext ctx) {
          return Padding(
            padding: (Platform.isIOS) ? const EdgeInsets.only(bottom: 32) : EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => _versesProvider.shareVerses(
                        listMap.where((element) => element["isSelected"]).toList(),
                        widget.bookName,
                        _chapter
                      ),
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: () => _versesProvider.copyVerses(
                        listMap.where((element) => element["isSelected"]).toList(),
                        widget.bookName,
                        _chapter
                      ),
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final verses = listMap.where((element) => element["isSelected"]).toList();
                        if(verses.length > 5) {
                          showCustomSnackBar(child: const Text('Selecione até no máximo 5 versículos'));
                          _versesProvider.openBottomSheet(false);
                          _versesProvider.clearSelectedVerses(listMap);
                          return;
                        }
                        bibleDataController.getStartAndEndIndex(listMap);
                        Navigator.pushNamed(
                          context, 'verse_with_background',
                          arguments: {
                            "bookName": listMap[index]["bookName"],
                            "chapter": widget.chapter,
                            "verseStart": listMap[index]["verseNumber"],
                            "verseEnd": bibleDataController.endIndex,
                            "content": listMap.where((element) => element["isSelected"]).toList()
                          });
                        _versesProvider.openBottomSheet(false);
                        _versesProvider.clearSelectedVerses(listMap);
                      },
                      icon: const Icon(Icons.photo_outlined),
                    ),
                    IconButton(
                      onPressed: () {
                        final List<dynamic> verses = listMap.map((element) => element["verse"]).toList();
                        bibleDataController.getStartAndEndIndex(listMap);
                        Annotation innerAnnotation = Annotation(
                          annotationId: const Uuid().v1(),
                          title:
                          '${widget.bookName} ${widget.chapter}:${index + 1}',
                          content: '',
                          book: widget.bookName,
                          chapter: widget.chapter,
                          verseStart: bibleDataController.startIndex,
                          verseEnd: bibleDataController.endIndex
                        );
                        bibleDataController.verifyAnnotationExists(widget.bookName, widget.chapter, bibleDataController.endIndex)
                          .then((value) {
                            final annotation = value?[0] ?? innerAnnotation;
                            Navigator.pushNamed(
                              context, 'annotation_widget',
                              arguments: {
                                'annotation': annotation,
                                'verses': verses,
                                'isEditing': value != null
                              });
                          });
                      },
                      icon: const Icon(Icons.edit_rounded),
                    ),
                    IconButton(
                      onPressed: (listMap[index]["verseColor"] != Colors.transparent) ? (() {
                        _versesProvider.openBottomSheet(false);
                        _versesProvider.deleteVerses(listMap);
                        Navigator.pop(ctx);
                      }) : null,
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: (() {
                        _versesProvider.clearSelectedVerses(listMap);
                        _versesProvider.openBottomSheet(false);
                        Navigator.pop(ctx);
                      }),
                      icon: const Icon(Icons.minimize),
                    ),
                  ],
                ),
                const Divider(thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    colorContainer(ctx, ThemeColors.color2, ThemeColors.colorString2),
                    colorContainer(ctx, ThemeColors.color3, ThemeColors.colorString3),
                    colorContainer(ctx, ThemeColors.color4, ThemeColors.colorString4),
                    colorContainer(ctx, ThemeColors.color5, ThemeColors.colorString5),
                    colorContainer(ctx, ThemeColors.color6, ThemeColors.colorString6),
                    colorContainer(ctx, ThemeColors.color7, ThemeColors.colorString7),
                    colorContainer(ctx, ThemeColors.color8, ThemeColors.colorString8),
                    colorContainer(ctx, ThemeColors.color1, ThemeColors.colorString1),
                    const SizedBox(height: 70),
                  ],
                ),
              ],
            ),
          );
        });
    }else if(listMap.where((element) => element["isSelected"]).length == 1 && !isSelected) {
      _versesProvider.openBottomSheet(false);
      Navigator.pop(context);
    }

    setState(() {
      listMap[index]["isSelected"] = isSelected;
      listMap[index]["isEditing"] = isEditing;
    });
  }
}