import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/bible_data.dart';
import '../../../data/bible_data_controller.dart';

class VerseArea extends StatefulWidget {
  final int chapter;
  final int verseNumber;
  final Color verseColor;
  final String? title;
  final String verse;
  final bool verseHasAnnotation;

  const VerseArea({
    Key? key,
    required this.verseNumber,
    required this.verse,
    required this.verseColor,
    required this.verseHasAnnotation,
    required this.chapter,
    this.title,
  }) : super(key: key);

  @override
  State<VerseArea> createState() => _VerseAreaState();
}

class _VerseAreaState extends State<VerseArea> {
  Color verseColor = Colors.transparent;
  final ThemeColors themeColors = ThemeColors();
  List<dynamic> verses = [];
  late Annotation? annotation;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if(widget.verseHasAnnotation) {
      BibleDataController()
          .verifyAnnotationExists(widget.title!.split(' ')[0], widget.chapter, widget.verseNumber)
          .then((value) {
        annotation = value![0];
      });
    } else {
      annotation = null;
    }
    return Container(
      color: widget.verseColor,
      padding: const EdgeInsets.all(6),
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${widget.verseNumber.toString()}  ',
              style: (widget.verseColor == Colors.transparent) ? themeColors.verseNumberColor(themeProvider.isOn) : themeColors.coloredVerse(),
              children: <TextSpan>[
                (widget.verseColor != Colors.transparent)
                    ? TextSpan(text: widget.verse, style: themeColors.coloredVerse())
                    : TextSpan(text: widget.verse, style: themeColors.verseColor(themeProvider.isOn)),
              ],
            ),
          ),
          (widget.verseHasAnnotation) ? IconButton(onPressed: (() {
            final List<dynamic> list = BibleData().data[0];
            final bookInfo = list.where((element) => element['name'] == annotation!.book).toList();
            verses = bookInfo[0]['chapters'][widget.chapter - 1];
            Navigator.pushNamed(context, 'annotation_widget', arguments: {
              'annotation': annotation,
              'verses': verses,
              'isEditing': true
            });
          }), icon: const Icon(Icons.mode_edit_outline_outlined))
              : Container()
        ],
      ),
    );
  }
}
