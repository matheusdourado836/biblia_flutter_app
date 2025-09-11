import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../helpers/go_to_verse_screen.dart';
import '../../main.dart';

class InitialSplashScreen extends StatefulWidget {
  final RemoteMessage? initialMessage;

  const InitialSplashScreen({super.key, this.initialMessage});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _handleNotificationRedirect);
  }

  void _handleNotificationRedirect() {
    final message = widget.initialMessage;

    showDialog(context: context, builder: (context) => AlertDialog(
      content: Text("Você recebeu uma notificação! ${message?.data}"),
    ));

    if (message != null) {
      if (message.data.containsKey('route')) {
        navigatorKey!.currentState!.pushReplacementNamed(
          message.data['route'],
          arguments: {"notification": true},
        );
      } else {
        GoToVerseScreen().goToVersePage(
          message.data["bookName"],
          message.data["abbrev"],
          int.parse(message.data["bookIndex"]),
          int.parse(message.data["chapters"]),
          int.parse(message.data["chapter"]),
          int.parse(message.data["verseNumber"]),
        );
      }
    } else {
      showDialog(context: context, builder: (context) => AlertDialog(
        content: Text("Você recebeu uma notificação! ${message?.data}"),
      ));
      // Redireciona para a rota padrão
      Navigator.of(context).pushReplacementNamed("home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}