import 'package:flutter/material.dart';

class CancelPlanDialog extends StatelessWidget {
  final void Function() execute;
  const CancelPlanDialog({super.key, required this.execute});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar plano'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tem certeza que deseja cancelar seu plano de leitura?'),
          SizedBox(height: 8),
          Text('Todo o progresso feito será perdido.'),
        ],
      ),
      actions: [
        TextButton(onPressed: execute, child: const Text('Sim')),
        TextButton(onPressed: (() => Navigator.pop(context)), child: const Text('Não')),
      ],
    );
  }
}
