import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/home_screen/home_screen.dart';

class SearchVersesProvider extends ChangeNotifier {
  final BibleData bibleData = BibleData();
  List<TextSpan> highlightedWords = [];

  Future<List<Map<String, dynamic>>> searchVerses(String query, int versionIndex, {String findIn = 'toda a biblia', int findInBookIndex = 0}) async {
    List<Map<String, dynamic>> results = [];
    int qtdBooks = 66;
    int index = 0;
    switch(findIn) {
      case 'antigo testamento':
        qtdBooks = 39;
        break;
      case 'novo testamento':
        index = 39;
        break;
    }
    if(findInBookIndex != -1) {
      index = findInBookIndex;
      qtdBooks = findInBookIndex + 1;
    }

    for (int i = index; i < qtdBooks; i++) {
      var book = bibleData.data[versionIndex][i]['name'];
      var abbrev = bibleData.data[versionIndex][i]['abbrev'];
      for (int j = 0; j < bibleData.data[versionIndex][i]['chapters'].length; j++) {
        var chapterIndex = j + 1;
        var chapter = bibleData.data[versionIndex][i]['chapters'][j];
        for (int y = 0; y < chapter.length; y++) {
          var verses = chapter[y].split(';');
          for (int k = 0; k < verses.length; k++) {
            var verse = verses[k].trim().toString();
            if (verse.toLowerCase().contains(query.toLowerCase())) {
              var verseIndex = y + 1;
              changeColorOfMatchedWord(query.toLowerCase(), verse);
              results.add({
                'book': book,
                'abbrev': abbrev,
                'qtdChapters': bibleData.data[versionIndex][i]['chapters'].length,
                'chapter': chapterIndex,
                'bookIndex': i,
                'verse': verse,
                'verseNumber': verseIndex,
                'highlightedTexts': highlightedWords
              });
            }
          }
        }
      }
    }
    notifyListeners();
    return results;
  }

  void changeColorOfMatchedWord(String query, String verse, {bool textOnColoredBackground = false}) {
    highlightedWords = [];
    final index = verse.toLowerCase().indexOf(query.toLowerCase());
    final matchString = verse.substring(index, index + query.length);
    final TextSpan highLightedText = TextSpan(
      text: matchString,
      style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false).fontSize,
          fontWeight: FontWeight.bold, 
          color: Colors.redAccent
      ),
    );
    List<TextSpan> verseFormated = [];
    final List<String> verseSplitByQuery = verse.toLowerCase().split(query);
    for(var i = 0; i < verseSplitByQuery.length; i++) {
      if(verseSplitByQuery[i].isEmpty ) {
        verseFormated.add(highLightedText);
      }else {
        verseFormated.add(
          TextSpan(
            text: verseSplitByQuery[i],
            style: (textOnColoredBackground)
                ? const TextStyle(color: Colors.black)
                : Theme.of(navigatorKey!.currentContext!).textTheme.bodyLarge!.copyWith(fontSize: versesProvider.fontSize),
          ),
        );
        verseFormated.add(
          highLightedText,
        );
      }
    }
    verseFormated.removeLast();
    highlightedWords = verseFormated;
  }

  List<String> bookToIndex() {
    const biblia = [
      'Gênesis', 'Êxodo', 'Levítico', 'Números', 'Deuteronômio', 'Josué',
      'Juízes', 'Rute', '1º Samuel', '2º Samuel', '1º Reis', '2º Reis', '1º Crônicas',
      '2º Crônicas', 'Esdras', 'Neemias', 'Ester', 'Jó', 'Salmos', 'Provérbios',
      'Eclesiastes', 'Cânticos', 'Isaías', 'Jeremias', 'Lamentações de Jeremias',
      'Ezequiel', 'Daniel', 'Oséias', 'Joel', 'Amós', 'Obadias', 'Jonas', 'Miquéias',
      'Naum', 'Habacuque', 'Sofonias', 'Ageu', 'Zacarias', 'Malaquias',
      'Mateus', 'Marcos', 'Lucas', 'João', 'Atos', 'Romanos', '1ª Coríntios',
      '2ª Coríntios', 'Gálatas', 'Efésios', 'Filipenses', 'Colossenses',
      '1ª Tessalonicenses', '2ª Tessalonicenses', '1ª Timóteo', '2ª Timóteo', 'Tito',
      'Filemom', 'Hebreus', 'Tiago', '1ª Pedro', '2ª Pedro', '1ª João', '2ª João',
      '3ª João', 'Judas', 'Apocalipse'
    ];

    return biblia;
  }

  void share(String bookName, String verse, int chapter, int verseNumber) {
    Share.share('$bookName $chapter:$verseNumber $verse');
  }

  void copyText(
      String bookName, String verse, int chapter, int verseNumber) async {
    await Clipboard.setData(
        ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }
}