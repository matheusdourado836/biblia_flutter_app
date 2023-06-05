import '../models/book.dart';

class ChapterPageHelpers {
  final List<Book> _listBooksVT = [];
  final List<Book> _listBooksNT = [];

  Map<String, List<Book>> formatedBookMap(List<Book> listBooks) {
    Map<String, List<Book>> map = {};
    for (var value in listBooks) {
      if (value.testament == 'VT') {
        _listBooksVT.add(value);
      } else if (value.testament == 'NT') {
        _listBooksNT.add(value);
      }
    }

    map["livrosVT"] = _listBooksVT;
    map["livrosNT"] = _listBooksNT;

    return map;
  }
}
