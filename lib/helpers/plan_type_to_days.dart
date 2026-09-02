import 'package:biblia_flutter_app/models/enums.dart';

int planTypeToChapters({required PlanType planType, bool? lastDay}) {
  switch(planType.code) {
    case 0:
      return (lastDay == null) ? 3 : 4;
    case 1:
      return (lastDay == null) ? 13 : 19;
    case 2:
      return 4;
    case 3:
      return (lastDay == null) ? 5 : 4;
    default:
      return 0;
  }
}