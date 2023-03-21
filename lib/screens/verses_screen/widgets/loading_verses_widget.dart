import 'dart:async';

import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/helpers/convert_colors.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verse_area.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../data/verse_inherited.dart';
import '../../../helpers/exception_dialog.dart';
import '../../../helpers/loading_widget.dart';
import '../../../models/chapter.dart';
import '../verses_screen.dart';

List<Map<String, dynamic>> listMap = [];
bool versesSelected = false;

class LoadingVersesWidget extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int chapter;
  final String verseColors;

  const LoadingVersesWidget(
      {Key? key,
      required this.bookName,
      required this.abbrev,
      required this.chapter,
      required this.verseColors,})
      : super(key: key);

  @override
  State<LoadingVersesWidget> createState() => _LoadingVersesWidgetState();
}

class _LoadingVersesWidgetState extends State<LoadingVersesWidget> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  int _chapter = 1;
  List<Map<String, dynamic>> listColorsDb = [];
  late SavedVersesProvider _savedVersesProvider;
  late List<Chapter> futureVerses;

  @override
  void initState() {
    _chapter = widget.chapter;
    _savedVersesProvider = Provider.of<SavedVersesProvider>(context, listen: false);
    refreshFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedVersesProvider>(
      builder: (context, value, child) {
        return FutureBuilder<List<Chapter>>(
          future: service.getVerses(widget.abbrev, _chapter.toString(), version: savedVersesProvider.version.toLowerCase())
              .catchError(
                (error) {
              var innerError = error as TimeoutException;
              exceptionDialog(title: 'Erro ${innerError.message}',
                  content:
                  'O servidor demorou pra responder. Tente novamente mais tarde.');
            },
            test: (error) => error is TimeoutException,
          ),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              if (snapshot.data!.isNotEmpty && listColorsDb.length == snapshot.data!.length) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: verseWidget(snapshot.data!, snapshot.data!.length));
              }
            }else if(snapshot.hasError) {
              return Center(child: Text('ERRO: ${snapshot.error}'));
            }
            return const LoadingWidget();
          },
        );
      },
    );
  }

  Widget verseWidget(List<Chapter> verses, int qtdVerses) {
    return ScrollablePositionedList.builder(
      initialScrollIndex: initialVerse - 1,
      itemScrollController: _itemScrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: qtdVerses,
      itemBuilder: (BuildContext context, int index) {
        String verse = verses[index].verse;
        listMap[index]["index"] = index;
        listMap[index]["chapter"] = widget.chapter;
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: InkWell(
            onTap: (() {onTap(context, index);}),
            child: VerseArea(
              verseNumber: index + 1,
              verse: verse,
              verseColor: (listMap[index]["isSelected"]) ? Theme.of(context).highlightColor : listMap[index]["verseColor"],
            ),
          ),
        );
      },
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

    final selectedVersesExist = _savedVersesProvider.verseSelectedExists(listMap);

    if(selectedVersesExist) {
      showBottomSheet(context: context, builder: (BuildContext ctx) {
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
                  onPressed: (() async {
                    VerseInherited.of(context).copyText(context, listMap);
                  }),
                  icon: const Icon(Icons.copy),
                ),
                IconButton(
                  onPressed: (() {
                    VerseInherited.of(context).deleteVerses(listMap);
                    refreshFunction();
                  }),
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: (() {
                    _savedVersesProvider.clearSelectedVerses(listMap);
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
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color2, ThemeColors.colorString2);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: RoundContainer(color: ThemeColors.color2),
                ),
                InkWell(
                    onTap: (() {
                      setState(() {
                        if(listMap[index]["verseColor"] != Colors.transparent) {
                          listMap[index]["isEditing"] = true;
                        }
                        VerseInherited.of(context)
                            .updateColors(listMap, ThemeColors.color3, ThemeColors.colorString3);
                      });
                      _savedVersesProvider.refresh();
                    }),
                    child: RoundContainer(color: ThemeColors.color3)),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color4, ThemeColors.colorString4);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: const RoundContainer(color: Colors.brown),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color5, ThemeColors.colorString5);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: RoundContainer(color: ThemeColors.color5),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color6, ThemeColors.colorString6);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: RoundContainer(color: ThemeColors.color6),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color7, ThemeColors.colorString7);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: RoundContainer(color: ThemeColors.color7),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color8, ThemeColors.colorString8);
                    });
                    _savedVersesProvider.refresh();
                  }),
                  child: RoundContainer(color: ThemeColors.color8),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      if(listMap[index]["verseColor"] != Colors.transparent) {
                        listMap[index]["isEditing"] = true;
                      }
                      VerseInherited.of(context)
                          .updateColors(listMap, ThemeColors.color1, ThemeColors.colorString1);
                    });
                    _savedVersesProvider.refresh();
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
    }
    if(selectedVersesExist == false) {
      Navigator.maybePop(context);
    }
  }

  refreshFunction() {
    listColorsDb = [];
    listMap = [];
    service.getVerses(widget.abbrev, _chapter.toString()).then((value) async => {
      for(var element in value) {
        await VersesDao().find(element.verse).then((res) => {
          if(res.isNotEmpty) {
            if(res[0].verse == element.verse) {
              listColorsDb.add({
                "verse": element.verse,
                "color": ConvertColors().convertColors(res[0].verseColor)
              }),
            }
          }else {
            listColorsDb.add({
              "verse": element.verse,
              "color": Colors.transparent
            }),
          },
        }),
        listMap.add({
          "bookName": widget.bookName,
          "chapter": widget.chapter,
          "verseNumber": element.verseNumber,
          "verse": element.verse,
          "verseColor": listColorsDb[element.verseNumber - 1]["color"],
          "isSelected": false,
          "isEditing": false
        }),
      },
      setState(() {
        listColorsDb;
      })
    });
  }
}