import 'package:biblia_flutter_app/main.dart';

class GoToVerseScreen {
  goToVersePage(String bookName, String abbrev, int chapters, int bookIndex,
      int chapter, int verseNumber) {
    Map<String, dynamic> mapBooks = {};
    mapBooks["bookName"] = bookName;
    mapBooks["abbrev"] = abbrev;
    mapBooks["bookIndex"] = bookIndex;
    mapBooks["chapters"] = chapters;
    mapBooks["chapter"] = chapter;
    mapBooks["verseNumber"] = verseNumber;
    navigatorKey?.currentState?.pushNamed('verses_screen', arguments: mapBooks);
  }
}
