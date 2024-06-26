import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/convert_colors.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/round_container.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../models/verse.dart';

class SavedVerses extends StatefulWidget {
  const SavedVerses({super.key});

  @override
  State<SavedVerses> createState() => _SavedVersesState();
}

class _SavedVersesState extends State<SavedVerses> {
  List<Map<String, dynamic>> allBooksList = [];
  late VersesProvider _versesProvider;
  late VersionProvider _versionProvider;
  BibleDataController bibleDataController = BibleDataController();
  String _selectedOption = '';
  final List<Widget> _listColors = [
    Container(),
    RoundContainer(color: ThemeColors.color2),
    RoundContainer(color: ThemeColors.color1),
    RoundContainer(color: ThemeColors.color3),
    const RoundContainer(color: Colors.brown),
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
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    _versesProvider.loadUserData();
    _versionProvider = Provider.of<VersionProvider>(context, listen: false);
    _versesProvider.getAllBooks().then((value) => setState(() => allBooksList = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _versesProvider.refresh();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DropdownButton(
          underline: Container(
            height: 0,
            color: Colors.transparent,
          ),
          value: _selectedOption,
          items: _options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Row(
                children: [
                  _listColors[bibleDataController.getColorName(option.toLowerCase())],
                  Text('   $option', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
            _versesProvider.orderListByColor(_selectedOption.toLowerCase());
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: (_versesProvider.lista.isNotEmpty)
                    ? (() {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.all(0),
                                title: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Alerta',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.displayMedium,
                                    ),
                                  ),
                                ),
                                content: Text(
                                    'Tem certeza que deseja deletar todos os seus versículos salvos?',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            textStyle: const TextStyle(color: Colors.white),
                                            minimumSize: const Size(80, 36),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error
                                                .withOpacity(0.65)
                                        ),
                                        onPressed: () {
                                          _versesProvider
                                              .deleteAllVerses()
                                              .then((value) => {
                                            _versesProvider.refresh(),
                                            Navigator.pop(context)
                                          });
                                        },
                                        child: Text(
                                          'Sim',
                                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).highlightColor.withOpacity(0.4),
                                            minimumSize: const Size(80, 36),
                                            textStyle: const TextStyle(color: Colors.white)
                                        ),
                                        onPressed: () => Navigator.pop(context, 'Cancelar'),
                                        child: Text('Cancelar', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            });
                      })
                    : null,
                icon: const Icon(
                  Icons.delete_forever,
                  size: 32,
                )),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<VersesProvider>(
        builder: (context, list, child) {
          if (_versesProvider.lista.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nothing_yet.png',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .55,
                ),
                const SizedBox(height: 32),
                const Text('Nenhum Versículo Salvo ainda...',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center)
              ],
            );
          }

          return coresListWidget(list: _versesProvider.lista, corSelecionada: _selectedOption);
        },
      ),
    );
  }

  Widget coresListWidget({required List<VerseModel> list, required String corSelecionada}) {
    final List<dynamic> objetosFiltrados = corSelecionada.toLowerCase() == 'todas'
            ? list
            : list.where((objeto) => ConvertColors()
                    .convertColorsToText(objeto.verseColor)
                    .contains(corSelecionada.toLowerCase()))
                .toList();

    return ScrollablePositionedList.builder(
      shrinkWrap: true,
      itemCount: objetosFiltrados.length,
      itemBuilder: (context, index) {
        String book = objetosFiltrados[index].book;
        int chapter = objetosFiltrados[index].chapter;
        String verse = objetosFiltrados[index].verse;
        String version = bibleDataController.getVersionName(list[index].version);
        int verseNumber = objetosFiltrados[index].verseNumber;
        String verseColor = objetosFiltrados[index].verseColor;

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: InkWell(
            onTap: (() {
              _versesProvider.clear();
              for (var i = 0; i < allBooksList.length; i++) {
                if (allBooksList[i]["bookName"] == book) {
                  _versionProvider.changeOptionBd(version);
                  _versesProvider.loadVerses(allBooksList[i]["bookIndex"], book, versionIndex: list[index].version);
                  GoToVerseScreen().goToVersePage(
                    book,
                    allBooksList[i]["abbrev"],
                    allBooksList[i]["bookIndex"],
                    allBooksList[i]["chapters"],
                    chapter,
                    verseNumber
                  );
                }
              }
            }),
            child: Card(
              child: Slidable(
                startActionPane: ActionPane(
                  extentRatio: 0.3,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                      onPressed: (context) {
                        showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Alerta',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                content: Text(
                                  'Tem certeza que deseja remover esse versículo de seus versículos salvos?',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _versesProvider.deleteVerse(verse).then(
                                          (value) => {
                                                _versesProvider.refresh(),
                                                Navigator.pop(context)
                                              });
                                    },
                                    child: const Text('Sim'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Não'),
                                    child: const Text('Não'),
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
                  extentRatio: .55,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _versesProvider.share(
                            book, verse, chapter, verseNumber);
                      },
                      icon: Icons.share,
                      label: 'Share',
                      backgroundColor:
                          Theme.of(context).buttonTheme.colorScheme!.background,
                    ),
                    SlidableAction(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                      onPressed: (context) {
                        _versesProvider.copyText(
                            book, verse, chapter, verseNumber);
                      },
                      icon: Icons.copy,
                      label: 'Copiar',
                      backgroundColor: Theme.of(context)
                          .buttonTheme
                          .colorScheme!
                          .background
                          .withOpacity(0.9),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$book $chapter:$verseNumber (${version.split(' ')[0]})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          RoundContainer(
                              color: ConvertColors().convertColors(verseColor)!)
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(verse, style: Theme.of(context).textTheme.bodyLarge),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
