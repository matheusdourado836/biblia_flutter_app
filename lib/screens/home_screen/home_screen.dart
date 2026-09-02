import 'dart:io';
import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
//import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card_chronological_order.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card_style_order.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_list.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_app_bar.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_drawer.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/search_book_widget.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/devocional_provider.dart';
import '../../data/user_provider.dart';

ScrollController? scrollController;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final VersesProvider versesProvider = Provider.of<VersesProvider>(context, listen: false);
  final BibleDataController bibleDataController = BibleDataController();
  BannerAd? _bannerAd;
  bool changeLayout = false;

  @override
  void initState() {
    setUserId();
    bibleDataController.getBooks();
    getLayout();
    final chapterProvider = Provider.of<ChaptersProvider>(context, listen: false);
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.getLoggedUser();
    devocionalProvider.getCompletedTutorials();
    chapterProvider.innerList = bibleDataController.books;
    chapterProvider.getOrderStyle();
    versesProvider.getFontSize();
    versesProvider.refresh();
    versesProvider.getImage();
    double savedPosition = chapterProvider.position;

    scrollController = ScrollController(initialScrollOffset: savedPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) => _createBannerAd());
    super.initState();
  }

  void setUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    userId ??= const Uuid().v4();
    prefs.setString('userId', userId);
  }

  Future<void> _createBannerAd() async {
    final screenWidth = MediaQuery.sizeOf(context).width.round();
    final width = AdSize.getInlineAdaptiveBannerAdSize(screenWidth , 60);
    _bannerAd = BannerAd(
      size: width,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerAdListener,
      request: const AdRequest()
    );
    await _bannerAd!.load();
    setState(() => _bannerAd);
  }

  void getLayout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? userLayout = prefs.getBool("cardLayout");
    if(userLayout == null) {
      prefs.setBool("cardLayout", true);
      return;
    }

    setState(() => changeLayout = userLayout);
  }

  void setLayout() async {
    setState(() => changeLayout = !changeLayout);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("cardLayout", changeLayout);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  /// Chamado quando o usuário volta para a home vindo de outra tela: é aqui
  /// que os dados são recarregados, e não mais a cada `build`.
  @override
  void didPopNext() {
    versesProvider.refresh();
    versesProvider.loadUserData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(books: bibleDataController.books),
      drawer: const HomeDrawer(),
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ChaptersProvider>(
          builder: (context, value, _) {
            if(value.isSearching) {
              return SearchBookWidget(books: value.innerList);
            }
            if(changeLayout) {
              if (value.orderStyle == 0) {
                return BookCard(
                  bookIsRead: bookIsRead,
                  database: bibleDataController.books
                );
              }else if(value.orderStyle == 1) {
                return BookCardChronologicalOrder(
                    bookIsRead: bookIsRead,
                    database: bibleDataController.books
                );
              }
              return BookCardStyleOrder(
                  bookIsRead: bookIsRead,
                  database: bibleDataController.books
              );
            }

            return BookList(
              listBooks: bibleDataController.books,
              bookIsRead: bookIsRead,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: () => setLayout(),
        tooltip: 'Mudar Layout',
        child: Icon(
          Icons.list,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
      bottomNavigationBar:
        (_bannerAd != null)
          ? Container(
              height: 60,
              padding: (Platform.isIOS) ? const EdgeInsets.only(left: 14, right: 14, bottom: 14) : EdgeInsets.zero,
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  bool bookIsRead(String bookName) {
    return versesProvider.listMap.any(
      (element) => element["bookName"] == bookName && element['finishedReading'] == 1,
    );
  }
}