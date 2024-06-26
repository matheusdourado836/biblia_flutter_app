import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/models/reading_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

class ReadingProgressDao {
  static final Database _plansInstance = DatabaseHelper.plansDatabase;
  static const String tableSql = '''
      CREATE TABLE $_tableName (
        $_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $_planId INTEGER NOT NULL,
        $_durationDays INTEGER NOT NULL,
        $_startDate TEXT NOT NULL,
        $_currentDay INTEGER NOT NULL,
        $_completed INTEGER NOT NULL
      )
    ''';

  static const String _id = 'id';
  static const String _tableName = 'reading_progress';
  static const String _planId = 'plan_id';
  static const String _durationDays = 'duration_days';
  static const String _startDate = 'start_date';
  static const String _currentDay = 'current_day';
  static const String _completed = 'completed';

  Future<List<ReadingPlan>> findAll() async {
    final List<ReadingPlan> readingPlans = [];
    final List<Map<String, dynamic>> result = await _plansInstance.query(_tableName);
    if(result.isNotEmpty) {
      for(var readingPlan in result) {
        readingPlans.add(ReadingPlan.fromJson(readingPlan));
      }
    }

    return readingPlans;
  }

  Future<ReadingPlan?> find({required int planId}) async {
    ReadingPlan? readingPlan;
    final List<Map<String, dynamic>> result = await _plansInstance.query(
      _tableName,
      where: '$_planId = ?',
      whereArgs: [planId]
    );

    if(result.isNotEmpty) {
      readingPlan = ReadingPlan.fromJson(result.first);
    }

    return readingPlan;
  }

  Future<int> startReadingPlan({required PlanType planId, required int durationDays}) async {
    final startDate = DateTime.now().toIso8601String();

    int progressId = await _plansInstance.insert(
      _tableName,
      {
        'plan_id': planId.code,
        'start_date': startDate,
        'duration_days': durationDays,
        'current_day': 0,
        'completed': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return progressId;
  }

  Future<int> updateCurrentDay({required int planId, required int action}) async {

    // Obtém o progresso atual
    List<Map<String, dynamic>> progress = await _plansInstance.query(
      _tableName,
      where: '$_planId = ?',
      whereArgs: [planId],
    );

    int currentDay = progress.first[_currentDay];

    return await _plansInstance.rawUpdate('UPDATE $_tableName SET $_currentDay = ? WHERE $_planId = ?', [action == 0 ? currentDay + 1 : currentDay - 1, planId]);
  }

  Future<int> updateCurrentDayRaw({required int planId, required int qtdDays}) async {
    return await _plansInstance.rawUpdate('UPDATE $_tableName SET $_currentDay = ? WHERE $_planId = ?', [qtdDays, planId]);
  }

  void dropDb({required int progressId}) async {
    await _plansInstance.delete(_tableName, where: '$_planId = ?', whereArgs: [progressId]);
  }
}