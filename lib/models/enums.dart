enum PlanType {
  ONE_YEAR(0, 'one_year'),
  THREE_MONTHS(1, 'three_months'),
  TWO_MONTHS_NEW(2, 'two_months_new'),
  SIX_MONTHS_OLD(3, 'six_months_old');

  final int code;
  final String description;
  const PlanType(this.code, this.description);

  static PlanType fromCode(int code) {
    return PlanType.values.firstWhere((e) => e.code == code);
  }
}