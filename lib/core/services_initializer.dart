import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/ai_helper.dart';
import '../helpers/app_logger.dart';
import '../data/database.dart';
import '../services/bible_service.dart';
import '../services/firebase_messaging_service.dart';
import '../data/bible_data.dart';
import '../helpers/version_to_name.dart';

class ServicesInitializer {
  static Future<void> initialize() async {
    // Inicializa anúncios
    MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ["2A2D11E674B401679B12723A6A640627"]),
    );

    // Carregar variáveis de ambiente
    await dotenv.load(fileName: ".env");

    // Banco de dados
    await DatabaseHelper.initializeDatabases();

    BibleService().checkInternetConnectivity().then((value) async {
      if (!value) return;
      try {
        final firebaseMessaging = FirebaseMessaging.instance;
        await firebaseMessaging.requestPermission();
        // No iOS o token APNS pode não estar pronto logo após a permissão e
        // subscribeToTopic falha com `apns-token-not-set`. Sem este try/catch
        // o erro escapava como exceção assíncrona não tratada a cada boot.
        await firebaseMessaging.subscribeToTopic("versiculo_diario");
        await FirebaseMessagingService().initialize();
      } catch (e, stack) {
        logError('Falha ao configurar as notificações push', e, stack);
      }
    });

    // Carrega apenas a versão de referência e a preferida do usuário.
    // As demais entram sob demanda (BibleData.ensureVersionLoaded).
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final preferred = prefs.getString('version');
    await BibleData().initialize(
      preferredVersion: preferred == null ? null : versionToName(preferred),
    );

    // Inicializa a IA
    AiHelper().initializeAi();
  }

  static Future<ThemeMode> getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('themeMode') == null || prefs.getBool('themeMode')!) ? ThemeMode.light : ThemeMode.dark;
  }
}