import '../helpers/format_data.dart';

class ReadingPlan {
  int? id;
  int? planId;
  int? durationDays;
  String? startDate;
  int? currentDay;
  int? completed;

  ReadingPlan(
      {this.id,
        this.planId,
        this.durationDays,
        this.startDate,
        this.currentDay,
        this.completed});

  ReadingPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planId = json['plan_id'];
    durationDays = json['duration_days'];
    startDate = formattedDate(dateString: json['start_date']);
    currentDay = json['current_day'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['plan_id'] = planId;
    data['duration_days'] = durationDays;
    data['start_date'] = startDate;
    data['current_day'] = currentDay;
    data['completed'] = completed;
    return data;
  }
}
