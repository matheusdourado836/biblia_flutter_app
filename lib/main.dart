import 'package:biblia_flutter_app/core/app_providers.dart';
import 'package:biblia_flutter_app/core/routes.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/themes/dark_theme.dart';
import 'package:biblia_flutter_app/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/services_initializer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
ThemeMode? _themeMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServicesInitializer.initialize();
  _themeMode = await ServicesInitializer.getThemeMode();
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://efdde2646a14d6b1bcd692e0cc099b51@o4507963534147584.ingest.us.sentry.io/4508399384133637';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    // Init your App.
    appRunner: () => runApp(
      MultiProvider(
        providers: appProviders,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<VersesProvider>(context, listen: false).loadUserData();
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    versionProvider.getPreferredVersion();
    final themeProvider = context.watch<ThemeProvider>();
    return Portal(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        themeMode: themeProvider.themeMode ?? _themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('pt')
        ],
        title: 'BibleWise',
        debugShowCheckedModeBanner: false,
        initialRoute: "home",
        routes: AppRoutes.routes,
        onGenerateRoute: (settings) => AppRoutes.generateRoute(settings),
      ),
    );
  }
}
