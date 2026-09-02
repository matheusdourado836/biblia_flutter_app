import 'dart:convert';

import 'package:biblia_flutter_app/helpers/app_logger.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/models/custom_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  FirebaseMessagingService();

  static final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    _registerToken();
    _tokenRefresh();
    _onMessage();
    _onMessageOpenedApp();
  }

  Future<void> _saveDeviceToken(String? token) async {
    if (token == null || token.isEmpty) return;

    await FirebaseFirestore.instance.collection('devices').doc(token).set(
        {'user_token': token, 'createdAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  Future<void> _tokenRefresh() async {
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (String? token) => _saveDeviceToken(token).catchError(
        (e, stack) => logError('Falha ao atualizar o token de push', e, stack),
      ),
      onError: (e, stack) => logError('Erro no stream de refresh do token de push', e, stack),
    );
  }

  Future<void> _registerToken() async {
    // No iOS o token APNS pode ainda não estar disponível no boot e o
    // getToken() falha com `apns-token-not-set`. O try/catch antigo não pegava
    // esse erro (ele vinha pelo Future, não pela chamada), então a exceção
    // escapava como erro assíncrono não tratado a cada inicialização.
    try {
      final token = await FirebaseMessaging.instance.getToken();
      await _saveDeviceToken(token);
    } catch (e, stack) {
      logError('Não foi possível registrar o token de push do dispositivo', e, stack);
    }
  }

  void _onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundNotification(message);
    });
  }

  void _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if(!message.data.containsKey("route")) {
        GoToVerseScreen().goToVersePage(
            message.data["bookName"],
            message.data["abbrev"],
            int.parse(message.data["bookIndex"]),
            int.parse(message.data["chapters"]),
            int.parse(message.data["chapter"]),
            int.parse(message.data["verseNumber"])
        );
      }else {
        navigatorKey!.currentState!.pushNamed(message.data["route"]);
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) => {
          if (message != null && !message.data.containsKey("route")) {
            GoToVerseScreen().goToVersePage(
              message.data["bookName"],
              message.data["abbrev"],
              int.parse(message.data["bookIndex"]),
              int.parse(message.data["chapters"]),
              int.parse(message.data["chapter"]),
              int.parse(message.data["verseNumber"])
            )
          }else if(message?.data.containsKey("route") ?? false) {
            navigatorKey!.currentState!.pushNamed(message!.data["route"], arguments: {"notification": true})
          }
        });
  }

  void _foregroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !message.data.containsKey("route")) {
      final jsonPayload = jsonEncode({
        "type": "verse",
        ...message.data,
      });

      _notificationService.showNotification(
        CustomNotification(
          id: android.hashCode,
          title: notification.title!,
          body: notification.body!,
          payload: jsonPayload,
        ),
        null
      );
    }else if(notification != null && android != null && message.data.containsKey("route")) {
      final jsonPayload = jsonEncode({
        "type": "route",
        ...message.data,
      });
      _notificationService.showNotification(
        CustomNotification(
          id: android.hashCode,
          title: notification.title!,
          body: notification.body!,
          payload: jsonPayload,
        ),
        message.data["route"]
      );
    }
  }
}
