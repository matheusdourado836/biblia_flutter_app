import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:provider/provider.dart';

class GoToVerseScreen {
  goToVersePage(String bookName, String abbrev, int bookIndex, int chapters, int chapter, int verseNumber) {
    final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    final versionProvider = Provider.of<VersionProvider>(navigatorKey!.currentContext!, listen: false);
    final versionName = versionProvider.selectedOption.toLowerCase().split(' ')[0];
    Map<String, dynamic> mapBooks = {};
    mapBooks["bookName"] = bookName;
    mapBooks["abbrev"] = abbrev;
    mapBooks["bookIndex"] = bookIndex;
    mapBooks["chapters"] = chapters;
    mapBooks["chapter"] = chapter;
    mapBooks["verseNumber"] = verseNumber;
    versesProvider.loadVerses(mapBooks["bookIndex"], mapBooks["bookName"], versionName: versionName);
    navigatorKey?.currentState?.pushNamed('verses_screen', arguments: mapBooks);
  }
}
