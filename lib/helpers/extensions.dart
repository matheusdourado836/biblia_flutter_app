import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'format_data.dart';

extension BrFormat on DateTime {

  String formatted({bool includeTime = false}) {
    return '${day < 10 ? '0$day' : day}/${month < 10 ? '0$month' : month}/$year ${includeTime ? '${hour > 9 ? hour : '0$hour'}h ${minute > 9 ? minute : '0$minute'}m' : ''}'.trim();
  }


  String toIso8601DateOnly() {
    return toIso8601String().split('T').first;
  }

}

extension CustomSnackbar on State {
  void showCustomSnackBar({int? seconds, required Widget child}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: (seconds == null) ? 4 : seconds),
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
      content: child,
    ));
  }
}

extension CustomSnackbarStateless on StatelessWidget {
  void showCustomSnackBar({required BuildContext context, int? seconds, required Widget child}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: (seconds == null) ? 4 : seconds),
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      content: child,
    ));
  }
}

extension FirebaseAuthExceptionExtension on FirebaseAuthException {
  String get translated {
    return FirebaseErrorTranslator.translate(code);
  }
}

extension StringFormatter on String {
  String removerAcentos() {
    const acentos = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C'
    };

    String textoSemAcentos = this; // `this` refere-se à instância da String
    acentos.forEach((acento, semAcento) {
      textoSemAcentos = textoSemAcentos.replaceAll(acento, semAcento);
    });

    return textoSemAcentos;
  }
}