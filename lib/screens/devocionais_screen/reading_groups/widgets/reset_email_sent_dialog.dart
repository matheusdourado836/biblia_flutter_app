import 'package:flutter/material.dart';

class ResetEmailSentDialog extends StatelessWidget {
  final String email;
  const ResetEmailSentDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('E-mail enviado!', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: '\nUm email de redefinição de senha foi enviado para:\n',
              style: const TextStyle(fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 3,
                    fontWeight: FontWeight.bold
                  ),
                ),
                TextSpan(
                  text: '\nCheque seu email e clique no link para redefinir a senha.',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16, height: 2),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}
