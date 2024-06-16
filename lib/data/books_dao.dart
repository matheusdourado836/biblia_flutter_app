import 'dart:convert';
import 'database.dart';
import 'package:sqflite/sqflite.dart';
import 'bible_data.dart';

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

  save(String bookName, int chapters, int finishedReading) async {
    Map<String, dynamic> bookMap = toMap(bookName, setChapters(chapters, 1).toString(), finishedReading);

    return await _versesInstance.update(_tablename, bookMap, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  saveChapters(String bookName) async {
    var itemExists = await find(bookName);
    if(itemExists.isEmpty) {
      final List<dynamic> list = BibleData().data[0];
      final bookInfo = list.where((element) => element['name'] == bookName).toList();
      final chapters = bookInfo[0]['chapters'].length;
      final Map<String, dynamic> mapaDeCapitulos = toMap(bookName, setChapters(chapters, 0).toString(), 0);

      return await _versesInstance.insert(_tablename, mapaDeCapitulos);
    }
  }

  saveChapter(String bookName, String chapter) async {
    int finishedReading = 0;
    Map<String, dynamic> mapChapters = {};
    await findByChapter(bookName).then((value) => mapChapters = value);
    List<dynamic> list = mapChapters['chapters'];
    for(var element in mapChapters['chapters']) {
      if(element[chapter] == false) {
        element[chapter] = true;
      }
    }

    if(list.firstWhere((element) => element.containsValue(false), orElse: () => -1) == -1) {
      finishedReading = 1;
    }

    return await _versesInstance.update(_tablename, {'chapters': json.encode(mapChapters['chapters']), 'finishedReading': finishedReading}, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  deleteChapter(String bookName, String chapter) async {
    Map<String, dynamic> mapChapters = {};
    await findByChapter(bookName).then((value) => mapChapters = value);
    for(var element in mapChapters['chapters']) {
      if(element[chapter] == true) {
        element[chapter] = false;
      }
    }

    return await _versesInstance.update(_tablename, {'chapters': json.encode(mapChapters['chapters']), 'finishedReading': 0}, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  List<Map<String, dynamic>> setChapters(int chapters, int finishedReading) {
    List<Map<String, dynamic>> list = [];
    if(finishedReading == 0) {
      for(var i = 0; i < chapters; i++) {
        list.add({
          '"${i + 1}"': false,
        });
      }
    }else {
      for(var i = 0; i < chapters; i++) {
        list.add({
          '"${i + 1}"': true,
        });
      }
    }

    return list;
  }

  delete(String bookName) async {
    return _versesInstance.delete(_tablename, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  Future<List<Map<String, dynamic>>> findAll() async {
    final List<Map<String, dynamic>> result =
        await _versesInstance.query(_tablename);

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

  Future<Map<String, dynamic>> findByChapter(String bookName) async {
    var result = await find(bookName);

    if(result.isEmpty) {
      await saveChapters(bookName);
      result = await find(bookName);
    }
    final chapters = result[0]['chapters'].substring(1, result[0]['chapters'].length - 1);

    return json.decode('{"chapters": [$chapters]}');
  }

  Map<String, dynamic> toMap(String bookName, String chapters, int finishedReading) {
    final Map<String, dynamic> mapaDeVersos = {};
    mapaDeVersos[_bookName] = bookName;
    mapaDeVersos[_chapters] = chapters;
    mapaDeVersos[_finishedReading] = finishedReading;

    return mapaDeVersos;
  }
}