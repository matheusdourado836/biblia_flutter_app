import 'dart:async';
import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card_chronological_order.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card_style_order.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_list.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_app_bar.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_drawer.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';

late VersesProvider versesProvider;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  final BibleDataController bibleDataController = BibleDataController();
  late Future<List<Book>> futureListBooks;
  List<Book>? listBooks;
  late AdSize width;
  bool changeLayout = true;

  @override
  void initState() {
    futureListBooks = bibleDataController.getBooks();
    versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    versesProvider.getFontSize();
    versesProvider.refresh();
    versesProvider.getImage();
    _createBannerAd();
    super.initState();
  }

  void _createBannerAd() {
    width = AdSize.getInlineAdaptiveBannerAdSize(screenWidth , 60);
    _bannerAd = BannerAd(
      size: width,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerAdListener,
      request: const AdRequest()
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    versesProvider.refresh();
    versesProvider.loadUserData();
    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      backgroundColor: Theme.of(context).primaryColor,
      body: (changeLayout)
          ? Consumer<ChaptersProvider>(
              builder: (context, value, _) {
                value.getOrderStyle();
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<List<Book>>(
                    future: futureListBooks,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        if (snapshot.data!.isNotEmpty) {
                          listBooks = snapshot.data!;
                          if (value.orderStyle == 0) {
                            return BookCard(
                                bookIsRead: bookIsRead,
                                database: bibleDataController.books);
                          }else if(value.orderStyle == 1) {
                            return BookCardChronologicalOrder(
                                bookIsRead: bookIsRead,
                                database: bibleDataController.books
                            );
                          }
                          return BookCardStyleOrder(
                            bookIsRead: bookIsRead,
                            database: bibleDataController.books,
                          );
                        }
                      } else if (snapshot.hasError) {
                        return InkWell(
                            onTap: (() => setState(() {})),
                            child: Text('Erro Inesperado! ${snapshot.error}'));
                      }
                      return const LoadingWidget();
                    },
                  ),
                );
              },
            )
          : BookList(
              listBooks: bibleDataController.books,
              bookIsRead: bookIsRead,
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: () {
          setState(() {
            listBooks;
            if (listBooks != null) {
              changeLayout = !changeLayout;
            }
          });
        },
        tooltip: 'Mudar Layout',
        child: Icon(
          Icons.list,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
      bottomNavigationBar:
        (_bannerAd != null)
            ? SizedBox(
                height: 60,
                child: AdWidget(ad: _bannerAd!),
              )
            : null,
    );
  }

  bool bookIsRead(String bookName) {
    List<Map<String, dynamic>> listMap = [];
    listMap = versesProvider.listMap;
    for (var element in listMap) {
      if (element["bookName"] == bookName && element['finishedReading'] == 1) {
        return true;
      }
    }

    return false;
  }
}
