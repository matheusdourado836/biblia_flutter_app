import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/helpers/exception_dialog.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/chapter_screen.dart';
import 'package:biblia_flutter_app/screens/email_screen/email_screen.dart';
import 'package:biblia_flutter_app/screens/home_screen/home_screen.dart';
import 'package:biblia_flutter_app/screens/saved_verses_screen/saved_verses.dart';
import 'package:biblia_flutter_app/screens/search_screen/search_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:biblia_flutter_app/services/firebase_messaging_service.dart';
import 'package:biblia_flutter_app/services/notification_service.dart';
import 'package:biblia_flutter_app/themes/dark_theme.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/themes/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  NotificationService notificationService = NotificationService();
  FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService(notificationService);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  await firebaseMessaging.subscribeToTopic("versiculo_diario");
  await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  await firebaseMessagingService.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
            create: (context) => NotificationService()),
        ChangeNotifierProvider(create: (context) => SavedVersesProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SearchVersesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: themeProvider.themeMode,
      darkTheme: darkTheme,
      title: 'Bíblia Online',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      initialRoute: "home",
      routes: {
        "home": (context) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'chapter_screen') {
          Map<String, dynamic>? routeArgs =
              settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(builder: (context) {
            return ChapterScreen(
              bookName: routeArgs?['bookName'] as String,
              abbrev: routeArgs?['abbrev'],
              chapters: routeArgs?['chapters'],
            );
          });
        } else if (settings.name == 'verses_screen') {
          Map<String, dynamic>? map =
              settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(builder: (context) {
            try {
              return VersesScreen(
                bookName: map?["bookName"],
                abbrev: map?["abbrev"],
                chapters: map?["chapters"],
                chapter: map?["chapter"],
                verseNumber: map?["verseNumber"],
              );
            }catch (e) {
              return exceptionDialog(content: 'Não foi possível carregar o versículo\nErro: ${e.toString()}');
            }
          });
        } else if (settings.name == 'saved_verses') {
          return MaterialPageRoute(builder: (context) {
            return const SavedVerses();
          });
        } else if (settings.name == 'search_screen') {
          return MaterialPageRoute(builder: (context) {
            return const SearchScreen();
          });
        } else if (settings.name == 'email_screen') {
          return MaterialPageRoute(builder: (context) {
            return const EmailScreen();
          });
        }

        return null;
      },
    );
  }
}
