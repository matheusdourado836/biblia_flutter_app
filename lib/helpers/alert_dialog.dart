import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';

alertDialog({String content = 'Não foi possível completar o login', String title = 'Alerta'}) {
  return showDialog(
      context: navigatorKey!.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.80),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(27), topRight: Radius.circular(27))
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          content: Text(content, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium,),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.white),
                  minimumSize: const Size(80, 36),
                  backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.80)),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      });
}