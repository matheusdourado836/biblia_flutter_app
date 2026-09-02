import 'dart:convert';
import 'dart:developer';
import 'database.dart';
import 'package:sqflite/sqflite.dart';

class BooksDao {
  static final Database _versesInstance = DatabaseHelper.versesDatabase;
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_bookName TEXT, '
      '$_chapters TEXT, '
      '$_finishedReading INTEGER)';

  static const String _tablename = 'bookstable';
  static const String _bookName = 'bookName';
  static const String _chapters = 'chapters';
  static const String _finishedReading = 'finishedReading';

  Future<int> save(String bookName, int chapters, int finishedReading) async {
    final itemExists = await find(bookName);
    final chaptersString = jsonEncode(setChapters(chapters, 1));
    Map<String, dynamic> bookMap = toJson(bookName, chaptersString, finishedReading);
    if(itemExists.isEmpty) {
      return await _versesInstance.insert(_tablename, bookMap);
    }

    return await _versesInstance.update(_tablename, bookMap, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  Future<void> setChapterRead(String bookName, String chapter, int qtdChapters, bool read) async {
    try {
      final mapChapters = await findByChapter(bookName, qtdChapters);
      final List<Map<String, dynamic>> listChapters = List<Map<String, dynamic>>.from(mapChapters['chapters']);

      final bool firstSave = listChapters.every((c) => c.values.first == false);
      final int chapterIndex = int.parse(chapter) - 1;
      listChapters[chapterIndex][chapter] = read;

      final bool allRead = listChapters.every((c) => c.values.first == true);

      final chaptersString = jsonEncode(listChapters);

      if (firstSave) {
        final bookMap = toJson(bookName, chaptersString, 0);
        await _versesInstance.insert(_tablename, bookMap);
      } else {
        await _versesInstance.update(
          _tablename,
          {'chapters': chaptersString, 'finishedReading': allRead ? 1 : 0},
          where: '$_bookName = ?',
          whereArgs: [bookName],
        );
      }
    } catch (e) {
      log('NAO FOI POSSIVEL SALVAR O CAPITULO: $e');
    }
  }

  List<Map<String, dynamic>> setChapters(int chapters, int finishedReading) {
    List<Map<String, dynamic>> list = List.generate(
      chapters,
      (index) => {(index + 1).toString(): finishedReading == 1 ? true : false},
      growable: false
    );

    return list;
  }

  Future<int> delete(String bookName) async {
    return _versesInstance.delete(_tablename, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  Future<List<Map<String, dynamic>>> findAll() async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(_tablename);

    return result;
  }

  Future<List<Map<String, dynamic>>> find(String bookName) async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(
      _tablename,
      where: '$_bookName = ?',
      whereArgs: [bookName],
    );

    return result;
  }

  Future<Map<String, dynamic>> findByChapter(String bookName, int qtdChapters) async {
    try {
      final result = await find(bookName);

      if(result.isEmpty) {
        final emptyList = [];
        for(var i = 0; i < qtdChapters; i++) {
          emptyList.add({(i + 1).toString(): false});
        }
        final jsonString = jsonEncode({"chapters": emptyList});

        return jsonDecode(jsonString);
      }
      final chapters = {"chapters": jsonDecode(result[0]['chapters'])};

      return chapters;
    }catch(e) {
      log('NAOI FOI POSSIVEL ENCONTRAR O LIVRO $e');
      return {};
    }
  }

  Map<String, dynamic> toJson(String bookName, String chapters, int finishedReading) => {
    _bookName: bookName,
    _chapters: chapters,
    _finishedReading: finishedReading
  };
}