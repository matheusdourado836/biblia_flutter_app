import 'package:biblia_flutter_app/data/database.dart';
import 'package:biblia_flutter_app/models/annotation_model.dart';
import 'package:sqflite/sqflite.dart';

class AnnotationsDao {
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

  Future<int> save(AnnotationModel annotation) async {
    final Database bancoDeDados = await getDatabase();
    var itemExists = await find(annotation.annotationId);
    Map<String, dynamic> annotationMap = toMap(annotation);

    if (itemExists.isEmpty) {
      return await bancoDeDados.insert(_tablename, annotationMap);
    }
    return 0;
  }

  Future<int> updateAnnotation(String annotationId, String content) async {
    final Database bancoDeDados = await getDatabase();

    return await bancoDeDados.rawUpdate(
        'UPDATE $_tablename SET $_content = ?  WHERE $_annotationId = ?', [content, annotationId]);
  }

  delete(String annotationId) async {
    final Database bancoDeDados = await getDatabase();

    return bancoDeDados.delete(_tablename, where: '$_annotationId = ?', whereArgs: [annotationId]);
  }

  deleteAllAnnotations() async {
    final Database bancoDeDados = await getDatabase();

    return bancoDeDados.delete(_tablename);
  }

  Future<List<Map<String, dynamic>>> find(String annotationId) async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result = await bancoDeDados.query(
      _tablename,
      where: '$_annotationId = ?',
      whereArgs: [annotationId],
    );

    return result;
  }

  Future<List<AnnotationModel>?> findByTitle(String title) async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result = await bancoDeDados.query(
      _tablename,
      where: '$_title = ?',
      whereArgs: [title],
    );

    if(result.isEmpty) {
      return null;
    }

    return toList(result);
  }

  Future<bool> checkByTitle(String title) async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result = await bancoDeDados.query(
      _tablename,
      where: '$_title = ?',
      whereArgs: [title],
    );

    if(result.isEmpty) {
      return false;
    }

    return true;
  }

  Future<List<AnnotationModel>> findAll() async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result =
    await bancoDeDados.query(_tablename);

    return toList(result);
  }

  List<AnnotationModel> toList(List<Map<String, dynamic>> mapaDeAnotacoes) {
    final List<AnnotationModel> annotations = [];
    for (Map<String, dynamic> linha in mapaDeAnotacoes) {
      final AnnotationModel annotation = AnnotationModel(annotationId: linha[_annotationId], title: linha[_title], content: linha[_content], book: linha[_book], chapter: linha[_chapter], verseStart: linha[_verseStart], verseEnd: linha[_verseEnd]);
      annotations.add(annotation);
    }

    return annotations;
  }

  Map<String, dynamic> toMap(AnnotationModel annotation) {
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