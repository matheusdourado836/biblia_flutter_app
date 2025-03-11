import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../helpers/annotation_widget.dart';
import '../screens/ai_screen/ai_screen.dart';
import '../screens/annotations_screen/annotations_screen.dart';
import '../screens/chapter_screen/chapter_screen.dart';
import '../screens/devocionais_screen/community/devocional_selected.dart';
import '../screens/devocionais_screen/community/feed_screen.dart';
import '../screens/devocionais_screen/devocionais_screen.dart';
import '../screens/devocionais_screen/plans/init_plan_base_screen.dart';
import '../screens/devocionais_screen/reading_groups/chat_screen.dart';
import '../screens/devocionais_screen/reading_groups/create_group_screen.dart';
import '../screens/devocionais_screen/reading_groups/day_selected_screen.dart';
import '../screens/devocionais_screen/reading_groups/group_admin_config_screen.dart';
import '../screens/devocionais_screen/reading_groups/group_selected_admin_screen.dart';
import '../screens/devocionais_screen/reading_groups/group_selected_screen.dart';
import '../screens/devocionais_screen/reading_groups/initial_screen.dart';
import '../screens/devocionais_screen/reading_groups/login_screen.dart';
import '../screens/devocionais_screen/reading_groups/solicitations_screen.dart';
import '../screens/devocionais_screen/reading_groups/user_config_screen.dart';
import '../screens/devocionais_screen/reading_groups/user_home_screen.dart';
import '../screens/devocionais_screen/theme/thematic_selected.dart';
import '../screens/devocionais_screen/widgets/selected_day_widget.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/home_screen/widgets/random_verse_widget.dart';
import '../screens/saved_verses_screen/saved_verses.dart';
import '../screens/search_screen/search_screen.dart';
import '../screens/settings_screen/settings.dart';
import '../screens/verses_screen/verses_screen.dart';
import '../screens/verses_screen/widgets/verse_with_background.dart';

class AppRoutes {
  static const Duration duration = Duration(milliseconds: 200);
  static const String home = "home";
  static const String annotations = "annotations_screen";
  static const String ai = "ai_screen";
  static const String savedVerses = "saved_verses";
  static const String search = "search_screen";
  static const String randomVerse = "random_verse_screen";
  static const String devocionais = "devocionais_screen";
  static const String readingGroups = "reading_groups_screen";
  static const String userHome = "user_home_screen";
  static const String login = "login_screen";
  static const String createGroup = "create_group_screen";
  static const String feed = "feed_screen";
  static const String settings = "settings";
  static const String userConfig = "user_config_screen";

  static Map<String, WidgetBuilder> routes = {
    annotations: (context) => const AnnotationsScreen(),
    ai: (context) => const AiScreen(),
    savedVerses: (context) => const SavedVerses(),
    search: (context) => const SearchScreen(),
    randomVerse: (context) => const RandomVerseScreen(),
    devocionais: (context) => const DevocionaisScreen(),
    readingGroups: (context) => const InitialScreen(),
    userHome: (context) => const UserHomeScreen(),
    login: (context) => const LoginScreen(),
    createGroup: (context) => const CreateGroupScreen(),
    feed: (context) => const FeedScreen(),
    settings: (context) => const SettingsScreen(),
    userConfig: (context) => const UserConfigScreen(),
  };
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'home':
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.bottomToTop,
        );

      case 'chapter_screen':
        Map<String, dynamic>? routeArgs = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          child: ChapterScreen(
            bookName: routeArgs?['bookName'] as String,
            abbrev: routeArgs?['abbrev'],
            bookIndex: routeArgs?['bookIndex'],
            chapters: routeArgs?['chapters'],
          ),
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration
        );

      case 'verses_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          child: VersesScreen(
            bookName: map?["bookName"],
            abbrev: map?["abbrev"],
            bookIndex: map?["bookIndex"],
            chapters: map?["chapters"],
            chapter: map?["chapter"],
            verseNumber: map?["verseNumber"],
            readingPlan: map?["reading_plan"],
          ),
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration
        );

      case 'verse_with_background':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) {
          return VerseWithBackground(
            bookName: map?["bookName"],
            chapter: map?["chapter"],
            verseStart: map?["verseStart"],
            verseEnd: map?["verseEnd"],
            content: map?["content"],
          );
        });

      case 'annotation_widget':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (context) {
          return AnnotationWidget(
            annotation: map?["annotation"],
            verses: map?["verses"],
            isEditing: map?["isEditing"],
          );
        });

      case 'devocional_selected':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: DevocionalSelected(devocional: map?["devocional"]),
        );
      case 'selected_day':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: SelectedDayWidget(day: map?["day"], qtdDays: map?["qtdDays"], chaptersLength: map?["chaptersLength"], dailyRead: map?["dailyRead"],),
        );
      case 'thematic_selected':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.scale,
          alignment: Alignment.center,
          duration: duration,
          child: ThematicSelected(devocional: map?["devocional"]),
        );
      case 'plans_base':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          duration: duration,
          child: InitPlanBaseScreen(plan: map?["plan"]),
        );
      case 'chat_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          duration: duration,
          child: ChatScreen(
            group: map?["group"],
            participantes: map?["participantes"],
          ),
        );
      case 'group_admin_config_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration,
          child: GroupAdminConfigScreen(
            group: map?["group"],
            participantes: map?["participantes"],
          ),
        );
      case 'group_selected_admin_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration,
          child: GroupSelectedAdminScreen(group: map?["group"]),
        );
      case 'group_selected_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration,
          child: GroupSelectedScreen(group: map?["group"]),
        );
      case 'solicitations_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration,
          child: SolicitationsScreen(group: map?["group"]),
        );
      case 'day_selected_screen':
        Map<String, dynamic>? map = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          duration: duration,
          child: DaySelectedScreen(
            day: map?["day"],
            chapters: map?["chapters"],
            group: map?["group"],
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Rota não encontrada!')),
      ),
    );
  }
}