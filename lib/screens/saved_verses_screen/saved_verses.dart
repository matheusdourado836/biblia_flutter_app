import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/helpers/convert_colors.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../models/verse_model.dart';
import '../verses_screen/verses_screen.dart';

class SavedVerses extends StatefulWidget {
  const SavedVerses({Key? key}) : super(key: key);

  @override
  State<SavedVerses> createState() => _SavedVersesState();
}

class _SavedVersesState extends State<SavedVerses> {
  Future<List<VerseModel>>? savedVersesList;
  List<Book> futureList = [];
  late SavedVersesProvider _savedVersesProvider;
  String _selectedOption = '';
  final List<Widget> _listColors = [
    Container(),
    RoundContainer(color: ThemeColors.color2),
    RoundContainer(color: ThemeColors.color1),
    RoundContainer(color: ThemeColors.color3),
    RoundContainer(color: ThemeColors.color4),
    RoundContainer(color: ThemeColors.color5),
    RoundContainer(color: ThemeColors.color6),
    RoundContainer(color: ThemeColors.color7),
    RoundContainer(color: ThemeColors.color8),
  ];
  final List<String> _options = [
    'Todas',
    'Azul',
    'Amarelo',
    'Marrom',
    'Vermelho',
    'Laranja',
    'Verde',
    'Rosa',
    'Ciano',
  ];

  @override
  void initState() {
    _selectedOption = _options[0];
    service.getAllBooks().then((value) => setState(() {
          futureList = value;
        }));
    savedVersesList = VersesDao().findAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _savedVersesProvider = Provider.of<SavedVersesProvider>(context, listen: false);
    _savedVersesProvider.refresh();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DropdownButton(
          value: _selectedOption,
          items: _options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Row(
                children: [
                  _listColors[getColorName(option.toLowerCase())],
                  Text(
                    '   $option',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
            _savedVersesProvider
                .orderListByColor(_selectedOption.toLowerCase());
          },
        ),
      ),
      body: Container(
          color: Theme.of(context).primaryColor,
          child: Consumer<SavedVersesProvider>(
            builder: (context, list, child) {
              if (_savedVersesProvider.lista.isEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(image: AssetImage('assets/images/nothing_yet.png')),
                    SizedBox(height: 32),
                    Text('Nenhum Versículo Salvo ainda...',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center)
                  ],
                );
              }

              return coresListWidget(
                  list: _savedVersesProvider.lista,
                  corSelecionada: _selectedOption);
            },
          )),
    );
  }

  getColorName(String option) {
    switch (option) {
      case 'todas':
        return 0;
      case 'ciano':
        return 2;
      case 'azul':
        return 1;
      case 'amarelo':
        return 3;
      case 'marrom':
        return 4;
      case 'vermelho':
        return 5;
      case 'laranja':
        return 6;
      case 'verde':
        return 7;
      case 'rosa':
        return 8;
    }
  }

  Widget coresListWidget(
      {required List<VerseModel> list, required String corSelecionada}) {
    final List<dynamic> objetosFiltrados =
        corSelecionada.toLowerCase() == 'todas'
            ? list
            : list
                .where((objeto) => ConvertColors()
                    .convertColorsToText(objeto.verseColor)
                    .contains(corSelecionada.toLowerCase()))
                .toList();

    return ListView.builder(
      itemCount: objetosFiltrados.length,
      itemBuilder: (context, index) {
        String book = objetosFiltrados[index].book;
        int chapter = objetosFiltrados[index].chapter;
        String verse = objetosFiltrados[index].verse;
        int verseNumber = objetosFiltrados[index].verseNumber;
        String verseColor = objetosFiltrados[index].verseColor;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: (() {
              for (var element in futureList) {
                if (element.name == book) {
                  GoToVerseScreen().goToVersePage(book, element.abbrev,
                      element.chapters, chapter, verseNumber);
                }
              }
            }),
            child: Card(
              child: Slidable(
                startActionPane: ActionPane(
                  extentRatio: 0.25,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        showDialog<void>(context: context, builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Alerta', style: Theme.of(context).textTheme.bodyLarge,),
                            content: Text('Tem certeza que deseja remover esse versículo de seus versículos salvos?', style: Theme.of(context).textTheme.bodyMedium),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Não'),
                                child: const Text('Não'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _savedVersesProvider.deleteVerse(verse).then((value) => {
                                    _savedVersesProvider.refresh(),
                                    Navigator.pop(context)
                                  });
                                },
                                child: const Text('Sim'),
                              ),
                            ],
                          );
                        });
                        },
                      icon: Icons.delete,
                      label: 'Deletar',
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: Colors.red.shade200,
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {_savedVersesProvider.share(book, verse, chapter, verseNumber);},
                      icon: Icons.share,
                      label: 'Share',
                      backgroundColor: Theme.of(context).buttonTheme.colorScheme!.background,
                    ),
                    SlidableAction(
                      onPressed: (context) {_savedVersesProvider.copyText(book, verse, chapter, verseNumber);},
                      icon: Icons.copy,
                      label: 'Copiar',
                      backgroundColor: Theme.of(context).buttonTheme.colorScheme!.background.withOpacity(0.9),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$book $chapter:$verseNumber',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          RoundContainer(
                              color: ConvertColors().convertColors(verseColor)!)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(verse,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
