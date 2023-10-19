import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verse_area.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';
import '../../../data/bible_data_controller.dart';
import '../../../data/theme_provider.dart';
import '../../../models/annotation.dart';
import '../verses_screen.dart';

bool versesSelected = false;
late ItemScrollController itemScrollController;

class LoadingVersesWidget extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapter;
  final String verseColors;
  final Map<int, dynamic> listVerses;

  const LoadingVersesWidget({
    Key? key,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verseColors,
    required this.bookIndex, required this.listVerses,
  }) : super(key: key);

  @override
  State<LoadingVersesWidget> createState() => _LoadingVersesWidgetState();
}

class _LoadingVersesWidgetState extends State<LoadingVersesWidget> {
  List<Map<String, dynamic>> listMap = [];
  final ThemeColors themeColors = ThemeColors();
  final BibleDataController bibleDataController = BibleDataController();
  final BooksDao booksDao = BooksDao();
  bool isChapterRead = false;
  int _chapter = 1;

  late VersesProvider _versesProvider;

  @override
  void initState() {
    _chapter = widget.chapter;
    _versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
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
  Widget build(BuildContext context) {
    setState(() {
      listMap = widget.listVerses[_chapter];
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScrollablePositionedList.builder(
        initialScrollIndex: initialVerse - 1,
        itemScrollController: itemScrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: listMap.length,
        itemBuilder: (BuildContext context, int index) {
          bibleDataController.annotationExists(widget.bookName, widget.chapter, index + 1)
              .then((value) => {listMap[index]["hasAnnotation"] = value});
          listMap[index]["index"] = index;
          listMap[index]["chapter"] = _chapter;
          final Color verseColor = (listMap[index]["isSelected"]) ? Theme.of(context).highlightColor : listMap[index]["verseColor"];
          if ((index + 1) == listMap.length) {
            return Column(
              children: [
                InkWell(
                  onTap: (() {
                    onTap(context, index);
                  }),
                  child: VerseArea(
                    chapter: _chapter,
                    title: (listMap[index]["hasAnnotation"] == true)
                        ? '${widget.bookName} ${widget.chapter}:${index + 1}'
                        : null,
                    verseNumber: index + 1,
                    verse: verseTextSpan(listMap[index]["verse"].toString().toLowerCase(), verseColor, index),
                    verseColor: verseColor,
                    verseHasAnnotation:
                        (listMap[index]["hasAnnotation"] == null)
                            ? false
                            : listMap[index]["hasAnnotation"],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 180),
                  child: ElevatedButton(
                    onPressed: (() {
                      if(!isChapterRead) {
                        booksDao.saveChapter(widget.bookName, _chapter.toString());
                      } else {
                        booksDao.deleteChapter(widget.bookName, _chapter.toString());
                      }
                      setState(() {
                        isChapterRead = !isChapterRead;
                      });
                    }),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(MediaQuery.of(context).size.width * .75, 50)
                    ),
                    child: (isChapterRead) ? const Text('Desmarcar como lido') : const Text('Marcar como lido'),
                  ),
                )
              ],
            );
          }
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: InkWell(
              onTap: (() {
                onTap(context, index);
              }),
              child: VerseArea(
                chapter: _chapter,
                title: (listMap[index]["hasAnnotation"] == true)
                    ? '${widget.bookName} ${widget.chapter}:${index + 1}'
                    : null,
                verseNumber: index + 1,
                verse: verseTextSpan(listMap[index]["verse"].toString().toLowerCase(), verseColor, index),
                verseColor: verseColor,
                verseHasAnnotation: (listMap[index]["hasAnnotation"] == null)
                    ? false
                    : listMap[index]["hasAnnotation"],
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<TextSpan> verseTextSpan(String verse, Color verseColor, int index) {
    final searchVersesProvider = Provider.of<SearchVersesProvider>(context, listen: false);
    List<TextSpan> versesListByQuery = [TextSpan(text: verse, style: (verseColor != Colors.transparent) ? themeColors.coloredVerse() : themeColors.verseColor(true))];
    if(searchVersesProvider.highlightedWords.isNotEmpty) {
      final verseFound = searchVersesProvider.highlightedWords.toList();
      if (verseFound.isNotEmpty) {
        for(var i = 0; i < verseFound.length; i++) {
          if(verse.contains(verseFound[i].text!)) {
            print('VERSO QUE TA SENDO ANALISADO E PASSOU $verse QUE TEM INDEX $index');
            versesListByQuery = verseFound;
          }
        }
      }else {
        versesListByQuery = [TextSpan(text: verse, style: (verseColor != Colors.transparent) ? themeColors.coloredVerse() : themeColors.verseColor(true))];
      }
    }
    return versesListByQuery;
  }

  void onTap(BuildContext context, int index) {
    final isSelected = !listMap[index]["isSelected"];
    final verseColor = listMap[index]["verseColor"];
    final bool isEditing = verseColor != Colors.transparent;

    setState(() {
      listMap[index]["isSelected"] = isSelected;
      listMap[index]["isEditing"] = isEditing;
    });

    final selectedVersesExist = _versesProvider.verseSelectedExists(listMap);
    if (selectedVersesExist) {
      _versesProvider.openBottomSheet(true);
      showBottomSheet(
          context: context,
          builder: (BuildContext ctx) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: (() {
                        _versesProvider.shareVerses(context, listMap, widget.bookName);
                      }),
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: (() {
                        _versesProvider.copyVerses(context, listMap);
                      }),
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: (() {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, 'verse_with_background',
                            arguments: {
                              "bookName": listMap[index]["bookName"],
                              "chapter": listMap[index]["chapter"],
                              "verseNumber": listMap[index]["verseNumber"],
                              "content": listMap[index]["verse"]
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
            );
          });
    } else {
      Navigator.pop(context);
      _versesProvider.openBottomSheet(false);
    }
  }
}
