import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/annotation_widget.dart';
import 'package:biblia_flutter_app/screens/annotations_screen/annotations_screen.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/chapter_screen.dart';
import 'package:biblia_flutter_app/screens/home_screen/home_screen.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/random_verse_widget.dart';
import 'package:biblia_flutter_app/screens/saved_verses_screen/saved_verses.dart';
import 'package:biblia_flutter_app/screens/search_screen/search_screen.dart';
import 'package:biblia_flutter_app/screens/settings_screen/settings.dart';
import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verse_with_background.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:biblia_flutter_app/services/firebase_messaging_service.dart';
import 'package:biblia_flutter_app/services/notification_service.dart';
import 'package:biblia_flutter_app/themes/dark_theme.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/themes/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/bible_data.dart';
import 'firebase_options.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
ThemeMode? _themeMode;
BibleData bibleData = BibleData();
int screenWidth = 0;

void main() async {
  Animate.restartOnHotReload = true;
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ["2A2D11E674B401679B12723A6A640627"]));
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  _themeMode = (prefs.getBool('themeMode') == null || prefs.getBool('themeMode')!) ? ThemeMode.light : ThemeMode.dark;
  await dotenv.load(fileName: ".env");
  await bibleData.loadBibleData(
    ['nvi', 'acf', 'aa', 'en_bbe', 'en_kjv', 'es_rvr', 'el_greek']
  );
  BibleService().checkInternetConnectivity().then((value) async {
    if(value) {
      NotificationService notificationService = NotificationService();
      FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService(notificationService);
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      firebaseMessaging.subscribeToTopic("versiculo_diario");
      firebaseMessagingService.initialize();
    }
  });
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
            create: (context) => NotificationService()),
        ChangeNotifierProvider(create: (context) => ChaptersProvider()),
        ChangeNotifierProvider(create: (context) => VersesProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SearchVersesProvider()),
        ChangeNotifierProvider(create: (context) => VersionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width.round();
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<VersesProvider>(context, listen: false).loadUserData();
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: (themeProvider.themeMode == null) ? _themeMode : themeProvider.themeMode,
      darkTheme: darkTheme,
      title: 'BibleWise',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      initialRoute: "home",
      routes: {
        "annotations_screen": (context) => const AnnotationsScreen(),
        "saved_verses": (context) => const SavedVerses(),
        "search_screen": (context) => const SearchScreen(),
        "random_verse_screen": (context) => const RandomVerseScreen(),
        "settings": (context) => const SettingsScreen()
      },
      onGenerateRoute: (settings) {
        if(settings.name == 'home') {
          return PageTransition(child: const HomeScreen(), type: PageTransitionType.bottomToTop, duration: 400.ms);
        }
        if (settings.name == 'chapter_screen') {
          Map<String, dynamic>? routeArgs =
              settings.arguments as Map<String, dynamic>?;
          return PageTransition(
            child: ChapterScreen(
              bookName: routeArgs?['bookName'] as String,
              abbrev: routeArgs?['abbrev'],
              bookIndex: routeArgs?['bookIndex'],
              chapters: routeArgs?['chapters'],
            ),
            duration: 500.ms,
            type: PageTransitionType.rightToLeftWithFade,
          );
        } else if (settings.name == 'verses_screen') {
          Map<String, dynamic>? map =
              settings.arguments as Map<String, dynamic>?;
          return PageTransition(
            child: VersesScreen(
              bookName: map?["bookName"],
              abbrev: map?["abbrev"],
              bookIndex: map?["bookIndex"],
              chapters: map?["chapters"],
              chapter: map?["chapter"],
              verseNumber: map?["verseNumber"],
            ),
            type: PageTransitionType.rightToLeftWithFade,
            duration: 500.ms
          );
        } else if(settings.name == 'verse_with_background') {
          Map<String, dynamic>? map =
          settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(builder: (context) {
            return VerseWithBackground(
                bookName: map?["bookName"],
                chapter: map?["chapter"],
                verseStart: map?["verseStart"],
                verseEnd: map?["verseEnd"],
                content: map?["content"]
            );
          });
        } else if (settings.name == 'annotation_widget') {
          Map<String, dynamic>? map =
          settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(builder: (context) {
            return AnnotationWidget(
              annotation: map?["annotation"],
              verses: map?["verses"],
              isEditing: map?["isEditing"],
            );
          });
        }

        return null;
      },
    );
  }
}
