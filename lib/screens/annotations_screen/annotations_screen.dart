import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/models/annotation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class AnnotationsScreen extends StatefulWidget {
  const AnnotationsScreen({Key? key}) : super(key: key);

  @override
  State<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends State<AnnotationsScreen> {
  late VersesProvider versesProvider;

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.6),
                                  child: Center(
                                    child: Text(
                                      'Alerta',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
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
                                            backgroundColor: Theme.of(context)
                                                .highlightColor
                                                .withOpacity(0.2),
                                            minimumSize: const Size(80, 36),
                                            textStyle: const TextStyle(
                                                color: Colors.white)),
                                        onPressed: () =>
                                            Navigator.pop(context, 'Não'),
                                        child: const Text('Não'),
                                      ),
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
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                                fontWeight: FontWeight.bold)),
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
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Consumer<VersesProvider>(
          builder: (context, value, _) {
            if (value.listaAnnotations.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/images/nothing_yet.png')),
                  SizedBox(height: 32),
                  Text('Nenhuma Anotação ainda...',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                      textAlign: TextAlign.center)
                ],
              );
            }

            return ListView.builder(
                itemCount: value.listaAnnotations.length,
                itemBuilder: (context, index) {
                  String annotationId =
                      value.listaAnnotations[index].annotationId;
                  String title = value.listaAnnotations[index].title;
                  String content = value.listaAnnotations[index].content;
                  String book = value.listaAnnotations[index].book;
                  int chapter = value.listaAnnotations[index].chapter;
                  int verseStart = value.listaAnnotations[index].verseStart;
                  int? verseEnd = value.listaAnnotations[index].verseEnd;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: (() {
                        AnnotationModel annotation = AnnotationModel(
                            annotationId: annotationId,
                            title: title,
                            content: content,
                            book: book,
                            chapter: chapter,
                            verseStart: verseStart,
                            verseEnd: verseEnd);
                        Navigator.pushNamed(context, 'annotation_widget',
                            arguments: {
                              'annotation': annotation,
                              'isEditing': true
                            });
                      }),
                      child: Card(
                        child: Slidable(
                          startActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
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
                                              onPressed: () =>
                                                  Navigator.pop(context, 'Não'),
                                              child: const Text('Não'),
                                            ),
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
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  value.share(
                                      book, content, chapter, verseStart);
                                },
                                icon: Icons.share,
                                label: 'Share',
                                backgroundColor: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme!
                                    .background,
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  value.copyText(
                                      book, content, chapter, verseStart);
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
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                      title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(content,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
