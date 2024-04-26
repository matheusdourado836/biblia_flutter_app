import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/models/custom_notification.dart';
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
        if(payload !=  null) {
          GoToVerseScreen().goToVersePage(
              payload.split(' ')[0],
              payload.split(' ')[1],
              int.parse(payload.split(' ')[2]),
              int.parse(payload.split(' ')[3]),
              int.parse(payload.split(' ')[4]),
              int.parse(payload.split(' ')[5])
          );
        }
      }
    }
  }

  showNotification(CustomNotification notification) {
    androidNotificationDetails = const AndroidNotificationDetails(
        'versiculo_diario_notification', 'versiculo_diario',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true);

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