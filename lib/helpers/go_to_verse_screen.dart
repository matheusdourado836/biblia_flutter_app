import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:provider/provider.dart';

class GoToVerseScreen {
  goToVersePage(String bookName, String abbrev, int bookIndex, int chapters, int chapter, int verseNumber) {
    final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    Map<String, dynamic> mapBooks = {};
    mapBooks["bookName"] = bookName;
    mapBooks["abbrev"] = abbrev;
    mapBooks["bookIndex"] = bookIndex;
    mapBooks["chapters"] = chapters;
    mapBooks["chapter"] = chapter;
    mapBooks["verseNumber"] = verseNumber;
    versesProvider.loadVerses(mapBooks["bookIndex"], mapBooks["bookName"]);
    navigatorKey?.currentState?.pushNamed('verses_screen', arguments: mapBooks);
  }
}
