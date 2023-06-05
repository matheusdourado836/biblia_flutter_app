import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/annotation_model.dart';

class AnnotationWidget extends StatefulWidget {
  final AnnotationModel annotation;
  final bool isEditing;

  const AnnotationWidget(
      {Key? key, required this.annotation, required this.isEditing})
      : super(key: key);

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  String title = '';
  late VersesProvider versesProvider;
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!,
        listen: false);
    if (widget.annotation.verseStart > 0) {
      title =
          '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseStart}-${widget.annotation.verseEnd}';
    } else {
      title =
          '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseEnd}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _contentController.text = widget.annotation.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  if (widget.isEditing) {
                    AnnotationsDao()
                        .updateAnnotation(widget.annotation.annotationId,
                            _contentController.text)
                        .whenComplete(
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text(
                                  'Anotação atualizada com sucesso!'),
                            ),
                          ),
                        );
                  } else {
                    AnnotationsDao()
                        .save(
                          AnnotationModel(
                              annotationId: const Uuid().v1(),
                              title: title,
                              content: _contentController.text,
                              book: widget.annotation.book,
                              chapter: widget.annotation.chapter,
                              verseStart: widget.annotation.verseStart,
                              verseEnd: widget.annotation.verseEnd),
                        )
                        .whenComplete(
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text(
                                  'Anotação salva com sucesso!'),
                            ),
                          ),
                        );
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
          decoration:
              const InputDecoration(hintText: 'Digite sua anotação aqui...'),
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
