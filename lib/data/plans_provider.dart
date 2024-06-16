import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/daily_reading_dao.dart';
import 'package:biblia_flutter_app/data/reading_progress_dao.dart';
import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/models/reading_plan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlansProvider extends ChangeNotifier {
  static final DailyReadingDao _dailyReadingDao = DailyReadingDao.instance;
  static final ReadingProgressDao _readingProgressDao = ReadingProgressDao();

  bool _loading = false;

  bool get loading => _loading;

  ReadingPlan? _currentPlan;

  ReadingPlan? get currentPlan => _currentPlan;

  List<ReadingPlan> _readingPlans = [];

  List<ReadingPlan> get readingPlans => _readingPlans;

  List<DailyRead> _dailyReads = [];

  List<DailyRead> get dailyReads => _dailyReads;

  List<List<DailyRead>> _dailyReadsGrouped = [];

  List<List<DailyRead>> get dailyReadsGrouped => _dailyReadsGrouped;

  bool _startedOneYear = false;

  bool get startedOneYear => _startedOneYear;

  bool _startedThreeMonths = false;

  bool get startedThreeMonths => _startedThreeMonths;

  List<String> _chapters = [];

  List<String> get chapters => _chapters;

  List<List<String>> _chaptersDivided = [];

  List<List<String>> get chaptersDivided => _chaptersDivided;

  void getAllReadingPlans() async {
    _readingPlans = await _readingProgressDao.findAll();
    notifyListeners();
  }

  void getDailyReads({required int progressId}) async {
    // _loading = true;
    _currentPlan = await _readingProgressDao.find(planId: 0);
    _dailyReads = await _dailyReadingDao.getByType(progressId: progressId);
    transformList(_dailyReads);
    // _loading = false;
    notifyListeners();
  }

  Future<bool> checkPlanStartedBybType({required PlanType planType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getInt(planType.description);

    return result != null;
  }

  void checkIfPlanStarted({required PlanType planType}) async {
    _loading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(planType == PlanType.ONE_YEAR) {
      final oneYearCode = prefs.getInt("one_year");
      (oneYearCode == null) ? _startedOneYear = false : _startedOneYear = true;
      _currentPlan = await _readingProgressDao.find(planId: 0);
      notifyListeners();
    }else if(planType == PlanType.THREE_MONTHS) {
      final threeMonthsCode = prefs.getInt("three_months");
      (threeMonthsCode == null) ? _startedThreeMonths = false : _startedThreeMonths = true;
      _currentPlan = await _readingProgressDao.find(planId: 1);
      notifyListeners();
    }
    _loading = false;
    print('LOADING $_loading /// ${_dailyReadsGrouped.length} /// $_currentPlan');
    notifyListeners();
  }

  Future<void> startReadingPlan({required PlanType planId}) async {
    _loading = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    (planId.code == 0)
        ? prefs.setInt("one_year", planId.code).whenComplete(() => _startedOneYear = true)
        : prefs.setInt("three_months", planId.code).whenComplete(() => _startedThreeMonths = true);
    await Future.wait([
      _readingProgressDao.startReadingPlan(planId: planId),
      generateDailyReadings(planId.code, planTypeToDays(planType: planId), planId)
    ]);
    _loading = false;
    getDailyReads(progressId: planId.code);
  }

  Future<void> generateDailyReadings(int progressId, int durationDays, PlanType planType) async {
    generateChapters(planTypeToChapters(planType: planType));

    return await _dailyReadingDao.generateDailyReadings(progressId, durationDays, _chaptersDivided);
  }

  void generateChapters(int chaptersLength) {
    _chapters = [];
    _chaptersDivided = [];
    _dailyReadsGrouped = [];
    final BibleData bibleData = BibleData();
    List<List<String>> partitions = [];

    for (var book in bibleData.data[0]) {
      for (var i = 0; i < book["chapters"].length; i++) {
        _chapters.add('${book["name"]} ${i + 1}');
      }
    }

    for (int i = 0; i < _chapters.length; i += chaptersLength) {
      int end = (i + chaptersLength < _chapters.length) ? i + chaptersLength : _chapters.length;
      partitions.add(_chapters.sublist(i, end));
    }

    _chaptersDivided = partitions;
  }

  void checkIfCompletedDailyRead({required int planId, required qtdChapterRequired}) {
    int qtdDaysCompleted = 0;
    for(var dailyRead in dailyReadsGrouped) {
      if(dailyRead.where((element) => element.completed == 1).length == qtdChapterRequired) {
       qtdDaysCompleted++;
      }
    }

    updateCurrentDayRaw(planId: planId, qtdDays: qtdDaysCompleted).then((value) => value > 0 ? notifyListeners() : null);
  }

  Future<bool> markChapter(String chapter, {required int read, required int progressId, bool? update}) async {
    return await _dailyReadingDao.markChapter(chapter, progressId: progressId, read: read).whenComplete(() => (update ?? false) ? notifyListeners() : null);
  }

  void transformList(List<DailyRead> data) {
    _dailyReadsGrouped = [];
    Map<int, List<DailyRead>> groupedByDay = {};
    Set<String> uniqueChapters = {};
    for (var item in data) {
      int dayNumber = item.dayNumber!;
      if (!groupedByDay.containsKey(dayNumber)) {
        groupedByDay[dayNumber] = [];
      }
      if (!uniqueChapters.contains(item.chapter)) {
        groupedByDay[dayNumber]?.add(item);
        uniqueChapters.add(item.chapter!);
      }
    }

    _dailyReadsGrouped = groupedByDay.values.toList();
  }

  Future<ReadingPlan?> findReadingPlan({required int planId}) async {
    return await _readingProgressDao.find(planId: planId);
  }

  Future<int> updateCurrentDay({required int planId, required int action}) async {
    return await _readingProgressDao.updateCurrentDay(planId: planId, action: action);
  }

  Future<int> updateCurrentDayRaw({required int planId, required int qtdDays}) async {
    return await _readingProgressDao.updateCurrentDayRaw(planId: planId, qtdDays: qtdDays);
  }

  void dropDb() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("one_year");
    prefs.remove("three_months");
    _startedOneYear = false;
    _startedThreeMonths = false;
    _dailyReadingDao.dropDb();
    notifyListeners();
    return _readingProgressDao.dropDb();
  }
}