import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

class DevocionalSelected extends StatefulWidget {
  final Devocional devocional;
  const DevocionalSelected({super.key, required this.devocional});

  @override
  State<DevocionalSelected> createState() => _DevocionalSelectedState();
}

class _DevocionalSelectedState extends State<DevocionalSelected> {
  QuillController? _controller;

  @override
  void initState() {
    final document = Document.fromJson(widget.devocional.styles!);
    _controller = QuillController(
      readOnly: true,
      document: document,
      selection: const TextSelection.collapsed(offset: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.devocional.titulo!),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
              controller: _controller!,
              padding: const EdgeInsets.symmetric(vertical: 16),
              checkBoxReadOnly: true,
              showCursor: false
              )
            ),
          ),
        ),
      ),
    );
  }
}
