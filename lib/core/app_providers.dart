import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/chapters_provider.dart';
import '../data/verses_provider.dart';
import '../data/theme_provider.dart';
import '../data/search_verses_provider.dart';
import '../data/version_provider.dart';
import '../data/devocional_provider.dart';
import '../data/plans_provider.dart';
import '../data/reading_groups_provider.dart';
import '../services/notification_service.dart';

final List<SingleChildWidget> appProviders = [
  Provider<NotificationService>(create: (context) => NotificationService()),
  ChangeNotifierProvider(create: (context) => ChaptersProvider()),
  ChangeNotifierProvider(create: (context) => VersesProvider()),
  ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ChangeNotifierProvider(create: (context) => SearchVersesProvider()),
  ChangeNotifierProvider(create: (context) => VersionProvider()),
  ChangeNotifierProvider(create: (context) => DevocionalProvider()),
  ChangeNotifierProvider(create: (context) => PlansProvider()),
  ChangeNotifierProvider(create: (context) => ReadingGroupsProvider()),
];