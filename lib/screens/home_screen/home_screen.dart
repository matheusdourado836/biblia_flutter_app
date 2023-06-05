import 'dart:async';
import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_list.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_app_bar.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BibleDataController bibleDataController = BibleDataController();
  late Future<List<Book>> futureListBooks;
  List<Book>? listBooks;
  bool changeLayout = true;
  late VersesProvider _versesProvider;

  @override
  void initState() {
    futureListBooks = bibleDataController.getBooks();
    _versesProvider = Provider.of<VersesProvider>(
        navigatorKey!.currentContext!,
        listen: false);
    _versesProvider.refresh();
    _versesProvider.getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _versesProvider.refresh();
    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: (changeLayout)
          ? Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<Book>>(
                future: futureListBooks,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.isNotEmpty) {
                      listBooks = snapshot.data!;
                      return BookCard(
                        database: bibleDataController.books,
                        bookIsRead: bookIsRead,
                      );
                    }
                  } else if (snapshot.hasError) {
                    return InkWell(
                        onTap: (() {
                          setState(() {});
                        }),
                        child: Text('Erro Inesperado! ${snapshot.error}'));
                  }
                  return const LoadingWidget();
                },
              ),
            )
          : BookList(
              listBooks: bibleDataController.books,
              bookIsRead: bookIsRead,
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.background,
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
    );
  }

  bool bookIsRead(String bookName) {
    List<Map<String, dynamic>> listMap = [];
    listMap = _versesProvider.listMap;
    for (var element in listMap) {
      if (element["bookName"] == bookName) {
        return true;
      }
    }

    return false;
  }
}
