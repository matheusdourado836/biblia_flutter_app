import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import '../../../data/bible_data.dart';
import '../verses_screen.dart';

class VerseArea extends StatefulWidget {
  final int chapter;
  final int verseNumber;
  final Color verseColor;
  final List<TextSpan> verse;
  final Annotation? annotation;

  const VerseArea({
    super.key,
    required this.verseNumber,
    required this.verse,
    required this.verseColor,
    required this.chapter,
    this.annotation,
  });

  @override
  State<VerseArea> createState() => _VerseAreaState();
}

class _VerseAreaState extends State<VerseArea> {
  Color verseColor = Colors.transparent;
  final ThemeColors themeColors = ThemeColors();
  List<dynamic> verses = [];

  @override
  Widget build(BuildContext context) {
    final defaultColor = themeColors.verseNumberColor(themeProvider!.isOn);
    final textOnColoredBackground = (widget.verseColor == Theme.of(context).highlightColor) ? themeColors.coloredVerse(themeProvider!.isOn) : themeColors.coloredVerse(true);
    return Container(
      decoration: BoxDecoration(
        color: widget.verseColor,
        borderRadius: BorderRadius.circular(4)
      ),
      padding: const EdgeInsets.all(6),
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${widget.verseNumber.toString()}  ',
              style: (widget.verseColor == Colors.transparent) ? defaultColor : textOnColoredBackground,
              children: widget.verse,
            ),
          ),
          (widget.annotation != null) ? IconButton(onPressed: (() {
            final List<dynamic> list = BibleData().data[0]["text"];
            final bookInfo = list.where((element) => element['name'] == widget.annotation!.book).toList();
            verses = bookInfo[0]['chapters'][widget.chapter - 1];
            Navigator.pushNamed(context, 'annotation_widget', arguments: {
              'annotation': widget.annotation,
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
