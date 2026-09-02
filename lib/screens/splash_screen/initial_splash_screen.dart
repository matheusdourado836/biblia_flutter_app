import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../helpers/go_to_verse_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleNotificationRedirect());
  }

  void _handleNotificationRedirect() {
    if (!mounted) return;
    final message = widget.initialMessage;

    if (message == null) {
      Navigator.of(context).pushReplacementNamed("home");
      return;
    }

    if (message.data.containsKey('route')) {
      Navigator.of(context).pushReplacementNamed(
        message.data['route'],
        arguments: {"notification": true},
      );
      return;
    }

    // Abre a home antes do versiculo para que exista rota de retorno.
    Navigator.of(context).pushReplacementNamed("home");
    GoToVerseScreen().goToVersePage(
      message.data["bookName"],
      message.data["abbrev"],
      int.parse(message.data["bookIndex"]),
      int.parse(message.data["chapters"]),
      int.parse(message.data["chapter"]),
      int.parse(message.data["verseNumber"]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
