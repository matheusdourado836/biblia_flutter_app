import 'package:biblia_flutter_app/models/enums.dart';

int planTypeToDays({required PlanType planType}) {
  switch(planType.code) {
    case 0:
      return 397;
    case 1:
      return 92;
    case 2:
      return 60;
    default:
      return 0;
  }
}

int planTypeToChapters({required PlanType planType, bool? lastDay}) {
  switch(planType.code) {
    case 0:
      return (lastDay == null) ? 3 : 4;
    case 1:
      return (lastDay == null) ? 13 : 19;
    case 2:
      return 4;
    default:
      return 0;
  }
}