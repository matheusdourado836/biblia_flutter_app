import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerseDialog extends StatelessWidget {
  final double width;
  final double height;
  final String bookName;
  final int chapter;
  final String verse;
  final List<dynamic> verses;
  const VerseDialog({super.key, required this.bookName, required this.chapter, required this.verse, required this.verses, required this.width, required this.height});

  static ThemeColors themeColors = ThemeColors();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(26), topEnd: Radius.circular(26))
          ),
          child: Stack(
            children: [
              Center(
                child: Text('$bookName $chapter:$verse', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white,),
                ),
              )
            ],
          )
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      content: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(var i = 0; i < verses.length; i++)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text.rich(TextSpan(
                      text: '${int.parse(verse.contains('-') ? verse.split('-')[0] : verse) + i}  ',
                      style: themeColors.coloredVerse(themeProvider.isOn),
                      children: <TextSpan>[
                        TextSpan(text: verses[i], style: themeColors.verseColor(themeProvider.isOn))
                      ]
                  )
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: (() {
              final versesProvider = Provider.of<VersesProvider>(context, listen: false);
              final List<dynamic> list = BibleData().data[0]["text"];
              final bookInfo = list.where((element) => element['name'] == bookName).toList();
              int verseNumber = int.parse(verse.contains('-') ? verse.split('-')[0] : verse);
              versesProvider.clear();
              versesProvider.loadVerses(list.indexOf(bookInfo.first), bookName);
              GoToVerseScreen().goToVersePage(
                bookName,
                bookInfo[0]['abbrev'],
                list.indexOf(bookInfo.first),
                bookInfo[0]['chapters'].length,
                chapter,
                verseNumber
              );
            }),
            child: const Text('Ler completo')
          ),
        )
      ],
    );
  }
}
