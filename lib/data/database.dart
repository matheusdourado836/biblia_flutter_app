import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/data/daily_reading_dao.dart';
import 'package:biblia_flutter_app/data/reading_progress_dao.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _versesDbInstance;
  static Database? _plansDbInstance;

  static Future<void> initializeDatabases() async {
    _versesDbInstance = await _getDatabase();
    _plansDbInstance = await _getPlansDatabase();
  }

  static Database get versesDatabase {
    if (_versesDbInstance == null) {
      throw Exception("Verses database has not been initialized");
    }
    return _versesDbInstance!;
  }

  static Database get plansDatabase {
    if (_plansDbInstance == null) {
      throw Exception("Plans database has not been initialized");
    }
    return _plansDbInstance!;
  }
}

Future<Database> _getDatabase() async {
  final String path = join(await getDatabasesPath(), 'verses.db');

  return openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(VersesDao.tableSql);
        db.execute(BooksDao.tableSql);
        db.execute(AnnotationsDao.tableSql);
      },
      version: 2
  );
}

Future<Database> _getPlansDatabase() async {
  final String path = join(await getDatabasesPath(), 'plans.db');

  return openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(ReadingProgressDao.tableSql);
        db.execute(DailyReadingDao.tableSql);
      },
      version: 1
  );
}