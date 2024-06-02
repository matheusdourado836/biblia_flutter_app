import 'package:flutter/material.dart';

class DevocionalSavedDialog extends StatelessWidget {
  const DevocionalSavedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Obrigado por compartilhar seu momento conosco!', textAlign: TextAlign.center,),
      content: const Text('Iremos analisar se o seu devocional está de acordo com as nossas normas e rapidamente iremos disponibilizá-lo em nosso feed', textAlign: TextAlign.center,),
      actions: [
        TextButton(onPressed: (() => Navigator.pushNamedAndRemoveUntil(context, 'feed_screen', (route) => false)), child: const Text('Ok'))
      ],
    );
  }
}
