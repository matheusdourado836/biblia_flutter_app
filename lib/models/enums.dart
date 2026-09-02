enum PlanType {
  oneYear(0, 'one_year'),
  threeMonths(1, 'three_months'),
  twoMonthsNew(2, 'two_months_new'),
  sixMonthsOld(3, 'six_months_old');

  final int code;
  final String description;
  const PlanType(this.code, this.description);

  static PlanType fromCode(int code) {
    return PlanType.values.firstWhere((e) => e.code == code);
  }
}

enum Status {
  approved(0, 'Aprovado'),
  pending(1, 'Pendente'),
  rejected(2, 'Rejeitado');

  final int code;
  final String description;
  const Status(this.code, this.description);

  static Status fromCode(int code) {
    return Status.values.firstWhere((e) => e.code == code);
  }
}

enum ReportReason {
  sexualContent('Conteúdo sexual'),
  violentOrRepulsiveContent('Conteúdo violento ou repulsivo'),
  hatespeechOrAbuse('Ódio gratuito'),
  bullyingOrHarassment('Assédio ou bullying'),
  violateMyRights('Viola meus direitos'),
  notListed('Não listado');

  final String description;
  const ReportReason(this.description);

  static ReportReason fromInt(int index) {
    return ReportReason.values.firstWhere((report) => report == ReportReason.values[index]);
  }
}