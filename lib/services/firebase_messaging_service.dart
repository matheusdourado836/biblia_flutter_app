import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/models/custom_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    _registerToken();
    _tokenRefresh();
    _onMessage();
    _onMessageOpenedApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _tokenRefresh() async {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((String? token) {
        assert(token != null);

        FirebaseFirestore.instance.collection('devices').doc(token).set(
            {'user_token': token, 'createdAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
      });
    }catch (e) {
      return alertDialog(title: 'Dispositivo sem conexão com a internet', content: 'parece que você está sem internet, não será possível receber notificações(caso permitido)');
    }
  }

  Future<void> _registerToken() async {
    try {
      FirebaseMessaging.instance.getToken().then((String? token) {
        assert(token != null);

        FirebaseFirestore.instance.collection('devices').doc(token).set(
            {'user_token': token, 'createdAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
      });
    }catch (e) {
      return alertDialog(title: 'Dispositivo sem conexão com a internet', content: 'parece que você está sem internet, não será possível receber notificações(caso permitido)');
    }
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundNotification(message);
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      GoToVerseScreen().goToVersePage(
          message.data["bookName"],
          message.data["abbrev"],
          int.parse(message.data["chapters"]),
          int.parse(message.data["bookIndex"]),
          int.parse(message.data["chapter"]),
          int.parse(message.data["verse"]));
    });
    FirebaseMessaging.instance.getInitialMessage().then((value) => {
          if (value != null)
            {
              GoToVerseScreen().goToVersePage(
                  value.data["bookName"],
                  value.data["abbrev"],
                  int.parse(value.data["chapters"]),
                  int.parse(value.data["bookIndex"]),
                  int.parse(value.data["chapter"]),
                  int.parse(value.data["verse"]))
            }
        });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage? message) async {
    if (message != null) {
      GoToVerseScreen().goToVersePage(
          message.data["bookName"],
          message.data["abbrev"],
          int.parse(message.data["chapters"]),
          int.parse(message.data["bookIndex"]),
          int.parse(message.data["chapter"]),
          int.parse(message.data["verse"]));
    }
  }

  _foregroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      String bookName = message.data["bookName"];
      String abbrev = message.data["abbrev"];
      String chapters = message.data["chapters"];
      String bookIndex = message.data["bookIndex"];
      String chapter = message.data["chapter"];
      String verse = message.data["verse"];
      _notificationService.showNotification(
        CustomNotification(
          id: android.hashCode,
          title: notification.title!,
          body: notification.body!,
          payload: '$bookName $abbrev $chapters $bookIndex $chapter $verse',
        ),
      );
    }
  }
}
