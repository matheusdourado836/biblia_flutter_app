import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SearchVersesProvider extends ChangeNotifier {
  static final BibleData bibleData = BibleData();
  List<TextSpan> highlightedWords = [];

  List<Map<String, dynamic>> searchVerses(
    String query,
    int versionIndex, {
      String findIn = 'toda a biblia',
      int findInBookIndex = -1,
      bool preciseSearch = false,
    }) {
    List<Map<String, dynamic>> results = [];
    int startIndex = 0, qtdBooks = 66;

    switch (findIn) {
      case 'antigo testamento':
        qtdBooks = 39;
        break;
      case 'novo testamento':
        startIndex = 39;
        break;
    }

    if (findInBookIndex != -1) {
      startIndex = findInBookIndex;
      qtdBooks = findInBookIndex + 1;
    }

    final normalizedQuery = _normalizeText(query);
    final queryWords = normalizedQuery.split(' ');

    for (int bookIndex = startIndex; bookIndex < qtdBooks; bookIndex++) {
      var bookData = bibleData.data[versionIndex]["text"][bookIndex];
      var book = bookData['name'];
      var abbrev = bookData['abbrev'];

      for (int chapterIndex = 0; chapterIndex < bookData['chapters'].length; chapterIndex++) {
        var chapter = bookData['chapters'][chapterIndex];

        for (int verseIndex = 0; verseIndex < chapter.length; verseIndex++) {
          var verses = chapter[verseIndex].split(';');

          for (var verse in verses) {
            verse = verse.trim();

            bool match = preciseSearch
              ? _matchesPreciseSearch(verse, queryWords)
              : verse.toLowerCase().contains(query.toLowerCase());

            if (match) {
              changeColorOfMatchedWord(query.toLowerCase(), verse);
              results.add({
                'book': book,
                'abbrev': abbrev,
                'qtdChapters': bookData['chapters'].length,
                'chapter': chapterIndex + 1,
                'bookIndex': bookIndex,
                'verse': verse,
                'verseNumber': verseIndex + 1,
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
    final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    highlightedWords = [];
    final index = verse.toLowerCase().indexOf(query.toLowerCase());
    final matchString = verse.substring(index, index + query.length);
    final TextSpan highLightedText = TextSpan(
      text: matchString,
      style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: versesProvider.fontSize,
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

  bool _matchesPreciseSearch(String verse, List<String> queryWords) {
    final verseWords = _normalizeText(verse).split(' ');

    if (queryWords.length == 1) {
      return verseWords.contains(queryWords.first);
    }

    for (int i = 0; i <= verseWords.length - queryWords.length; i++) {
      if (listEquals(verseWords.sublist(i, i + queryWords.length), queryWords)) {
        return true;
      }
    }
    return false;
  }

  String _normalizeText(String text) {
    return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '') // Remove pontuações
      .replaceAll(RegExp(r'\s+'), ' ') // Substitui múltiplos espaços por um só
      .trim();
  }

  void share(String bookName, String verse, int chapter, int verseNumber) {
    Share.share('$bookName $chapter:$verseNumber $verse');
  }

  void copyText(String bookName, String verse, int chapter, int verseNumber) {
    Clipboard.setData(ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }
}