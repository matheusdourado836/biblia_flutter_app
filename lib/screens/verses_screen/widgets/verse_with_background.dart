import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home_screen/widgets/random_verse_widget.dart';

class VerseWithBackground extends StatefulWidget {
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String content;
  const VerseWithBackground({Key? key, required this.bookName, required this.content, required this.chapter, required this.verseNumber}) : super(key: key);

  @override
  State<VerseWithBackground> createState() => _VerseWithBackgroundState();
}

class _VerseWithBackgroundState extends State<VerseWithBackground> {
  BibleService service = BibleService();
  late VersesProvider versesProvider;
  late Future<String> futureBackground;

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!,
        listen: false);
    futureBackground = service.getRandomImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<String>(
        future: futureBackground,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const LoadingWidget();
          }
          else if(snapshot.data != null && snapshot.data!.isNotEmpty) {
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
                            CachedNetworkImageProvider(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 48.0),
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
                                      text: '${widget.bookName} ${widget.chapter}:${widget.verseNumber}\n\n',
                                      style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: widget.content,
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
                            Padding(
                              padding:
                              const EdgeInsets.only(right: 32, bottom: 6.0),
                              child: IconButton(
                                onPressed: (() {
                                  versesProvider.shareImageAndText();
                                }),
                                icon: const Icon(Icons.share),
                                iconSize: 32,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 32, bottom: 6.0),
                              child: IconButton(
                                onPressed: (() {
                                  versesProvider.copyText(
                                      widget.bookName, widget.content, widget.chapter, widget.verseNumber);
                                }),
                                icon: const Icon(Icons.copy),
                                iconSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: (() {
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
                            child: const Text('VOLTAR'),
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
