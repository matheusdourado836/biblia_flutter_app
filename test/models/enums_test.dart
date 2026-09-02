import 'package:biblia_flutter_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanType', () {
    test('fromCode devolve o plano correspondente', () {
      expect(PlanType.fromCode(0), PlanType.oneYear);
      expect(PlanType.fromCode(3), PlanType.sixMonthsOld);
    });

    test('códigos e descrições são únicos (usados como chave em prefs e Firestore)', () {
      final codes = PlanType.values.map((p) => p.code).toSet();
      final descriptions = PlanType.values.map((p) => p.description).toSet();
      expect(codes.length, PlanType.values.length);
      expect(descriptions.length, PlanType.values.length);
    });

    test('ida e volta pelo código é estável', () {
      for (final plan in PlanType.values) {
        expect(PlanType.fromCode(plan.code), plan);
      }
    });
  });

  group('Status', () {
    test('fromCode cobre todos os valores', () {
      for (final status in Status.values) {
        expect(Status.fromCode(status.code), status);
      }
    });
  });

  group('ReportReason', () {
    test('fromInt respeita a ordem de declaração', () {
      expect(ReportReason.fromInt(0), ReportReason.sexualContent);
      expect(ReportReason.fromInt(ReportReason.values.length - 1), ReportReason.notListed);
    });

    test('toda razão tem descrição não vazia', () {
      for (final reason in ReportReason.values) {
        expect(reason.description, isNotEmpty);
      }
    });
  });
}
