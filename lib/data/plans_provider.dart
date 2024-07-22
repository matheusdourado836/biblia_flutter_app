import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/daily_reading_dao.dart';
import 'package:biblia_flutter_app/data/reading_progress_dao.dart';
import 'package:biblia_flutter_app/helpers/plan_type_to_days.dart';
import 'package:biblia_flutter_app/models/daily_read.dart';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/models/plan.dart';
import 'package:biblia_flutter_app/models/reading_plan.dart';
import 'package:biblia_flutter_app/services/plans_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_messaging_service.dart';
import '../services/notification_service.dart';

class PlansProvider extends ChangeNotifier {
  static final DailyReadingDao _dailyReadingDao = DailyReadingDao.instance;
  static final ReadingProgressDao _readingProgressDao = ReadingProgressDao();
  static final PlansService _plansService = PlansService();
  static final NotificationService notificationService = NotificationService();
  FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService(notificationService);
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  bool _loading = false;

  bool get loading => _loading;

  bool _planNotificationStatus = false;

  bool get planNotificationStatus => _planNotificationStatus;

  ReadingPlan? _currentPlan;

  ReadingPlan? get currentPlan => _currentPlan;

  List<Plan> _plans = [];

  List<Plan> get plans => _plans;

  final List<ReadingPlan> _readingPlans = [];

  List<ReadingPlan> get readingPlans => _readingPlans;

  List<DailyRead> _dailyReads = [];

  List<DailyRead> get dailyReads => _dailyReads;

  List<List<DailyRead>> _dailyReadsGrouped = [];

  List<List<DailyRead>> get dailyReadsGrouped => _dailyReadsGrouped;

  List<String> _chapters = [];

  List<String> get chapters => _chapters;

  List<List<String>> _chaptersDivided = [];

  List<List<String>> get chaptersDivided => _chaptersDivided;

  static final List<Plan> _staticList =  [
    Plan(label: 'Bíblia em 1 ano', description: 'Leia a Bíblia em 1 ano', imgPath: 'assets/images/santidade.png', planType: PlanType.ONE_YEAR, duration: 397, qtdChapters: 3),
    Plan(label: 'Bíblia toda em 3 meses', description: 'Leia a Bíblia em 3 meses', imgPath: 'assets/images/santidade.png', planType: PlanType.THREE_MONTHS, duration: 92, qtdChapters: 13),
    Plan(label: 'Novo testamento em 2 meses', description: 'Leia o novo testamento em 2 meses', imgPath: 'assets/images/santidade.png', planType: PlanType.TWO_MONTHS_NEW, duration: 66, qtdChapters: 4, isNewTestament: true),
    Plan(label: 'Antigo testamento em 6 meses', description: 'Leia o antigo testamento em 6 meses', imgPath: 'assets/images/santidade.png', planType: PlanType.SIX_MONTHS_OLD, duration: 186, qtdChapters: 5, bibleLength: 39),
  ];

  void getDailyReads({required int progressId}) async {
    _dailyReads = await _dailyReadingDao.getByType(progressId: progressId);
    transformList(_dailyReads);
    notifyListeners();
  }

  Future<void> getPlans() async {
    if(_plans.isEmpty) {
      _plans = await _plansService.getPlans() ?? _staticList;
      notifyListeners();
    }
    return;
  }

  Future<bool> checkPlanStartedBybType({required PlanType planType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getInt(planType.description);

    return result != null;
  }

  Future<bool> checkIfPlanStarted({required PlanType planType}) async {
    _currentPlan = null;
    _loading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final planCode = prefs.getInt(planType.description);
    if(planCode != null) {
      _currentPlan = await _readingProgressDao.find(planId: planType.code);
    }
    _loading = false;
    notifyListeners();
    return planCode != null;
  }

  Future<void> startReadingPlan({required Plan plan}) async {
    _loading = true;
    notifyListeners();
    subscribeUser(planType: plan.planType);
    generateChapters(planTypeToChapters(planType: plan.planType), plan.planType, bibleLength: plan.bibleLength, isNewTestament: plan.isNewTestament);
    await generateDailyReadings(plan.planType.code, plan.duration, plan.planType);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(plan.planType.description, plan.planType.code);
    _readingProgressDao.startReadingPlan(planId: plan.planType, durationDays: plan.duration);
    _currentPlan = await _readingProgressDao.find(planId: plan.planType.code);
    getDailyReads(progressId: plan.planType.code);
    _loading = false;
  }

  Future<void> checkPlanNotificationStatus({required PlanType planType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _planNotificationStatus = prefs.getBool('${planType.description}_notifications') ?? false;
    notifyListeners();
  }

  Future<void> updatePlanNotification({required PlanType planType, required bool status}) async {
    (status) ? subscribeUser(planType: planType) : unsubscribeUser(planType: planType);
    notifyListeners();
  }

  Future<void> generateDailyReadings(int progressId, int durationDays, PlanType planType) async {
    return await _dailyReadingDao.generateDailyReadings(progressId, durationDays, _chaptersDivided);
  }

  void generateChapters(int chaptersLength, PlanType planId, {int? bibleLength, bool? isNewTestament}) {
    _chapters = [];
    _chaptersDivided = [];
    _dailyReadsGrouped = [];
    final BibleData bibleData = BibleData();
    List<List<String>> partitions = [];
    final length = bibleLength ??= bibleData.data[0]["text"].length;
    final index = isNewTestament == null ? 0 : 39;

    for (var i = index; i < length; i++) {
      final book = bibleData.data[0]["text"][i];
      for (var j = 0; j < book["chapters"].length; j++) {
        _chapters.add('${book["name"]} ${j + 1}');
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

  Future<void> subscribeUser({required PlanType planType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    firebaseMessaging.subscribeToTopic('${planType.description}_sub');
    _plansService.subscribeUser(planType: planType);
    prefs.setBool('${planType.description}_notifications', true);
    _planNotificationStatus = true;
  }

  Future<void> unsubscribeUser({required PlanType planType}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    firebaseMessaging.unsubscribeFromTopic('${planType.description}_sub');
    _plansService.unsubscribeUser(planType: planType);
    prefs.setBool('${planType.description}_notifications', false);
    _planNotificationStatus = false;
  }

  void dropDb({required PlanType planType, required int progressId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for(var plan in PlanType.values) {
      if(plan == planType) {
        unsubscribeUser(planType: plan);
        prefs.remove(planType.description);
        _dailyReadingDao.dropDb(progressId: progressId);
        _readingProgressDao.dropDb(progressId: progressId);
        _currentPlan = null;
        notifyListeners();
      }
    }
  }
}