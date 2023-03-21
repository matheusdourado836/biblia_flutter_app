import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/exception_dialog.dart';

class EmailScreen extends StatelessWidget {
  final String emailAddress = 'mathewdourado@gmail.com';
  final String emailSubject = 'Feedback do usuário';
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar feedback'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Enviar e-mail'),
          onPressed: () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: emailAddress,
              query: encodeQueryParameters(<String, String>{
                'subject': 'Feedback de Erro no aplicativo!',
              }),
            );

            try {
              await launchUrl(emailLaunchUri);
            }catch (e) {
              exceptionDialog(content: e.toString());
            }
          },
        ),
      ),
    );
  }
}
