import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/convert_colors.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/screens/saved_verses_screen/widgets/delete_all_saved_verses_dialog.dart';
import 'package:biblia_flutter_app/screens/saved_verses_screen/widgets/delete_saved_verse.dart';
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
          underline: Container(height: 0, color: Colors.transparent),
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
          onChanged: (newValue) => setState(() => _selectedOption = newValue!),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: (_versesProvider.listaBd.isNotEmpty)
                ? (() {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteAllSavedVersesDialog(
                        onDelete: () {
                          _versesProvider.deleteAllVerses().then((value) {
                              _versesProvider.loadUserData();
                              Navigator.pop(context);
                          });
                        }
                      );
                    });
                  })
                  : null,
              icon: const Icon(Icons.delete_forever, size: 32)
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Consumer<VersesProvider>(
        builder: (context, list, child) {
          if (_versesProvider.listaBd.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nothing_yet.png',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .55,
                ),
                const SizedBox(height: 20),
                const Text('Nenhum Versículo Salvo ainda...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200), textAlign: TextAlign.center)
              ],
            );
          }

          return coresListWidget(list: _versesProvider.listaBd, corSelecionada: _selectedOption);
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

    if(objetosFiltrados.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/images/not_found.png'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Você ainda não salvou nenhum versículo na cor ${corSelecionada.toLowerCase()}.',
              textAlign: TextAlign.center,
            ),
          )
        ],
      );
    }

    return ScrollablePositionedList.builder(
      shrinkWrap: true,
      itemCount: objetosFiltrados.length,
      itemBuilder: (context, index) {
        String book = objetosFiltrados[index].book;
        int chapter = objetosFiltrados[index].chapter;
        String verse = objetosFiltrados[index].verse;
        String version = list[index].version;
        int verseNumber = objetosFiltrados[index].verseNumber;
        String verseColor = objetosFiltrados[index].verseColor;

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: InkWell(
            onTap: (() {
              final versionName = _versionProvider.options.firstWhere((v) => v.toLowerCase().split(' ')[0].trim() == nameToVersion(version.trim()));
              _versesProvider.clear();
              for (var i = 0; i < allBooksList.length; i++) {
                if (allBooksList[i]["bookName"] == book) {
                  _versionProvider.changeVersion(versionName.trim());
                  _versesProvider.loadVerses(allBooksList[i]["bookIndex"], book, versionName: version);
                  Navigator.pushNamed(
                      context,
                      'verses_screen',
                      arguments: {
                        'bookName': book,
                        "abbrev": allBooksList[i]["abbrev"],
                        "bookIndex": allBooksList[i]["bookIndex"],
                        "chapters": allBooksList[i]["chapters"],
                        "chapter": chapter,
                        "verseNumber": verseNumber,
                      }
                  );
                }
              }
            }),
            child: Slidable(
              startActionPane: ActionPane(
                extentRatio: 0.3,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    onPressed: (context) {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return DeleteSavedVerse(
                            onDelete: () {
                              _versesProvider.deleteVerse(verse).whenComplete(() {
                                _versesProvider.loadUserData();
                                setState(() => list.removeWhere((v) => v.verse == verse));
                                Navigator.pop(context);
                              });
                            }
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
                extentRatio: .7,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => _versesProvider.share(book, verse, chapter, verseNumber),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    icon: Icons.share,
                    label: 'Compartilhar',
                    backgroundColor: Theme.of(context).buttonTheme.colorScheme!.surface,
                  ),
                  SlidableAction(
                    onPressed: (context) => _versesProvider.copyText(book, verse, chapter, verseNumber),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    icon: Icons.copy,
                    label: 'Copiar',
                    backgroundColor: Theme.of(context).highlightColor
                  )
                ],
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$book $chapter:$verseNumber (${nameToVersion(version).toUpperCase()})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          RoundContainer(color: ConvertColors().convertColors(verseColor)!)
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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