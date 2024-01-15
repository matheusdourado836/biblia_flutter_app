import 'dart:developer';
import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/models/book.dart';
import 'annotations_dao.dart';
import 'bible_data.dart';

class BibleDataController {
  final BibleData _bibleData = BibleData();
  final AnnotationsDao _annotationsDao = AnnotationsDao();
  String _annotationTitle = '';
  int _startIndex = 0;
  int _endIndex = 0;
  List<Book> _books = [];

  String get annotationTitle => _annotationTitle;

  int get startIndex => _startIndex;

  int get endIndex => _endIndex;

  List<Book> get books => _books;

  Future<List<Annotation>?> verifyAnnotationExists(String bookName, int chapter, int verse) async {
    return await _annotationsDao.findByTitle(bookName, chapter, verse);
  }

  Future<Annotation?> annotationExists(String bookName, int chapter, int verse) async {
    return await _annotationsDao.checkByTitle(bookName, chapter, verse);
  }

  void getStartAndEndIndex(List<Map<String, dynamic>> listMap, int verseNumber) {
    _startIndex = 0;
    _endIndex = 0;
    List<Map<String, dynamic>> versosSelecionados = listMap.where((element) => element["isSelected"] == true).toList();
    _startIndex = versosSelecionados.first['verseNumber'];
    _endIndex = versosSelecionados.last['verseNumber'];
    _annotationTitle = '${versosSelecionados.first['bookName']} ${versosSelecionados.first['chapter']}:$_startIndex-$_endIndex';
    if(_startIndex == _endIndex) {
      _annotationTitle = '${versosSelecionados.first['bookName']} ${versosSelecionados.first['chapter']}:$_endIndex';
      _startIndex = 0;
    }
  }

  Future<List<Book>> getBooks() async {
    _books = [];
    String testament = '';
    for (int i = 0; i < _bibleData.data[0].length; i++) {
      testament = i < 39 ? 'VT' : 'NT';
      _books.add(Book(
          abbrev: _bibleData.data[0][i]['abbrev'],
          name: _bibleData.data[0][i]['name'],
          testament: testament,
          chapters: _bibleData.data[0][i]['chapters'].length));
    }

    return _books;
  }

  getVersionName(int versionCode) {
    switch(versionCode) {
      case 0:
        return 'NVI (Nova Versão Internacional)';
      case 1:
        return 'ACF (Almeida Corrigida Fiel)';
      case 2:
        return 'RA (Revista e Atualizada)';
      case 3:
        return 'BBE (Bible in Basic English)';
      case 4:
        return 'KJV (King James Version)';
      case 5:
        return 'RVR (Versão Espanhola Reina-Valera)';
      case 6:
        return 'GREGO ';
    }
  }

  getColorName(String option) {
    switch (option) {
      case 'todas':
        return 0;
      case 'ciano':
        return 2;
      case 'azul':
        return 1;
      case 'amarelo':
        return 3;
      case 'marrom':
        return 4;
      case 'vermelho':
        return 5;
      case 'laranja':
        return 6;
      case 'verde':
        return 7;
      case 'rosa':
        return 8;
    }
  }
}
