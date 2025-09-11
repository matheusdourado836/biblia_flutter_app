import 'package:flutter/material.dart';

class RemoveAllDialog extends StatefulWidget {
  const RemoveAllDialog({super.key});

  @override
  State<RemoveAllDialog> createState() => _RemoveAllDialogState();
}

class _RemoveAllDialogState extends State<RemoveAllDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar ação'),
      content: const Text('Deseja realmente remover todas as versões baixadas?\nEsta acão não poderá ser desfeita'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sim')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}
