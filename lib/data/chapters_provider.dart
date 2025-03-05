import 'dart:convert';

import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'books_dao.dart';

class ChaptersProvider extends ChangeNotifier {
  static final BooksDao _booksDao = BooksDao();
  List<bool> _readChapters = [];
  int _orderStyle = 0;

  List<Book> innerList = [];

  int get orderStyle => _orderStyle;

  List<bool> get readChapters => _readChapters;

  String currentBook = '';

  bool isSearching = false;

  double _position = 0.0;

  double get position => _position;

  void updatePosition(double newPosition) => _position = newPosition;

  Future<List<bool>> setChaptersRead(String bookName, int chapters) async {
    _readChapters = [];
    List<dynamic> chaptersList = [];
    final booksRead = await _booksDao.findByChapter(bookName, chapters);
    if(booksRead['chapters'] is String) {
      final chaptersString = booksRead['chapters'];

      chaptersList = jsonDecode(chaptersString);
    }else {
      chaptersList = booksRead['chapters'];
    }

    notifyListeners();
    return _readChapters = chaptersList.map((chapter) => chapter.values.first as bool).toList();
  }

  Future<void> setChapterRead(String bookName, String chapter, int qtdChapters, bool read) async {
    final index = int.parse(chapter) - 1;
    _readChapters[index] = read;
    await _booksDao.setChapterRead(bookName, chapter, qtdChapters, read);
    notifyListeners();
  }

  void addAllChapters(String bookName, int chapters) async {
    await _booksDao.save(bookName, chapters, 1);
    _readChapters = List.generate(chapters, (i) => true, growable: false);

    notifyListeners();
  }

  void removeAllChapters(String bookName, int chapters) async {
    await _booksDao.delete(bookName);
    _readChapters = List.generate(chapters, (i) => false, growable: false);

    notifyListeners();
  }

  void setOrderStyle(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(value.startsWith('Por')) {
      await prefs.setInt('orderStyle', 2);
      _orderStyle = 2;
    }else if(value == 'Padrão') {
      await prefs.setInt('orderStyle', 0);
      _orderStyle = 0;
    }else {
      await prefs.setInt('orderStyle', 1);
      _orderStyle = 1;
    }

    notifyListeners();
  }

  void getOrderStyle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _orderStyle = prefs.getInt('orderStyle') ?? 0;
  }

  void updateSearch(List<Book> books, String query) {
    if(query.isEmpty) {
      isSearching = false;
      notifyListeners();
      return;
    }
    isSearching = true;
    final querySemAcento = query.toLowerCase().removerAcentos();
    innerList = books.where((item) => item.name.toLowerCase().removerAcentos().startsWith(querySemAcento) || item.name.toLowerCase().removerAcentos().contains(querySemAcento)).toList();
    notifyListeners();
  }
}