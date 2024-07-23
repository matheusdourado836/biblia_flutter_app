import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/save_devocional_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../data/devocional_provider.dart';
import '../../../data/theme_provider.dart';
import '../../../helpers/tutorial_widget.dart';

class CreateDevocional extends StatefulWidget {
  const CreateDevocional({super.key});

  @override
  State<CreateDevocional> createState() => _CreateDevocionalState();
}

class _CreateDevocionalState extends State<CreateDevocional> {
  final QuillController _controller = QuillController.basic();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _textFocus = FocusNode();
  final GlobalKey quillKey = GlobalKey();
  TutorialCoachMark? _coachMark;
  List<TargetFocus> _targets = [];


  void showTutorial() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    if(!devocionalProvider.tutorials.contains('tutorial 3')) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      initTargets();
      _coachMark = TutorialCoachMark(
          onSkip: () {
            devocionalProvider.markTutorial(3);
            return true;
          },
          onFinish: () {
            devocionalProvider.markTutorial(3);
          },
          colorShadow: (themeProvider.isOn) ? Colors.black : Theme.of(context).cardTheme.color!,
          targets: _targets,
          hideSkip: true
      )..show(context: context);
    }
  }

  void initTargets() {
    _targets = [
      TargetFocus(
          identify: 'bg-image-key',
          keyTarget: quillKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Arraste para o lado para descobrir os diversos tipos de estilização disponíveis para personalizar seu texto',
                      skip: '',
                      next: 'Fechar',
                      onNext: (() {
                        c.skip();
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            ),
          ]
      ),
    ];
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () => showTutorial());
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
    _coachMark?.finish();
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
        toolbarHeight: kDefaultToolbarSize + 50,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Form(
          key: _formKey,
          child: TextFormField(
            controller: _titleController,
            focusNode: _titleFocus,
            validator: (value) {
              if(value?.isEmpty ?? true) {
                return 'o título é obrigatório';
              }
              return null;
            },
            decoration: const InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                hintText: 'Título...',
                suffixIcon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                ),
                enabledBorder: InputBorder.none),
          ),
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
          SizedBox(
            key: quillKey,
            child: QuillToolbar.simple(
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
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: QuillEditor.basic(
                focusNode: _textFocus,
                  configurations: QuillEditorConfigurations(
                    controller: _controller,
                    isOnTapOutsideEnabled: true,
                    onTapOutside: (p, e) {
                      _textFocus.unfocus();
                    },
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
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
                      contactEmail: null,
                      titulo: _titleController.text,
                      styles: styles,
                      plainText: plainText,
                      status: 1,
                      qtdCurtidas: 0,
                      qtdViews: 0,
                      qtdComentarios: 0
                  );
                  if(_formKey.currentState!.validate()) {
                    if(_controller.document.isEmpty()) {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text('Erro'),
                        content: const Text('Não é possível enviar um devocional vazio.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
                        ],
                      ));
                      return;
                    }
                    Navigator.push(
                        context,
                        PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SaveDevocionalWidget(devocional: devocional))
                    );
                  }
                }),
                child: const Text('Próximo')
            ),
          )
        ],
      ),
    );
  }
}
