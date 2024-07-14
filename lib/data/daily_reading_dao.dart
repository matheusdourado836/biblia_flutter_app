import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

class DailyReadingDao {
  static final Database _plansInstance = DatabaseHelper.plansDatabase;
  static const String tableSql = '''
      CREATE TABLE $_tableName (
        $_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_progressId INTEGER NOT NULL,
        $_dayNumber INTEGER NOT NULL,
        $_chapter TEXT NOT NULL,
        $_completed INTEGER NOT NULL,
        FOREIGN KEY ($_progressId) REFERENCES $_readingProgress (id)
      )
    ''';

  static const String _id = 'id';
  static const String _tableName = 'daily_reading';
  static const String _progressId = 'progress_id';
  static const String _dayNumber = 'day_number';
  static const String _chapter = 'chapter';
  static const String _completed = 'completed';
  static const String _readingProgress = 'reading_progress';

  DailyReadingDao._privateConstructor();

  static final DailyReadingDao instance = DailyReadingDao._privateConstructor();

  Future<List<DailyRead>> getAll() async {
    List<DailyRead> dailyReads = [];
    final List<Map<String, dynamic>> result = await _plansInstance.query(_tableName);
    if(result.isNotEmpty) {
      for(var dailyRead in result) {
        dailyReads.add(DailyRead.fromJson(dailyRead));
      }
    }

    return dailyReads;
  }

  Future<List<DailyRead>> getByType({required int progressId}) async {
    List<DailyRead> dailyReads = [];
    final List<Map<String, dynamic>> result = await _plansInstance.query(
        _tableName,
      where: '$_progressId = ?',
      whereArgs: [progressId]
    );
    if(result.isNotEmpty) {
      for(var dailyRead in result) {
        dailyReads.add(DailyRead.fromJson(dailyRead));
      }
    }

    return dailyReads;
  }

  Future<void> generateDailyReadings(int progressId, int durationDays, List<List<String>> chapters) async {
    final List<Map<String, dynamic>> chaptersMap = [];
    for (int day = 0; day < durationDays; day++) {
      if(chapters.length > day) {
        for (String chapter in chapters[day]) {
          chaptersMap.add({
            'progress_id': progressId,
            'day_number': day + 1,
            'chapter': chapter,
            'completed': 0,
          });
          print('OLHA O CHAPTER AEEEE $chapter - DIA $day');
        }
      }
    }
    await _plansInstance.transaction((txn) async {
      for(var chapter in chaptersMap) {
        await txn.insert(_tableName, chapter);
      }
    });
  }

  Future<bool> markChapter(String chapter, {required int read, required int progressId}) async {
    await _plansInstance.update(
      _tableName,
      {_completed: read},
      where: '$_chapter = ? AND $_progressId = ?',
      whereArgs: [chapter, progressId],
    );

    return true;
  }

  void dropDb({required int progressId}) async {
    await _plansInstance.delete(_tableName, where: '$_progressId = ?', whereArgs: [progressId]);
  }
}