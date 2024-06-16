import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

class AnnotationsDao {
  static final Database _versesInstance = DatabaseHelper.versesDatabase;
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_annotationId TEXT, '
      '$_title TEXT, '
      '$_book TEXT, '
      '$_chapter INTEGER, '
      '$_verseStart INTEGER, '
      '$_verseEnd INTEGER, '
      '$_content TEXT)';

  static const String _tablename = 'annotationsTable';
  static const String _annotationId = 'annotationId';
  static const String _content = 'content';
  static const String _title = 'title';
  static const String _book = 'book';
  static const String _chapter = 'chapter';
  static const String _verseStart = 'verseStart';
  static const String _verseEnd = 'verseEnd';

  Future<int> save(Annotation annotation) async {
    var itemExists = await find(annotation.annotationId);
    Map<String, dynamic> annotationMap = toMap(annotation);

    if (itemExists.isEmpty) {
      return await _versesInstance.insert(_tablename, annotationMap);
    }
    return 0;
  }

  Future<int> updateAnnotation(String annotationId, String content) async {
    return await _versesInstance.rawUpdate(
        'UPDATE $_tablename SET $_content = ?  WHERE $_annotationId = ?', [content, annotationId]);
  }

  delete(String annotationId) async {
    return _versesInstance.delete(_tablename, where: '$_annotationId = ?', whereArgs: [annotationId]);
  }

  deleteAllAnnotations() async {
    return _versesInstance.delete(_tablename);
  }

  Future<List<Map<String, dynamic>>> find(String annotationId) async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(
      _tablename,
      where: '$_annotationId = ?',
      whereArgs: [annotationId],
    );

    return result;
  }

  Future<List<Annotation>?> findByTitle(String bookName, int chapter, int verse) async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(
      _tablename,
      where: '$_book = ? AND $_chapter = ? AND $_verseEnd = ?',
      whereArgs: [bookName, chapter, verse],
    );

    if(result.isEmpty) {
      return null;
    }

    return toList(result);
  }

  Future<Annotation?> checkByTitle(String bookName, int chapter, int verse) async {
    final List<Map<String, dynamic>> result = await _versesInstance.query(
      _tablename,
      where: '$_book = ? AND $_chapter = ? AND $_verseEnd = ?',
      whereArgs: [bookName, chapter, verse],
    );

    if(result.isEmpty) {
      return null;
    }

    return toList(result).first;
  }

  Future<List<Annotation>> findAll() async {
    final List<Map<String, dynamic>> result =
    await _versesInstance.query(_tablename);

    return toList(result);
  }

  List<Annotation> toList(List<Map<String, dynamic>> mapaDeAnotacoes) {
    final List<Annotation> annotations = [];
    for (Map<String, dynamic> linha in mapaDeAnotacoes) {
      final Annotation annotation = Annotation(annotationId: linha[_annotationId], title: linha[_title], content: linha[_content], book: linha[_book], chapter: linha[_chapter], verseStart: linha[_verseStart], verseEnd: linha[_verseEnd]);
      annotations.add(annotation);
    }

    return annotations;
  }

  Map<String, dynamic> toMap(Annotation annotation) {
    final Map<String, dynamic> mapaDeVersos = {};
    mapaDeVersos[_annotationId] = annotation.annotationId;
    mapaDeVersos[_title] = annotation.title;
    mapaDeVersos[_book] = annotation.book;
    mapaDeVersos[_content] = annotation.content;
    mapaDeVersos[_chapter] = annotation.chapter;
    mapaDeVersos[_verseStart] = annotation.verseStart;
    mapaDeVersos[_verseEnd] = annotation.verseEnd;

    return mapaDeVersos;
  }
}