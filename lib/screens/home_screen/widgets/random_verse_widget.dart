import 'dart:io';

import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

GlobalKey globalKey = GlobalKey();

class RandomVerseScreen extends StatefulWidget {
  const RandomVerseScreen({Key? key}) : super(key: key);

  @override
  State<RandomVerseScreen> createState() => _RandomVerseScreenState();
}

class _RandomVerseScreenState extends State<RandomVerseScreen> {
  late VersesProvider versesProvider;
  late Future<Map<String, dynamic>> futureRandomVerses;
  String abbrev = '';
  String bookName = '';
  int bookIndex = 0;
  String verse = '';
  int chapters = 0;
  int chapter = 0;
  int verseNumber = 0;

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(context, listen: false);
    Provider.of<VersionProvider>(context, listen: false).changeSelectedOption = 'NVI (Nova Versão Internacional)';
    futureRandomVerses = versesProvider.getRandomVerse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureRandomVerses,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const LoadingWidget();
          }
          else if(snapshot.data!["bookName"] != null) {
            abbrev = snapshot.data!["abbrev"];
            bookName = snapshot.data!["bookName"];
            chapter = snapshot.data!["chapter"];
            verseNumber = snapshot.data!["verseNumber"];
            verse = snapshot.data!["verse"];
            final List<dynamic> bookReference = bibleData.data[0];
            final book = bookReference.where((element) => element["abbrev"] == abbrev).first;
            bookIndex = bookReference.indexOf(book);
            chapters = book["chapters"].length;
            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    key: globalKey,
                    child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5), BlendMode.darken),
                            opacity: 0.8,
                            image:
                            CachedNetworkImageProvider(snapshot.data!["url"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 72.0),
                                child: Text(
                                  'BibleWise',
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, bottom: 40.0),
                                child: Text.rich(
                                  TextSpan(
                                      text: '$bookName $chapter:$verseNumber\n\n',
                                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: verse,
                                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.white))
                                      ]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox()
                            ],
                          ),
                        )),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    width: width * 0.7,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: (() {
                                versesProvider.shareImageAndText();
                              }),
                              icon: const Icon(Icons.share),
                              iconSize: 32,
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: (() {
                                versesProvider.clear();
                                versesProvider.loadVerses(bookIndex, bookName);
                                Navigator.pushNamed(context, 'verses_screen', arguments: {
                                  "bookName": bookName,
                                  "abbrev": abbrev,
                                  "bookIndex": bookIndex,
                                  "chapters": chapters,
                                  "chapter": chapter,
                                  "verseNumber": verseNumber
                                });
                              }),
                              icon: const Icon(Icons.menu_book_outlined),
                              iconSize: 32,
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: (() {
                                versesProvider.copyText(
                                    bookName, verse, chapter, verseNumber);
                              }),
                              icon: const Icon(Icons.copy),
                              iconSize: 32,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Padding(
                          padding: (Platform.isIOS) ? const EdgeInsets.only(bottom: 32, top: 8) : const EdgeInsets.only(bottom: 16.0, top: 8),
                          child: ElevatedButton(
                            onPressed: (() {
                              versesProvider.clear();
                              versesProvider.getImage();
                              Navigator.pop(context);
                            }),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                              side: MaterialStateProperty.all<BorderSide>(
                                const BorderSide(color: Colors.white, width: 2),
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(width * 0.7, 40),
                              ),
                            ),
                            child: Text('VOLTAR', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image(image: AssetImage('assets/images/no_data.png')),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text('Não foi possível carregar um Versículo aleatório. Por Favor tente novamente.',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                      textAlign: TextAlign.center),
                ),
                ElevatedButton(
                  onPressed: (() => Navigator.pushReplacementNamed(context, 'home')),
                  child: const Text('Home'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
