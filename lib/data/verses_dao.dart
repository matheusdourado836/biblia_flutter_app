import 'package:biblia_flutter_app/models/verse.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

class VersesDao {
  static final Database _versesInstance = DatabaseHelper.versesDatabase;
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_verse TEXT, '
      '$_verseColor TEXT, '
      '$_bookName TEXT, '
      '$_version INTEGER, '
      '$_chapter INTEGER, '
      '$_verseNumber INTEGER)';

  static const String _tablename = 'versetable';
  static const String _verse = 'verse';
  static const String _verseColor = 'verseColor';
  static const String _bookName = 'bookName';
  static const String _version = 'version';
  static const String _chapter = 'chapter';
  static const String _verseNumber = 'verseNumber';

  Future<int> save(VerseModel verse) async {
    var itemExists = await find(verse.verse);
    Map<String, dynamic> verseMap = toMap(verse);

    if (itemExists.isEmpty) {
      return await _versesInstance.insert(_tablename, verseMap);
    }
    return 0;
  }

  Future<int> saveChapter(VerseModel verse) async {
    var itemExists = await find(verse.chapter.toString());
    Map<String, dynamic> verseMap = toMap(verse);

    if (itemExists.isEmpty) {
      return await _versesInstance.insert(_tablename, verseMap);
    }
    return 0;
  }

  Future<List<VerseModel>> findAll() async {
    final List<Map<String, dynamic>> result =
    await _versesInstance.query(_tablename);

    return toList(result);
  }

  Future<List<VerseModel>> find(String verse) async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(
      _tablename,
      where: '$_verse = ?',
      whereArgs: [verse],
    );

    return toList(result);
  }

  updateColor(String verse, String newColor) async {
    return await _versesInstance.rawUpdate(
        'UPDATE $_tablename SET $_verseColor = ? WHERE $_verse = ?', [newColor, verse]);
  }

  delete(String verse) async {
    return _versesInstance.delete(_tablename, where: '$_verse = ?', whereArgs: [verse]);
  }

  deleteAllVerses() async {
    return _versesInstance.delete(_tablename);
  }

  List<VerseModel> toList(List<Map<String, dynamic>> mapaDeVersos) {
    final List<VerseModel> verses = [];
    for (Map<String, dynamic> linha in mapaDeVersos) {
      final VerseModel verse =
      VerseModel(verse: linha[_verse], verseColor: linha[_verseColor], book: linha[_bookName], version: linha[_version], chapter: linha[_chapter], verseNumber: linha[_verseNumber]);
      verses.add(verse);
    }

    return verses;
  }

  Map<String, dynamic> toMap(VerseModel verse) {
    final Map<String, dynamic> mapaDeVersos = {};
    mapaDeVersos[_verse] = verse.verse;
    mapaDeVersos[_verseColor] = verse.verseColor;
    mapaDeVersos[_bookName] = verse.book;
    mapaDeVersos[_version] = verse.version;
    mapaDeVersos[_chapter] = verse.chapter;
    mapaDeVersos[_verseNumber] = verse.verseNumber;

    return mapaDeVersos;
  }
}