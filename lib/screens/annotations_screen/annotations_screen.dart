import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AnnotationsScreen extends StatefulWidget {
  const AnnotationsScreen({super.key});

  @override
  State<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends State<AnnotationsScreen> {
  late VersesProvider versesProvider;

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(context, listen: false);
    versesProvider.loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    versesProvider.getAnnotations();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Suas anotações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: (versesProvider.listaAnnotations.isNotEmpty)
                    ? (() {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.all(0),
                                title: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(28),
                                        topRight: Radius.circular(28)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Alerta',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                    ),
                                  ),
                                ),
                                content: Text(
                                    'Tem certeza que deseja deletar todas as suas anotações?',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            textStyle: const TextStyle(
                                                color: Colors.white),
                                            minimumSize: const Size(80, 36),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error
                                                .withOpacity(0.65)),
                                        onPressed: () {
                                          versesProvider
                                              .deleteAllAnnotations()
                                              .then((value) => {
                                                    versesProvider.refresh(),
                                                    Navigator.pop(context)
                                                  });
                                        },
                                        child: Text('Sim',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(fontSize: 14)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .highlightColor
                                                .withOpacity(0.4),
                                            minimumSize: const Size(80, 36),
                                            textStyle: const TextStyle(
                                                color: Colors.white)),
                                        onPressed: () =>
                                            Navigator.pop(context, 'Não'),
                                        child: Text('Cancelar',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(fontSize: 14)),
                                      ),
                                    ],
                                  )
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
        builder: (context, value, _) {
          if (value.listaAnnotations.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/nothing_yet.png',
                  width: double.infinity,
                  height: height * .55,
                ),
                const SizedBox(height: 20),
                const Text('Nenhuma Anotação ainda...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200), textAlign: TextAlign.center)
              ],
            );
          }

          return ListView.builder(
              itemCount: value.listaAnnotations.length,
              itemBuilder: (context, index) {
                Annotation annotation = value.listaAnnotations[index];
                final List<dynamic> list = BibleData().data[0]["text"];
                final bookInfo = list
                    .where((element) => element['name'] == annotation.book)
                    .toList();
                final List<dynamic> verses =
                    bookInfo[0]['chapters'][annotation.chapter - 1];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (() {
                      Navigator.pushNamed(context, 'annotation_widget',
                          arguments: {
                            'annotation': annotation,
                            'verses': verses,
                            'isEditing': true
                          });
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        content: Text(
                                            'Tem certeza que deseja remover essa anotação?',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              value
                                                  .deleteAnnotation(value
                                                      .listaAnnotations[index]
                                                      .annotationId)
                                                  .then((res) => {
                                                        value.refresh(),
                                                        Navigator.pop(context)
                                                      });
                                            },
                                            child: const Text('Sim'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Não'),
                                            child: const Text('Não'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              icon: Icons.delete,
                              label: 'Deletar',
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
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
                                Share.share('Veja que interessante essa reflexão:\n${annotation.title} ${annotation.content}');
                              },
                              icon: Icons.share,
                              label: 'Share',
                              backgroundColor: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .background,
                            ),
                            SlidableAction(
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                              onPressed: (context) {
                                value.copyText(
                                    annotation.book,
                                    annotation.content,
                                    annotation.chapter,
                                    annotation.verseEnd!);
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    annotation.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  TextButton(
                                    onPressed: (() {
                                      versesProvider.clear();
                                      versesProvider.loadVerses(
                                          list.indexOf(bookInfo.first),
                                          annotation.book);
                                      GoToVerseScreen().goToVersePage(
                                          annotation.book,
                                          bookInfo[0]['abbrev'],
                                          list.indexOf(bookInfo.first),
                                          bookInfo[0]['chapters'].length,
                                          annotation.chapter,
                                          annotation.verseEnd ?? 1);
                                    }),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    child: Row(children: [
                                      Text('Ler passagem  ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge),
                                      Icon(Icons.menu_book,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onError)
                                    ]),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(annotation.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
