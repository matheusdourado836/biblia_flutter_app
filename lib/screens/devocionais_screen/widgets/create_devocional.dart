import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/save_bottom_sheet.dart';
import 'package:flutter/material.dart';

class CreateDevocional extends StatefulWidget {
  const CreateDevocional({super.key});

  @override
  State<CreateDevocional> createState() => _CreateDevocionalState();
}

class _CreateDevocionalState extends State<CreateDevocional> {
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  int textValue = 1;
  IconData textAlignIcon = Icons.align_horizontal_center;

  TextAlign textAlign = TextAlign.center;

  void switchTextAlign(int value) {
    if (value == 0) {
      textAlign = TextAlign.start;
      textAlignIcon = Icons.align_horizontal_left;
    } else if (value == 1) {
      textAlign = TextAlign.center;
      textAlignIcon = Icons.align_horizontal_center;
    } else {
      textAlign = TextAlign.end;
      textAlignIcon = Icons.align_horizontal_right;
    }

    setState(() {
      textAlign;
      textAlignIcon;
    });
  }

  int textAlignToInt(TextAlign textAlign) {
    if (textAlign == TextAlign.start) {
      return 0;
    } else if (textAlign == TextAlign.center) {
      return 1;
    } else {
      return 2;
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _titleController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: (() {
                    if (textValue == 2) {
                      setState(() => textValue = 0);
                      switchTextAlign(textValue);
                      return;
                    }
                    setState(() => textValue++);
                    switchTextAlign(textValue);
                  }),
                  icon: Icon(textAlignIcon)),
              Expanded(
                child: TextField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(fontSize: 12),
                      hintText: 'Passagem de referência...',
                      suffixIcon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      enabledBorder: InputBorder.none),
                ),
              ),
              IconButton(
                  onPressed: (() => Navigator.pop(context)),
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    textAlign: textAlign,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        fontStyle: FontStyle.italic),
                    expands: false,
                    decoration: const InputDecoration(
                      hintText: 'Tema do devocional...',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _textoController,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 22),
                      textAlign: textAlign,
                      decoration: const InputDecoration(
                          hintText: 'Escreva seu devocional aqui...'),
                      keyboardType: TextInputType.multiline,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                    ),
                  )
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: (() {
                final devocional = Devocional(
                    createdAt: DateTime.now().toIso8601String(),
                    referencia: _referenceController.text,
                    titulo: _titleController.text,
                    texto: _textoController.text,
                    textAlign: textAlignToInt(textAlign),
                    status: 0,
                    qtdCurtidas: 0,
                    qtdComentarios: 0);
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).primaryColor,
                    isScrollControlled: true,
                    isDismissible: false,
                    showDragHandle: true,
                    enableDrag: false,
                    builder: (context) =>
                        SaveBottomSheet(devocional: devocional));
              }),
              child: const Text('Salvar'))
        ],
      ),
    );
  }
}
