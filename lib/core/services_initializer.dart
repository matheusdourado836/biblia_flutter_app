import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/ai_helper.dart';
import '../data/database.dart';
import '../firebase_options.dart';
import '../services/bible_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_messaging_service.dart';
import '../data/bible_data.dart';

class ServicesInitializer {
  static Future<void> initialize() async {
    // Inicializa anúncios
    MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ["2A2D11E674B401679B12723A6A640627"]),
    );

    // Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");

    // Banco de dados
    await DatabaseHelper.initializeDatabases();

    // Notificações
    NotificationService notificationService = NotificationService();
    FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService(notificationService);

    await firebaseMessagingService.initialize();

    BibleService().checkInternetConnectivity().then((value) async {
      if (value) {
        NotificationService notificationService = NotificationService();
        FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService(notificationService);
        FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
        await firebaseMessaging.requestPermission();
        firebaseMessaging.subscribeToTopic("versiculo_diario");
        firebaseMessagingService.initialize();
      }
    });

    // Carregar a Bíblia
    BibleData bibleData = BibleData();
    await bibleData.loadBibleData(['nvi', 'acf', 'ntlh', 'aa', 'en_kjv']);

    // Inicializa a IA
    AiHelper().initializeAi();
  }

  static Future<ThemeMode> getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('themeMode') == null || prefs.getBool('themeMode')!) ? ThemeMode.light : ThemeMode.dark;
  }
}