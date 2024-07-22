import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailDialog extends StatefulWidget {
  final Devocional devocional;
  const EmailDialog({super.key, required this.devocional});

  @override
  State<EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends State<EmailDialog> {
  final GlobalKey<FormState> _key = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  bool _isLoading = false;

  void saveUserPost(String devocionalId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userPosts = prefs.getStringList('posts') ?? [];

    userPosts.add(devocionalId);

    prefs.setStringList('posts', userPosts);
  }

  Widget _loading() => SizedBox(
    height: 25,
    width: 25,
    child: CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
      strokeWidth: 2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Tudo certo!', textAlign: TextAlign.center),
      content: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Você pode adicionar um email para ser notificado sobre o status de sua publicação:', textAlign: TextAlign.center),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Email (opcional)',
                hintStyle: const TextStyle(fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface))
              ),
              validator: (value) {
                if(value != null && value.isNotEmpty && value != _confirmEmailController.text) {
                  return 'os emails devem ser iguais';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmEmailController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Confirme seu Email',
                hintStyle: const TextStyle(fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface))
              ),
              validator: (value) {
                if(value != null && value.isNotEmpty && value != _emailController.text) {
                  return 'os emails devem ser iguais';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (() {
            if(_key.currentState!.validate()) {
              final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
              if(_confirmEmailController.text.isNotEmpty) {
                widget.devocional.contactEmail = _confirmEmailController.text;
              }
              setState(() => _isLoading = true);
              devocionalProvider.postDevocional(devocional: widget.devocional).then((value) {
                setState(() => _isLoading = false);
                if (value.isNotEmpty) {
                  saveUserPost(value);

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const _DevocionalSavedDialog()
                  );
                }
              });
            }
          }),
          child: (_isLoading) ? _loading() : const Text('Continuar')
        )
      ],
    );
  }
}

class _DevocionalSavedDialog extends StatelessWidget {
  const _DevocionalSavedDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Obrigado por compartilhar seu momento conosco!', textAlign: TextAlign.center,),
      content: const Text('Iremos analisar se o seu post está de acordo com as nossas normas e rapidamente iremos disponibilizá-lo no feed.', textAlign: TextAlign.center,),
      actions: [
        TextButton(onPressed: (() => Navigator.popUntil(context, (route) => route.settings.name == 'feed_screen')), child: const Text('Ok'))
      ],
    );
  }
}