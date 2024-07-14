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

enum Status {
  APPROVED(0, 'Aprovado'),
  PENDING(1, 'Pendente'),
  REJECTED(2, 'Rejeitado');

  final int code;
  final String description;
  const Status(this.code, this.description);

  static Status fromCode(int code) {
    return Status.values.firstWhere((e) => e.code == code);
  }
}

enum ReportReason {
  SEXUAL_CONTENT('Conteúdo sexual'),
  VIOLENT_OR_REPULSIVE_CONTENT('Conteúdo violento ou repulsivo'),
  HATESPEECH_OR_ABUSE('Conteúdo de incitação ao ódio ou abusivo'),
  BULLYING_OR_HARASSMENT('Assédio ou bullying'),
  VIOLATE_MY_RIGHTS('Viola meus direitos'),
  NOT_LISTED('Não listado');

  final String description;
  const ReportReason(this.description);

  static ReportReason fromInt(int index) {
    return ReportReason.values.firstWhere((report) => report == ReportReason.values[index]);
  }
}