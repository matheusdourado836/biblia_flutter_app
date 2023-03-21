import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

randomVerseDialog(Map<String, dynamic> verseInfo,
    {String title = 'Título', String content = 'Conteúdo'}) {
  return showDialog(
      context: navigatorKey!.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          content: InkWell(
              onTap: ((){
                Navigator.pushNamed(context, 'verses_screen', arguments: verseInfo);
              }),
              child: Text(content, style: Theme.of(context).textTheme.bodyMedium,)),
          actions: [
            IconButton(
              onPressed: () {
                Share.share('$title $content');
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: '$title $content'))
                    .then(
                      (value) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 1000),
                        content: Text('Texto Copiado para área de transferência'),
                      ),
                    ),
                      Navigator.pop(context, true)
                  },
                );
              },
              icon: const Icon(Icons.copy),
            ),
          ],
        );
      });
}