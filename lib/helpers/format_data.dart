String formattedDate({required String dateString, bool plan = false}) {
  final createdAt = DateTime.parse(dateString);
  String day = createdAt.day < 10 ? '0${createdAt.day}' : createdAt.day.toString();
  String month = createdAt.month < 10 ? '0${createdAt.month}' : createdAt.month.toString();
  int year = createdAt.year;

  if(plan) {
    return '$day/$month/$year';
  }

  if(DateTime.now().day == createdAt.day && DateTime.now().difference(createdAt).inHours <= 24) {
    return 'Hoje';
  }

  return 'Em $day/$month/$year';
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