import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/models/custom_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
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
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
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

  _onSelectedNotification(NotificationResponse? notificationResponse) {
    if(notificationResponse != null) {
      if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
        final payload = notificationResponse.payload;
        if(payload != null && payload.split(' ')[0] == 'route') {
          navigatorKey!.currentState!.pushNamed(payload.split(' ')[1]);
        }
        if(payload !=  null) {
          String bookName = payload.split(' ')[0];
          String abbrev = payload.split(' ')[1];
          int bookIndex = int.parse(payload.split(' ')[2]);
          int chapters = int.parse(payload.split(' ')[3]);
          int chapter = int.parse(payload.split(' ')[4]);
          int verseNumber = int.parse(payload.split(' ')[5]);
          if(payload.split(' ')[0].contains('ª') || payload.split(' ')[0].contains('º') || payload.split(' ')[0].contains('°')) {
            bookName = '${payload.split(' ')[0]} ${payload.split(' ')[1]}';
            abbrev = payload.split(' ')[2];
            bookIndex = int.parse(payload.split(' ')[3]);
            chapters = int.parse(payload.split(' ')[4]);
            chapter = int.parse(payload.split(' ')[5]);
            verseNumber = int.parse(payload.split(' ')[6]);
          }
          GoToVerseScreen().goToVersePage(
              bookName,
              abbrev,
              bookIndex,
              chapters,
              chapter,
              verseNumber
          );
        }
      }
    }
  }

  showNotification(CustomNotification notification, String? channelInfo) {
    final channel = (channelInfo == null) ? 'versiculo_diario' : channelInfo;
    androidNotificationDetails = AndroidNotificationDetails(
      '${channel}_notification', channel,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      colorized: true,
      color: Colors.brown
    );

    localNotificationsPlugin.show(
        notification.id,
        notification.title,
        notification.body,
        NotificationDetails(android: androidNotificationDetails),
        payload: notification.payload);
  }

  checkForNotification() async {
    final details = await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _onSelectedNotification(details.notificationResponse!);
    }
  }
}