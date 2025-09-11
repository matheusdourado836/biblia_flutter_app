import 'dart:convert';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/models/custom_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidNotificationDetails;

  NotificationService() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupNotifications();
  }

  _setupNotifications() async {
    await _setupTimezone();
    await _initializeNotifications();
  }

  Future<void> _setupTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await localNotificationsPlugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: _onSelectedNotification,
    );
  }

  void _onSelectedNotification(NotificationResponse? notificationResponse) {
    if (notificationResponse?.payload?.isEmpty ?? true) return;

    try {
      final Map<String, dynamic> data = jsonDecode(notificationResponse!.payload!);

      if (data['type'] == 'route') {
        navigatorKey!.currentState!.pushNamedAndRemoveUntil(
          data['route'], (route) => false,
          arguments: {"notification": true},
        );
      } else if (data['type'] == 'verse') {
        GoToVerseScreen().goToVersePage(
          data['bookName'],
          data['abbrev'],
          int.parse(data['bookIndex'].toString()),
          int.parse(data['chapters'].toString()),
          int.parse(data['chapter'].toString()),
          int.parse(data['verseNumber'].toString()),
        );
      }
    } catch (e) {
      debugPrint('Erro ao tratar payload: $e');
    }
  }

  void showNotification(CustomNotification notification, String? channelInfo) {
    final channel = (channelInfo == null) ? 'versiculo_diario' : channelInfo;
    androidNotificationDetails = AndroidNotificationDetails(
      '${channel}_notification',
      channel,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      colorized: true,
      color: Colors.brown,
    );

    localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(android: androidNotificationDetails),
      payload: notification.payload,
    );
  }
}