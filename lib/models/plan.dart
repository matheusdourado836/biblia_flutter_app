import 'package:biblia_flutter_app/models/enums.dart';

class Plan {
  final String label;
  final String description;
  final String imgPath;
  final String bgSelectedImgPath;
  final PlanType planType;
  final int duration;
  final int qtdChapters;
  final int? bibleLength;
  final bool? isNewTestament;

  Plan({
    required this.label,
    required this.description,
    required this.imgPath,
    required this.bgSelectedImgPath,
    required this.planType,
    required this.duration,
    required this.qtdChapters,
    this.bibleLength,
    this.isNewTestament
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    label: json["label"],
    description: json["description"],
    imgPath: json["imgPath"],
    bgSelectedImgPath: json["bgSelectedImgPath"],
    planType: PlanType.fromCode(json["code"]),
    duration: json["duration"],
    qtdChapters: json["qtdChapters"],
    bibleLength: json["bibleLength"],
    isNewTestament: json["isNewTestament"]
  );
}