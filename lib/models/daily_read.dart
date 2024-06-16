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
