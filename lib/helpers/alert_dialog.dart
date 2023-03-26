import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';

alertDialog({String content = 'Não foi possível completar o login', String title = 'Alerta!'}) {
  return showDialog(
      context: navigatorKey!.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
          ),
          content: Text(content, style: Theme.of(context).textTheme.bodyMedium,),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      });
}