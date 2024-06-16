enum PlanType {
  ONE_YEAR(0, 'one_year'),
  THREE_MONTHS(1, 'three_months'),
  SIX_MONTHS(2, 'two_months');

  final int code;
  final String description;
  const PlanType(this.code, this.description);

  static PlanType fromCode(int code) {
    return PlanType.values.firstWhere((e) => e.code == code);
  }
}