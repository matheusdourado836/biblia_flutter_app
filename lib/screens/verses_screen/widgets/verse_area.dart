import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import '../../../data/bible_data.dart';

class VerseArea extends StatelessWidget {
  final int chapter;
  final int verseNumber;
  final Color verseColor;
  final List<TextSpan> verse;
  final Annotation? annotation;
  final EventBus eventBus;

  const VerseArea({
    super.key,
    required this.verseNumber,
    required this.verse,
    required this.verseColor,
    required this.chapter,
    required this.eventBus,
    this.annotation,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeColors themeColors = ThemeColors();
    final defaultColor = themeColors.coloredVerse(true);
    final textOnColoredBackground = verseColor == Theme.of(context).highlightColor
        ? themeColors.coloredVerse(false)
        : themeColors.coloredVerse(true);
    return Container(
      decoration: BoxDecoration(
        color: verseColor,
        borderRadius: BorderRadius.circular(4)
      ),
      padding: const EdgeInsets.all(6),
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${verseNumber.toString()}  ',
              style: verseColor != Colors.transparent ? defaultColor : textOnColoredBackground,
              children: verse,
            ),
          ),
          if(annotation != null)
            IconButton(
              onPressed: () {
                final List<dynamic> list = BibleData().data[0]["text"];
                final bookInfo = list.where((element) => element['name'] == annotation!.book).toList();
                List<dynamic> verses = [];
                verses = bookInfo[0]['chapters'][chapter - 1];
                Navigator.pushNamed(context, 'annotation_widget', arguments: {
                  'annotation': annotation,
                  'verses': verses,
                  'isEditing': true,
                  'eventBus': eventBus
                });
              },
              icon: const Icon(Icons.mode_edit_outline_outlined)
            )
        ],
      ),
    );
  }
}

class VerseAreaDark extends StatelessWidget {
  final int chapter;
  final int verseNumber;
  final Color verseColor;
  final List<TextSpan> verse;
  final Annotation? annotation;
  final EventBus eventBus;

  const VerseAreaDark({
    super.key,
    required this.chapter,
    required this.verseNumber,
    required this.verseColor,
    required this.verse,
    required this.eventBus,
    this.annotation
  });

  @override
  Widget build(BuildContext context) {
    final ThemeColors themeColors = ThemeColors();
    final defaultColor = themeColors.coloredVerse(verseColor != Theme.of(context).highlightColor);
    final textOnColoredBackground = themeColors.coloredVerse(verseColor == Theme.of(context).highlightColor);
    return Container(
      decoration: BoxDecoration(
        color: verseColor,
        borderRadius: BorderRadius.circular(4)
      ),
      padding: const EdgeInsets.all(6),
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${verseNumber.toString()}  ',
              style: verseColor != Colors.transparent ? defaultColor : textOnColoredBackground,
              children: verse,
            ),
          ),
          if (annotation != null)
            IconButton(
              onPressed: () {
                final List<dynamic> list = BibleData().data[0]["text"];
                final bookInfo = list.where((element) => element['name'] == annotation!.book).toList();
                List<dynamic> verses = [];
                verses = bookInfo[0]['chapters'][chapter - 1];
                Navigator.pushNamed(context, 'annotation_widget', arguments: {
                  'annotation': annotation,
                  'verses': verses,
                  'isEditing': true,
                  'eventBus': eventBus
                });
              },
              icon: const Icon(Icons.mode_edit_outline_outlined)
            )
        ],
      ),
    );
  }
}
