import 'package:biblia_flutter_app/data/database.dart';
import 'package:sqflite/sqflite.dart';

class BooksDao {
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_bookName TEXT, '
      '$_finishedReading INTEGER)';

  static const String _tablename = 'bookstable';
  static const String _bookName = 'bookName';
  static const String _finishedReading = 'finishedReading';

  save(String bookName, int finishedReading) async {
    final Database bancoDeDados = await getDatabase();
    var itemExists = await find(bookName);
    Map<String, dynamic> bookMap = toMap(bookName, finishedReading);

    if (itemExists.isEmpty) {
      return await bancoDeDados.insert(_tablename, bookMap);
    }
  }

  delete(String bookName) async {
    final Database bancoDeDados = await getDatabase();

    return bancoDeDados
        .delete(_tablename, where: '$_bookName = ?', whereArgs: [bookName]);
  }

  Future<List<Map<String, dynamic>>> findAll() async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result =
        await bancoDeDados.query(_tablename);

    return result;
  }

  Future<List<Map<String, dynamic>>> find(String bookName) async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result = await bancoDeDados.query(
      _tablename,
      where: '$_bookName = ?',
      whereArgs: [bookName],
    );

    return result;
  }

  List<dynamic> toList(List<Map<String, dynamic>> mapaDeVersos) {
    final List<dynamic> verses = [];
    for (Map<String, dynamic> linha in mapaDeVersos) {
      verses.add('${linha[_bookName]}\n${linha[_finishedReading]}');
    }

    return verses;
  }

  Map<String, dynamic> toMap(String bookName, int finishedReading) {
    final Map<String, dynamic> mapaDeVersos = {};
    mapaDeVersos[_bookName] = bookName;
    mapaDeVersos[_finishedReading] = finishedReading;

    return mapaDeVersos;
  }
}
