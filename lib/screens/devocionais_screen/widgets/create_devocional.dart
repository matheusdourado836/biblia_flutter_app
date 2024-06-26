import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/save_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CreateDevocional extends StatefulWidget {
  const CreateDevocional({super.key});

  @override
  State<CreateDevocional> createState() => _CreateDevocionalState();
}

class _CreateDevocionalState extends State<CreateDevocional> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _textFocus = FocusNode();

  @override
  void initState() {

    _titleFocus.addListener(() {
      if (_titleFocus.hasFocus) {
        _textFocus.unfocus();
      }
    });

    _textFocus.addListener(() {
      if (_textFocus.hasFocus) {
        _titleFocus.unfocus();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    _titleFocus.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: TextField(
          controller: _titleController,
          focusNode: _titleFocus,
          decoration: const InputDecoration(
              hintStyle: TextStyle(fontSize: 14),
              hintText: 'Título...',
              suffixIcon: Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              enabledBorder: InputBorder.none),
        ),
        actions: [
          IconButton(
              onPressed: (() => Navigator.pop(context)),
              icon: const Icon(Icons.close))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              color: Theme.of(context).primaryColor,
              showAlignmentButtons: true,
              multiRowsDisplay: false,
              showQuote: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              showClipboardCut: false,
              showSubscript: false,
              showSuperscript: false,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('pt', 'BR'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: QuillEditor.basic(
                focusNode: _textFocus,
                  configurations: QuillEditorConfigurations(
                    controller: _controller,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    placeholder: 'Escreva seu devocional aqui...',
                    customStyles: DefaultStyles(
                      placeHolder: DefaultListBlockStyle(
                        TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          fontStyle: FontStyle.italic
                        ),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                        null
                      )
                    )
                  )
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                fixedSize: Size(MediaQuery.of(context).size.width * .85, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                )
            ),
            onPressed: (() {
              _titleFocus.unfocus();
              _textFocus.unfocus();
              final styles = _controller.document.toDelta().toJson();
              final textDivided = _controller.document.toPlainText().split('\n').where((line) => line.trim().isNotEmpty).toList();
              final plainText = textDivided.join('\n').split('\n').take(4).join('\n');
              final devocional = Devocional(
                  createdAt: DateTime.now().toIso8601String(),
                  titulo: _titleController.text,
                  styles: styles,
                  plainText: plainText,
                  status: 0,
                  qtdCurtidas: 0,
                  qtdComentarios: 0
              );
              showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  isScrollControlled: true,
                  isDismissible: false,
                  showDragHandle: true,
                  enableDrag: false,
                  builder: (context) => SaveBottomSheet(devocional: devocional)
              );
            }),
            child: const Text('Próximo')
        ),
      ),
    );
  }
}
