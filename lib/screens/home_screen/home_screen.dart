import 'dart:async';
import 'dart:io';
import 'package:biblia_flutter_app/data/books_dao.dart';
import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/helpers/random_verse_dialog.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_card.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/book_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/exception_dialog.dart';
import '../../models/book.dart';
import '../../services/bible_service.dart';
import '../../data/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BibleService service = BibleService();
  late Future<List<Book>> futureList;
  List<Book>? listBooks;
  Map<String, dynamic> verseInfo = {};
  bool changeLayout = true;
  bool toggleMode = true;
  late SavedVersesProvider _savedVersesProvider;

  @override
  void initState() {
    futureList = service.getAllBooks();
    _savedVersesProvider = Provider.of<SavedVersesProvider>(context, listen: false);
    _savedVersesProvider.refresh();
    getRandomVerse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _savedVersesProvider.refresh();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Biblia Online'),
        actions: [
          IconButton(
            onPressed: () {
              randomVerseDialog(verseInfo, title: '${verseInfo["bookName"]} ${verseInfo["chapter"]}:${verseInfo["verseNumber"]}', content: verseInfo["verse"],);
              getRandomVerse();
            },
            tooltip: 'Versículo Aleatório',
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        child: Consumer<SavedVersesProvider>(
          builder: (context, value, child) {
            return Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: kElevationToShadow[3],
                    borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator(
                                strokeWidth: 8.0,
                                backgroundColor:
                                Theme.of(context).colorScheme.surface,
                                color: Theme.of(context).colorScheme.onSurface,
                                value: _savedVersesProvider.listMap.length / 66,
                              ),
                            ),
                            Text(
                              '     Progresso: ${formatValue(_savedVersesProvider.listMap.length / 66)}%',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Livros Lidos:\n${_savedVersesProvider.listMap.length}/66',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: (() {
                    Navigator.pushNamed(context, 'saved_verses');
                  }),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 32.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Text('   Versículos Salvos'),
                        const Spacer(),
                        Text('${_savedVersesProvider.qtdVerses}')
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (() {
                    Navigator.popAndPushNamed(context, 'search_screen');
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Text('   Pesquisar passagens'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (() {
                    setState(() {
                      toggleMode = !toggleMode;
                    });
                    themeProvider.toggleTheme(toggleMode);
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        (toggleMode)
                            ? Icon(
                          Icons.light_mode_sharp,
                          color: Theme.of(context).colorScheme.primary,
                        )
                            : Icon(
                          Icons.dark_mode_sharp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Text('   Trocar modo do app'),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: (() {
                    Navigator.pushNamed(context, 'email_screen');
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Text('   Reportar um erro'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: (changeLayout)
          ? Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<Book>>(
                future: futureList,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.isNotEmpty) {
                      listBooks = snapshot.data!;
                      return ListBooks(
                        database: listBooks,
                        bookIsRead: bookIsRead,
                      );
                    }
                  }else if(snapshot.hasError) {
                    return InkWell(
                        onTap: (() {setState(() {});}),
                        child: Text('Erro Inesperado! ${snapshot.error}'));
                  }
                  return const LoadingWidget();
                },
              ),
            )
          : BookList(
              listBooks: listBooks!,
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
    listMap = _savedVersesProvider.listMap;
    for (var element in listMap) {
      if (element["bookName"] == bookName) {
        return true;
      }
    }

    return false;
  }

  getRandomVerse() {
    verseInfo = {};
    service.getRandomVerse().then((value) async => {
        await service.getBookDetail(value["book"]["abbrev"]["pt"]).then((value) => {verseInfo["chapters"] = value["chapters"]}),
        verseInfo["bookName"] = value["book"]["name"],
        verseInfo["abbrev"] = value["book"]["abbrev"]["pt"],
        verseInfo["chapter"] = value["chapter"],
        verseInfo["verseNumber"] = value["number"],
        verseInfo["verse"] = value["text"]
    }
    ).catchError(
          (error) {
            var innerError = error as TimeoutException;
        exceptionDialog(title: 'Erro ${innerError.message}',
            content:
            'O servidor demorou pra responder. Tente novamente mais tarde.');
      },
      test: (error) => error is TimeoutException,
    ).catchError(
          (error) {
            var innerError = error as HttpException;
        exceptionDialog(title: 'Erro ${innerError.message}',
            content:
            'O servidor demorou pra responder. Tente novamente mais tarde.');
      },
      test: (error) => error is HttpException,
    );
    setState(() {
      verseInfo;
    });
  }

  formatValue(double value) {
    value = value * 100;
    var formatedLevel = value.toStringAsFixed(2);

    return double.parse(formatedLevel);
  }
}
