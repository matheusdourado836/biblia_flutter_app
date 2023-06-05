import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'verses.db');

  return openDatabase(path, onCreate: (db, version) {
    db.execute(VersesDao.tableSql);
    db.execute(BooksDao.tableSql);
    db.execute(AnnotationsDao.tableSql);
  }, version: 1);
}