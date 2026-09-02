String formattedDate({required String dateString}) {
  final createdAt = DateTime.parse(dateString);
  String day = createdAt.day < 10 ? '0${createdAt.day}' : createdAt.day.toString();
  String month = createdAt.month < 10 ? '0${createdAt.month}' : createdAt.month.toString();
  int year = createdAt.year;

  if(DateTime.now().difference(createdAt).inHours <= 24) {
    return 'Hoje';
  }

  return 'Em $day/$month/$year';
}

String formattedDatePlan({required String dateString}) {
  final createdAt = DateTime.parse(dateString);
  String day = createdAt.day < 10 ? '0${createdAt.day}' : createdAt.day.toString();
  String month = createdAt.month < 10 ? '0${createdAt.month}' : createdAt.month.toString();
  int year = createdAt.year;

  return '$day/$month/$year';
}

String planStringDate(DateTime date) {
  List<String> monthNames = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro'
  ];
  String day = date.day.toString().padLeft(2, '0');
  String month = monthNames[date.month - 1];
  return '$day de\n$month';
}

String formatInfoQuantity(int info) {
  String infoString = info.toString();
  if(info <= 9999) {
    return infoString;
  }else if(info <= 99999) {
    return '${infoString.substring(0, 2)}.${infoString[3]}k';
  }else if(info <= 999999) {
    return '${infoString.substring(0, 3)}k';
  }else {
    return '${infoString.substring(0, 3)}mi';
  }
}

class FirebaseErrorTranslator {
  static String translate(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta. Por favor, tente novamente.';
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado.';
      case 'invalid-email':
        return 'E-mail inválido. Por favor, insira um e-mail válido.';
      case 'invalid-credential':
        return 'As credenciais fornecidas estão incorretas ou expiraram.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    }
  }
}