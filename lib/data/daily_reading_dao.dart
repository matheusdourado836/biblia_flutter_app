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
    for (int day = 0; day < durationDays; day++) {
      for (String chapter in chapters[day]) {
        await _plansInstance.insert(_tableName, {
          'progress_id': progressId,
          'day_number': day + 1,
          'chapter': chapter,
          'completed': 0,
        });
      }
    }
  }

  Future<bool> markChapter(String chapter, {required int read, required int progressId}) async {
    bool allChaptersRead = false;

    await _plansInstance.update(
      _tableName,
      {_completed: read},
      where: '$_chapter = ? AND $_progressId = ?',
      whereArgs: [chapter, progressId],
    );

    return true;

    // // Verifica se todos os capítulos do dia foram lidos
    // List<Map<String, dynamic>> chapters = await bancoDeDados.query(
    //   _tableName,
    //   where: '$_progressId = ? AND $_dayNumber = ?',
    //   whereArgs: [progressId, dayNumber],
    // );
    //
    // print('CHAPTERSSSSSSS $chapters');
    //
    // allChaptersRead = chapters.every((chapter) => chapter['completed'] == 1);
    //
    // // if (allChaptersRead) {
    // //   // Atualiza o progresso diário
    // //   await bancoDeDados.rawUpdate(
    // //       'UPDATE $_tableName SET $_completed = ? WHERE $_progressId = ? AND $_dayNumber = ?', [1, progressId, dayNumber]);
    // // }
    //
    // return allChaptersRead;
  }

  void dropDb() async {
    await _plansInstance.delete(_tableName);
  }

}