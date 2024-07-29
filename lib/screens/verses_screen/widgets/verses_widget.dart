import 'dart:io';
import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/data/plans_provider.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/chapter_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/searching_verse.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verse_area.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';
import '../../../data/bible_data_controller.dart';
import '../../../models/annotation.dart';
import '../../../models/daily_read.dart';
import '../verses_screen.dart';

ItemScrollController? itemScrollController;
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
bool isChapterRead = false;
DailyRead? dailyRead;
bool isLastDay = false;

class VersesWidget extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapter;
  final String verseColors;
  final bool? readingPlan;
  final Map<int, dynamic> listVerses;

  const VersesWidget({
    super.key,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verseColors,
    required this.bookIndex, required this.listVerses,
    this.readingPlan,
  });

  @override
  State<VersesWidget> createState() => _VersesWidgetState();
}

class _VersesWidgetState extends State<VersesWidget> {
  List<Map<String, dynamic>> listMap = [];
  final ThemeColors themeColors = ThemeColors();
  final BibleDataController bibleDataController = BibleDataController();
  final BooksDao booksDao = BooksDao();
  int _chapter = 1;
  PlansProvider? _planProvider;
  late VersesProvider _versesProvider;

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
    booksDao.findByChapter(widget.bookName).then((value) => {
      for(var element in value['chapters']) {
        if(element[_chapter.toString()] == true) {
          setState(() {
            isChapterRead = true;
          })
        }
      },
    });
    super.initState();
  }

  @override
  void dispose() {
    itemPositionsListener;
    itemScrollController;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listMap = widget.listVerses[_chapter];
    listMap.removeWhere((verse) => verse["verse"].isEmpty);
    return Consumer<ThemeProvider>(
      builder: (context, themeValue, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ScrollablePositionedList.builder(
            initialScrollIndex: initialVerse - 1,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            physics: const BouncingScrollPhysics(),
            itemCount: listMap.length,
            itemBuilder: (BuildContext context, int index) {
              final Color verseColor = (listMap[index]["isSelected"]) ? Theme.of(context).highlightColor : listMap[index]["verseColor"];
              final textOnColoredBackground = (verseColor == Theme.of(context).highlightColor) ? themeColors.coloredVerse(themeValue.isOn) : themeColors.coloredVerse(true);
              final textStyle = (verseColor == Colors.transparent) ? themeColors.verseColor(themeValue.isOn) : textOnColoredBackground;
              final List<TextSpan> versesDefault = (allVersesTextSpan.isEmpty) ? [TextSpan(text: listMap[index]["verse"], style: textStyle)] : allVersesTextSpan[index][index + 1];
              if ((index + 1) == listMap.length) {
                return Column(
                  children: [
                    InkWell(
                      onTap: (() {
                        onTap(context, index);
                      }),
                      child: VerseArea(
                        chapter: _chapter,
                        verseNumber: listMap[index]["verseNumber"],
                        verse: versesDefault,
                        verseColor: verseColor,
                        annotation: listMap[index]["annotation"],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 180),
                      child: ElevatedButton(
                        onPressed: (() {
                          if(widget.readingPlan == null) {
                            if(!isChapterRead) {
                              chaptersProvider.saveChapter(widget.bookName, _chapter.toString());
                            } else {
                              chaptersProvider.deleteChapter(widget.bookName, _chapter.toString());
                            }
                            setState(() => isChapterRead = !isChapterRead);
                          }else {
                            final currentPlan = PlanType.fromCode(dailyRead!.progressId!);
                            dailyRead!.completed == 1 ? dailyRead!.completed = 0 : dailyRead!.completed = 1;
                            _planProvider!.markChapter(dailyRead!.chapter!, read: dailyRead!.completed!, progressId: dailyRead!.progressId!, update: true);
                            _planProvider!.checkIfCompletedDailyRead(planId: dailyRead!.progressId!, qtdChapterRequired: planTypeToChapters(planType: currentPlan, lastDay: isLastDay ? true : null));
                            setState(() {});
                          }
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.surface,
                            fixedSize: Size(MediaQuery.of(context).size.width * .85, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        child: (widget.readingPlan == null)
                            ? Text((isChapterRead) ? 'Desmarcar como lido' : 'Marcar como lido', style: const TextStyle(color: Colors.white))
                            : Text((dailyRead!.completed == 1) ? 'Desmarcar leitura diária' : 'Marcar leitura diária', style: const TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                  onTap: (() => onTap(context, index)),
                  child: VerseArea(
                    chapter: _chapter,
                    verseNumber: listMap[index]["verseNumber"],
                    verse: versesDefault,
                    verseColor: verseColor,
                    annotation: listMap[index]["annotation"],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void onTap(BuildContext context, int index) {
    final isSelected = !listMap[index]["isSelected"];
    final verseColor = listMap[index]["verseColor"];
    final bool isEditing = verseColor != Colors.transparent;

    if(listMap.where((element) => element["isSelected"]).isEmpty) {
      _versesProvider.openBottomSheet(true);
      showBottomSheet(
          context: context,
          enableDrag: false,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
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
                        onPressed: (() {
                          _versesProvider.shareVerses(context, listMap, widget.bookName);
                        }),
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: (() {
                          _versesProvider.copyVerses(listMap);
                        }),
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                          final verses = listMap.where((element) => element["isSelected"]).toList();
                          if(verses.length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Selecione até o máximo de 5 versículos', textAlign: TextAlign.center)
                                )
                            );
                            _versesProvider.openBottomSheet(false);
                            _versesProvider.clearSelectedVerses(listMap);
                            return;
                          }
                          bibleDataController.getStartAndEndIndex(listMap, listMap[index]["verseNumber"]);
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
                        }),
                        icon: const Icon(Icons.photo_outlined),
                      ),
                      IconButton(
                        onPressed: (() {
                          final List<dynamic> verses = [];
                          for(var element in listMap) {
                            verses.add(element['verse']);
                          }
                          bibleDataController.getStartAndEndIndex(listMap, listMap[index]["verseNumber"]);
                          Annotation innerAnnotation = Annotation(
                              annotationId: const Uuid().v1(),
                              title:
                              '${widget.bookName} ${widget.chapter}:${index + 1}',
                              content: '',
                              book: widget.bookName,
                              chapter: widget.chapter,
                              verseStart: bibleDataController.startIndex,
                              verseEnd: bibleDataController.endIndex);
                          bibleDataController.verifyAnnotationExists(widget.bookName, widget.chapter, bibleDataController.endIndex)
                              .then((value) => {
                            if (value != null) {
                              innerAnnotation = value[0],
                              Navigator.pushNamed(
                                  context, 'annotation_widget',
                                  arguments: {
                                    'annotation': innerAnnotation,
                                    'verses': verses,
                                    'isEditing': true
                                  })
                            }
                            else {
                              Navigator.pushNamed(
                                  context, 'annotation_widget',
                                  arguments: {
                                    'annotation': innerAnnotation,
                                    'verses': verses,
                                    'isEditing': false
                                  })
                            },
                          });
                        }),
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
                  const Divider(
                    thickness: 1.5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color2, ThemeColors.colorString2);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color2),
                      ),
                      InkWell(
                          onTap: (() {
                            setState(() {
                              _versesProvider.openBottomSheet(false);
                              if (listMap[index]["verseColor"] !=
                                  Colors.transparent) {
                                listMap[index]["isEditing"] = true;
                              }
                              _versesProvider.updateColors(listMap,
                                  ThemeColors.color3, ThemeColors.colorString3);
                            });
                            _versesProvider.refresh();
                            Navigator.pop(ctx);
                          }),
                          child: RoundContainer(color: ThemeColors.color3)),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color4, ThemeColors.colorString4);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: const RoundContainer(color: Colors.brown),
                      ),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color5, ThemeColors.colorString5);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color5),
                      ),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color6, ThemeColors.colorString6);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color6),
                      ),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color7, ThemeColors.colorString7);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color7),
                      ),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color8, ThemeColors.colorString8);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color8),
                      ),
                      InkWell(
                        onTap: (() {
                          setState(() {
                            _versesProvider.openBottomSheet(false);
                            if (listMap[index]["verseColor"] !=
                                Colors.transparent) {
                              listMap[index]["isEditing"] = true;
                            }
                            _versesProvider.updateColors(listMap,
                                ThemeColors.color1, ThemeColors.colorString1);
                          });
                          _versesProvider.refresh();
                          Navigator.pop(ctx);
                        }),
                        child: RoundContainer(color: ThemeColors.color1),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
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