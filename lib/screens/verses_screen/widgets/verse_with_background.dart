import 'dart:math';
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
  final int verseStart;
  final int? verseEnd;
  final List<Map<String, dynamic>> content;
  const VerseWithBackground({Key? key, required this.bookName, required this.content, required this.chapter, required this.verseStart, this.verseEnd}) : super(key: key);

  @override
  State<VerseWithBackground> createState() => _VerseWithBackgroundState();
}

class _VerseWithBackgroundState extends State<VerseWithBackground> {
  BibleService service = BibleService();
  late VersesProvider versesProvider;
  late Future<String> futureBackground;
  Color? _selectedColor;
  List<Color> _generatedColors = [];
  bool realign = false;
  int length = 0;
  String reference = '';

  double calculateFontSize() {
    double calculatedFontSize = 20;

    print('OLHA O LENGTH $length');
    if(length <= 360) {
     calculatedFontSize = 20;
    }else if(length > 360 && length <= 600) {
      calculatedFontSize = 15;
    }else if(length > 600 && length <= 900) {
      calculatedFontSize = 12;
    }else {
      calculatedFontSize = 10;
    }

    return calculatedFontSize;
  }

  Color generateRandomColor() {
    final Random random = Random();
    const int maxRGBValue = 255;

    // Loop para garantir que a cor tenha um contraste adequado com o branco
    while (true) {
      // Gera valores aleatórios para os componentes RGB
      int red = random.nextInt(maxRGBValue);
      int green = random.nextInt(maxRGBValue);
      int blue = random.nextInt(maxRGBValue);

      // Calcula a luminância da cor
      double luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255;

      // Se a luminância for menor que 0.5, a cor é escura e o texto será branco
      // Se for maior ou igual a 0.5, a cor é clara e o texto será preto
      if (luminance < 0.5) {
        // Cria a cor com base nos componentes RGB gerados
        Color color = Color.fromARGB(255, red, green, blue);
        return color;
      }
    }
  }


  @override
  void initState() {
    for(var text in widget.content) {
      length += text["verse"].toString().length;
    }
    reference = '${widget.bookName} ${widget.chapter}:${widget.verseStart}\n';
    if(widget.verseStart != widget.verseEnd) {
      reference = '${widget.bookName} ${widget.chapter}:${widget.verseStart}-${widget.verseEnd!}\n';
    }
    _generatedColors = List<Color>.generate(10, (index) => generateRandomColor());
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
                        decoration: BoxDecoration(
                          color: (_selectedColor == null) ? null : _selectedColor,
                          image: (_selectedColor == null) ? DecorationImage(
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5), BlendMode.darken
                            ),
                            opacity: 0.8,
                            image: CachedNetworkImageProvider(snapshot.data!),
                            fit: BoxFit.cover,
                          ) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: (length < 360) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 48.0),
                              child: Text(
                                'BibleWise',
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 56.0, top: (length < 360) ? 0 : 40),
                              child: Column(
                                children: [
                                  Text(reference, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                                  for(var i = 0; i <  widget.content.length; i++)
                                    Text(
                                        widget.content[i]["verse"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: calculateFontSize()
                                        )
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox()
                          ],
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
                                  setState(() => realign = true);
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
                                  versesProvider.copyVerses(widget.content);
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
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: Colors.white, width: 2)),
                              fixedSize: MaterialStateProperty.all<Size>(Size(width * 0.7, 40)),
                            ),
                            child: Text('VOLTAR', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14)),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              if(index == 0) {
                                return NewImageContainer(onTap: (() => setState(() {
                                    _selectedColor = null;
                                    futureBackground = service.getRandomImage();
                                  }))
                                );
                              }
                              if(index == 9) {
                                return AddMoreContainer(onTap: (() => setState(() {
                                  _generatedColors = [];
                                  _generatedColors = List<Color>.generate(10, (index) => generateRandomColor());
                                })),
                                );
                              }
                              return ColorContainer(
                                color: _selectedColor,
                                listColors: _generatedColors[index],
                                onTap: (() => setState(() => _selectedColor = _generatedColors[index])),
                              );
                          }),
                        )
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

class ColorContainer extends StatelessWidget {
  final Color? color;
  final Color listColors;
  final Function() onTap;
  const ColorContainer({super.key, required this.color, required this.listColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            color: listColors,
          ),
        ),
        ((color != listColors))
            ? Container()
            : InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            color: Colors.black.withOpacity(.45),
            child: const Icon(Icons.check, color: Colors.white, size: 32,),
          ),
        ),
      ],
    );
  }
}

class AddMoreContainer extends StatelessWidget {
  final Function() onTap;
  const AddMoreContainer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: Colors.white,
      child: IconButton(
          onPressed: onTap, icon: const Icon(Icons.add)
      ),
    );
  }
}

class NewImageContainer extends StatelessWidget {
  final Function() onTap;
  const NewImageContainer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        color: Colors.white,
        child: const Center(child: Text('Nova\nImagem', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)),
      ),
    );
  }
}



