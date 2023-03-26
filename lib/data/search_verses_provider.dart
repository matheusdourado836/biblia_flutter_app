import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class SearchVersesProvider extends ChangeNotifier {
  List<dynamic> _bibleData = [];

  Future<List<dynamic>> loadBibleData({String version = 'nvi'}) async {
    final String response =
        await rootBundle.loadString('assets/json/$version.json');
    final data = await json.decode(response);

    return data;
  }

  Future<List<Map<String, dynamic>>> searchVerses(
      String query, String version) async {
    List<Map<String, dynamic>> results = [];
    List<dynamic> bibleData = await loadBibleData(version: version);
    for (int i = 0; i < bibleData.length; i++) {
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

  void copyText(String bookName, String verse, int chapter, int verseNumber) async {
    await Clipboard.setData(ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }
}
