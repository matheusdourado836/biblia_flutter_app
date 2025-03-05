import '../models/book.dart';

class ChapterPageHelpers {
  final List<Book> _listBooksVT = [];
  final List<Book> _listBooksNT = [];

  Map<String, List<Book>> formatedBookMap(List<Book> listBooks) {
    Map<String, List<Book>> map = {};
    _listBooksVT.addAll(listBooks.where((book) => book.testament == 'VT').toList(growable: false));
    _listBooksNT.addAll(listBooks.where((book) => book.testament == 'NT').toList(growable: false));

    map["livrosVT"] = _listBooksVT;
    map["livrosNT"] = _listBooksNT;

    return map;
  }
}
