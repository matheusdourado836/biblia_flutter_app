import 'package:flutter/material.dart';

class RemoveVersionDialog extends StatefulWidget {
  const RemoveVersionDialog({super.key});

  @override
  State<RemoveVersionDialog> createState() => _RemoveVersionDialogState();
}

class _RemoveVersionDialogState extends State<RemoveVersionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remover Versão'),
      content: const Text('Deseja realmente remover esta versão?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sim')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ]
    );
  }
}
