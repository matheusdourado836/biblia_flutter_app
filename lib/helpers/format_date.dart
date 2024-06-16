String formattedDate({required String dateString}) {
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