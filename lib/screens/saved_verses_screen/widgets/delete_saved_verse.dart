import 'package:flutter/material.dart';

class DeleteSavedVerse extends StatelessWidget {
  final Function() onDelete;
  const DeleteSavedVerse({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Alerta',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      content: Text(
          'Tem certeza que deseja remover esse versículo de seus versículos salvos?',
          style: Theme.of(context).textTheme.bodyMedium
      ),
      actions: [
        TextButton(
          onPressed: onDelete,
          child: const Text('Sim'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'Não'),
          child: const Text('Não'),
        ),
      ],
    );
  }
}
