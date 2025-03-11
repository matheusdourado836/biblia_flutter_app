import 'dart:convert';

import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/annotation.dart';

class AnnotationWidget extends StatefulWidget {
  final Annotation annotation;
  final List<dynamic> verses;
  final bool isEditing;

  const AnnotationWidget(
      {super.key,
      required this.annotation,
      required this.isEditing,
      required this.verses});

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _textFocus = FocusNode();
  String title = '';
  String annotationId = '';
  bool isEditing = false;

  Future<void> saveAnnotation() async {
    _textFocus.unfocus();
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    String plainText = _controller.document.toPlainText();
    String styledJson = jsonEncode(_controller.document.toDelta().toJson());
    if (isEditing) {
      await versesProvider.updateAnnotation(
        annotationId: annotationId,
        content: plainText,
        style: styledJson
      );
    } else {
      final newId = const Uuid().v1();
      final savedAnnotation = Annotation(
        annotationId: newId,
        title: title,
        content: plainText,
        book: widget.annotation.book,
        chapter: widget.annotation.chapter,
        verseStart: widget.annotation.verseStart,
        verseEnd: widget.annotation.verseEnd,
        style: styledJson
      );
      await versesProvider.saveAnnotation(annotation: savedAnnotation);
      setState(() {
        isEditing = true;
        annotationId = newId;
      });
    }
    showCustomSnackBar(child: const Text('Anotação salva com sucesso!'));
    versesProvider.refresh();
  }

  void loadAnnotation() {
    if (widget.annotation.style != null) {
      _controller.document = Document.fromJson(jsonDecode(widget.annotation.style!));
    } else {
      _controller.document = Document()..insert(0, widget.annotation.content);
    }
  }

  @override
  void initState() {
    isEditing = widget.isEditing;
    if(isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => loadAnnotation());
    }
    annotationId = widget.annotation.annotationId;
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
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                onPressed: (() {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0),
                        title: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadiusDirectional.only(
                              topStart: Radius.circular(26),
                              topEnd: Radius.circular(26)
                            )
                          ),
                          child: Center(
                            child: Text(
                              '${widget.annotation.book} capítulo ${widget.annotation.chapter}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
                            )
                          )
                        ),
                        content: SelectionArea(
                          child: ListView.builder(
                            itemCount: widget.verses.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Text.rich(TextSpan(
                                text: '${(index + 1).toString()}  ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: widget.verses[index],
                                    style: const TextStyle(fontWeight: FontWeight.normal)
                                  )
                                ])
                              );
                            }
                            ),
                        ),
                      );
                    });
                }),
                  icon: const Icon(Icons.menu_book_outlined)
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!_controller.document.isEmpty()) {
                saveAnnotation();
              }
            },
            icon: const Icon(Icons.check)
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              color: Theme.of(context).primaryColor,
              showAlignmentButtons: true,
              multiRowsDisplay: false,
              showQuote: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              showClipboardCut: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              focusNode: _textFocus,
              config: QuillEditorConfig(
                onTapOutsideEnabled: true,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                placeholder: 'Escreva sua anotação aqui...',
                customStyles: DefaultStyles(
                  placeHolder: DefaultListBlockStyle(
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      fontStyle: FontStyle.italic
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    null,
                    null
                  )
                )
              )
            ),
          ),
        ],
      ),
    );
  }
}
