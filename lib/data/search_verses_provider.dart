import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class SearchVersesProvider extends ChangeNotifier {
  List<dynamic> _bibleData = [];
  final List<String> _books = [];
  final List<String> _abbrev = [];

  List<String> get books => _books;

  List<String> get abbrev => _abbrev;

  List<dynamic> get bibleData => _bibleData;

  Future<List<dynamic>> loadBibleData({String version = 'nvi'}) async {
    switch(version) {
      case 'greek':
        version = 'el_greek';
        break;
      case 'bbe':
        version = 'en_bbe';
        break;
      case 'kjv':
        version = 'en_kjv';
        break;
    }
    final String response =
        await rootBundle.loadString('assets/json/$version.json');
    _bibleData = await json.decode(response);

    return _bibleData;
  }

  List<String> getBooks() {
    for (int i = 0; i < _bibleData.length; i++) {
      _books.add(_bibleData[i]['name']);
    }

    return _books;
  }

  List<String> getAbbrev() {
    for (int i = 0; i < _bibleData.length; i++) {
      _abbrev.add(_bibleData[i]['abbrev']);
    }

    return _abbrev;
  }

  Future<List<Map<String, dynamic>>> searchVerses(
      String query, String version, {String findIn = 'toda a biblia'}) async {
    List<Map<String, dynamic>> results = [];
    List<dynamic> bibleData = await loadBibleData(version: version);
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
    for (int i = index; i < qtdBooks; i++) {
      var book = bibleData[i]['name'];
      var abbrev = bibleData[i]['abbrev'];
      for (int j = 0; j < bibleData[i]['chapters'].length; j++) {
        var chapterIndex = j + 1;
        var chapter = bibleData[i]['chapters'][j];
        for (int y = 0; y < chapter.length; y++) {
          var verses = chapter[y].split(';');
          for (int k = 0; k < verses.length; k++) {
            var verse = verses[k].trim();
            if (verse.toLowerCase().contains(query.toLowerCase())) {
              var verseIndex = y + 1;
              results.add({
                'book': book,
                'abbrev': abbrev,
                'qtdChapters': bibleData[i]['chapters'].length,
                'chapter': chapterIndex,
                'bookIndex': i,
                'verse': verse,
                'verseNumber': verseIndex
              });
            }
          }
        }
      }
    }
    notifyListeners();
    return results;
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