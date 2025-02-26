import 'package:flutter/material.dart';

class DeleteSavedVersesDialog extends StatelessWidget {
  final Function() onDelete;
  const DeleteSavedVersesDialog({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
        ),
        child: Center(
          child: Text(
            'Alerta',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
      content: Text(
          'Tem certeza que deseja deletar todos os seus versículos salvos?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(color: Colors.white),
                minimumSize: const Size(80, 36),
                backgroundColor: Colors.red
              ),
              onPressed: onDelete,
              child: Text(
                'Sim',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).highlightColor,
                  minimumSize: const Size(80, 36),
                  textStyle: const TextStyle(color: Colors.white)
              ),
              onPressed: () => Navigator.pop(context, 'Cancelar'),
              child: Text('Cancelar', style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
