class DailyRead {
  int? id;
  int? progressId;
  int? dayNumber;
  String? chapter;
  int? completed;

  DailyRead(
      {this.id, this.progressId, this.dayNumber, this.chapter, this.completed});

  DailyRead.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    progressId = json['progress_id'];
    dayNumber = json['day_number'];
    chapter = json['chapter'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['progress_id'] = progressId;
    data['day_number'] = dayNumber;
    data['chapter'] = chapter;
    data['completed'] = completed;
    return data;
  }
}

class GroupDailyReading {
  Map<String, DayReading> dias;

  GroupDailyReading({required this.dias});

  /// Converte o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      "dias": dias.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Converte JSON em um objeto GroupDailyReading
  factory GroupDailyReading.fromJson(Map<String, dynamic> json) {
    final Map<String, DayReading> dias = {};
    if (json["dias"] != null) {
      json["dias"].forEach((key, value) {
        dias[key] = DayReading.fromJson(value);
      });
    }
    return GroupDailyReading(dias: dias);
  }
}

class DayReading {
  Map<String, List<String>> capitulos;

  DayReading({required this.capitulos});

  /// Converte o objeto em JSON
  Map<String, dynamic> toJson() {
    return {
      "capitulos": capitulos,
    };
  }

  /// Converte JSON em um objeto DayReading
  factory DayReading.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> capitulos = {};
    if (json["capitulos"] != null) {
      json["capitulos"].forEach((key, value) {
        capitulos[key] = List<String>.from(value);
      });
    }
    return DayReading(capitulos: capitulos);
  }
}