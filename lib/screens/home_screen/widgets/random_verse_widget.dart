import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RandomVerseScreen extends StatefulWidget {
  const RandomVerseScreen({Key? key}) : super(key: key);

  @override
  State<RandomVerseScreen> createState() => _RandomVerseScreenState();
}

class _RandomVerseScreenState extends State<RandomVerseScreen> {
  late SavedVersesProvider savedVersesProvider;
  @override
  Widget build(BuildContext context) {
    savedVersesProvider = Provider.of<SavedVersesProvider>(context, listen: false);
    final bookName = savedVersesProvider.verseInfo["bookName"];
    final chapter = savedVersesProvider.verseInfo["chapter"];
    final verseNumber = savedVersesProvider.verseInfo["verseNumber"];
    final verse = savedVersesProvider.verseInfo["verse"];
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              opacity: 0.8,
              image: CachedNetworkImageProvider(savedVersesProvider.verseInfo["url"]),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 46.0),
                child: Text('Biblia Online', style: Theme.of(context).textTheme.displayLarge,),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Text.rich(
                    TextSpan(
                        text: '$bookName $chapter:$verseNumber\n\n', style: Theme.of(context).textTheme.displayLarge,
                        children: <TextSpan>[
                          TextSpan(text: verse, style: Theme.of(context).textTheme.displayMedium)
                        ]
                    ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: width * 0.7,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                          child: IconButton(
                            onPressed: (() {savedVersesProvider.share(bookName, verse, chapter, verseNumber);}),
                            icon: const Icon(Icons.share),
                            iconSize: 32,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                          child: IconButton(
                            onPressed: (() {savedVersesProvider.copyText(bookName, verse, chapter, verseNumber);}),
                            icon: const Icon(Icons.copy),
                            iconSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(onPressed: (() {savedVersesProvider.getRandomVerse().then((value) => Navigator.pop(context));}), child: const Text('VOLTAR'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          side: MaterialStateProperty.all<BorderSide>(
                            const BorderSide(color: Colors.white, width: 2),
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            Size(width * 0.7, 40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}
