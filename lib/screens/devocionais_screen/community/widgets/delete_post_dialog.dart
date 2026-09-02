import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeletePostDialog extends StatefulWidget {
  final String devocionalId;
  final MyUser currentUser;
  final Function() refresh;
  const DeletePostDialog({super.key, required this.refresh, required this.currentUser, required this.devocionalId});

  @override
  State<DeletePostDialog> createState() => _DeletePostDialogState();
}

class _DeletePostDialogState extends State<DeletePostDialog> {
  bool _isLoading = false;
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
      title: const Text('Exlcuir post?'),
      actions: [
        TextButton(
            onPressed: () {
              final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
              setState(() => _isLoading = true);
              devocionalProvider.deletePost(widget.devocionalId).whenComplete(() {
                devocionalProvider.getUserDevocionais().whenComplete(() {
                  setState(() => _isLoading = false);
                  widget.refresh();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                });
              });
            },
            child: (_isLoading) ? _loading() : const Text('Sim')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
      ],
    );
  }
}
