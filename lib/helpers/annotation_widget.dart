import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/annotation.dart';

class AnnotationWidget extends StatefulWidget {
  final Annotation annotation;
  final List<dynamic> verses;
  final bool isEditing;

  const AnnotationWidget(
      {Key? key, required this.annotation, required this.isEditing, required this.verses})
      : super(key: key);

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  String title = '';
  String annotationId = '';
  late VersesProvider versesProvider;
  late ThemeProvider themeProvider;
  Color dialogColor = Colors.white;
  final TextEditingController _contentController = TextEditingController();
  final ThemeColors themeColors = ThemeColors();
  bool isEditing = false;

  @override
  void initState() {
    isEditing = widget.isEditing;
    annotationId = widget.annotation.annotationId;
    versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    themeProvider = Provider.of<ThemeProvider>(navigatorKey!.currentContext!, listen: false);
    themeProvider.isOn ? dialogColor = Colors.white : dialogColor = const Color.fromRGBO(83,75,94, 1);
    if (widget.annotation.verseStart > 0) {
      title = '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseStart}-${widget.annotation.verseEnd}';
    } else {
      title = '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseEnd}';
    }
    _contentController.text = widget.annotation.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                IconButton(onPressed: (() {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0),
                      title: Container(
                          height: 90,
                          color: Theme.of(context).colorScheme.primary,
                          child: Center(child: Text('${widget.annotation.book} capítulo ${widget.annotation.chapter}', style: themeColors.coloredVerse(),))),
                      actions: null,
                      content: Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * .5,
                        padding: const EdgeInsets.all(6.0),
                        child: ListView.builder(
                            itemCount: widget.verses.length,
                            itemBuilder: (context, index) {
                          return Text.rich(
                            TextSpan(
                              text: '${(index + 1).toString()}  ',
                              style: themeColors.verseNumberColor(themeProvider.isOn),
                              children: <TextSpan> [
                                TextSpan(text: widget.verses[index], style: themeColors.verseColor(themeProvider.isOn))
                              ]
                            )
                          );
                        }),
                      ),
                    );
                  });
                }), icon: const Icon(Icons.menu_book_outlined))
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  if (isEditing) {
                    AnnotationsDao().updateAnnotation(annotationId, _contentController.text)
                        .whenComplete(
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text('Anotação atualizada com sucesso!'),
                            ),
                          ),
                        );
                  } else {
                    final newId = const Uuid().v1();
                    final savedAnnotation = Annotation(
                        annotationId: newId,
                        title: title,
                        content: _contentController.text,
                        book: widget.annotation.book,
                        chapter: widget.annotation.chapter,
                        verseStart: widget.annotation.verseStart,
                        verseEnd: widget.annotation.verseEnd
                    );
                    AnnotationsDao().save(
                          savedAnnotation
                        ).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text('Anotação salva com sucesso!'),
                            ),
                          ),
                        );
                    setState(() {
                      isEditing = true;
                      annotationId = newId;
                    });
                  }
                  versesProvider.refresh();
                }
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          decoration: const InputDecoration(hintText: 'Digite sua anotação aqui...'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
          keyboardType: TextInputType.multiline,
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }
}
