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
import '../../../data/verse_inherited.dart';
import '../../../models/annotation_model.dart';
import '../verses_screen.dart';

bool versesSelected = false;
late ItemScrollController itemScrollController;

class LoadingVersesWidget extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int bookIndex;
  final int chapter;
  final String verseColors;

  const LoadingVersesWidget({
    Key? key,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verseColors,
    required this.bookIndex,
  }) : super(key: key);

  @override
  State<LoadingVersesWidget> createState() => _LoadingVersesWidgetState();
}

class _LoadingVersesWidgetState extends State<LoadingVersesWidget> {
  List<Map<String, dynamic>> listMap = [];
  final BibleDataController bibleDataController = BibleDataController();
  int _chapter = 1;

  late VersesProvider _versesProvider;

  @override
  void initState() {
    _chapter = widget.chapter;
    _versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!,
        listen: false);
    itemScrollController = ItemScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      listMap = _versesProvider.allVerses[_chapter];
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScrollablePositionedList.builder(
        initialScrollIndex: initialVerse - 1,
        itemScrollController: itemScrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _versesProvider.allVerses[_chapter].length,
        itemBuilder: (BuildContext context, int index) {
          bibleDataController
              .annotationExists(
                  '${widget.bookName} ${widget.chapter}:${index + 1}')
              .then((value) => {listMap[index]["hasAnnotation"] = value});
          listMap[index]["index"] = index;
          listMap[index]["chapter"] = _chapter;
          if ((index + 1) == _versesProvider.allVerses[_chapter].length) {
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
                    verse: listMap[index]["verse"],
                    verseColor: (listMap[index]["isSelected"])
                        ? Theme.of(context).highlightColor
                        : listMap[index]["verseColor"],
                    verseHasAnnotation:
                        (listMap[index]["hasAnnotation"] == null)
                            ? false
                            : listMap[index]["hasAnnotation"],
                  ),
                ),
                Container(height: 200,)
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
                verse: listMap[index]["verse"],
                verseColor: (listMap[index]["isSelected"])
                    ? Theme.of(context).highlightColor
                    : listMap[index]["verseColor"],
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
                        VerseInherited.of(context)
                            .share(context, listMap, widget.bookName);
                      }),
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: (() {
                        VerseInherited.of(context).copyText(context, listMap);
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
                        bibleDataController.getStartAndEndIndex(
                            listMap, listMap[index]["verseNumber"]);
                        AnnotationModel innerAnnotation = AnnotationModel(
                            annotationId: const Uuid().v1(),
                            title:
                                '${widget.bookName} ${widget.chapter}:${index + 1}',
                            content: '',
                            book: widget.bookName,
                            chapter: widget.chapter,
                            verseStart: bibleDataController.startIndex,
                            verseEnd: index + 1);
                        bibleDataController
                            .verifyAnnotationExists(
                                '${widget.bookName} ${widget.chapter}:${index + 1}')
                            .then((value) => {
                                  if (value != null)
                                    {
                                      innerAnnotation = value[0],
                                      Navigator.pushNamed(
                                          context, 'annotation_widget',
                                          arguments: {
                                            'annotation': innerAnnotation,
                                            'isEditing': true
                                          })
                                    }
                                  else
                                    {
                                      Navigator.pushNamed(
                                          context, 'annotation_widget',
                                          arguments: {
                                            'annotation': innerAnnotation,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                            VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
                          VerseInherited.of(context).updateColors(listMap,
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
