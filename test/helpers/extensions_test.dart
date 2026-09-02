import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrFormat', () {
    test('formata data no padrão brasileiro com zero à esquerda', () {
      expect(DateTime(2026, 3, 7).formatted(), '07/03/2026');
      expect(DateTime(2026, 12, 25).formatted(), '25/12/2026');
    });

    test('inclui hora quando solicitado', () {
      expect(DateTime(2026, 3, 7, 9, 5).formatted(includeTime: true), '07/03/2026 09h 05m');
      expect(DateTime(2026, 3, 7, 18, 40).formatted(includeTime: true), '07/03/2026 18h 40m');
    });

    test('formattedShort devolve apenas hora e minuto', () {
      expect(DateTime(2026, 3, 7, 8, 3).formattedShort(), '08:03');
      expect(DateTime(2026, 3, 7, 23, 59).formattedShort(), '23:59');
    });

    test('toIso8601DateOnly descarta a parte de horário', () {
      expect(DateTime(2026, 3, 7, 13, 22).toIso8601DateOnly(), '2026-03-07');
    });
  });
}
