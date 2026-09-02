import 'package:flutter/material.dart';

class AdDialog extends StatelessWidget {
  final Function() onTap;
  const AdDialog({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limite de perguntas atingido'),
      content: const Text('Você atingiu o limite de perguntas gratuitas. Deseja assistir à um anúncio para ganhar mais perguntas?'),
      actions: [
        TextButton(onPressed: onTap, child: const Text('Sim')),
        TextButton(onPressed: (() => Navigator.pop(context)), child: const Text('Não')),
      ],
    );
  }
}
