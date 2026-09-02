import 'package:biblia_flutter_app/data/bible_data_controller.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> verse(int number, {bool selected = true}) => {
      'bookName': 'João',
      'chapter': 3,
      'verseNumber': number,
      'isSelected': selected,
    };

void main() {
  late BibleDataController controller;

  setUp(() => controller = BibleDataController());

  group('getStartAndEndIndex', () {
    test('intervalo de versículos monta o título com início e fim', () {
      controller.getStartAndEndIndex([verse(16), verse(17), verse(18)]);

      expect(controller.startIndex, 16);
      expect(controller.endIndex, 18);
      expect(controller.annotationTitle, 'João 3:16-18');
    });

    test('versículo único zera o início e usa o título simples', () {
      controller.getStartAndEndIndex([verse(16)]);

      expect(controller.startIndex, 0);
      expect(controller.endIndex, 16);
      expect(controller.annotationTitle, 'João 3:16');
    });

    test('ignora os versículos não selecionados', () {
      controller.getStartAndEndIndex([
        verse(14, selected: false),
        verse(16),
        verse(17),
        verse(20, selected: false),
      ]);

      expect(controller.startIndex, 16);
      expect(controller.endIndex, 17);
      expect(controller.annotationTitle, 'João 3:16-17');
    });

    test('chamadas seguidas não vazam estado da anterior', () {
      controller.getStartAndEndIndex([verse(16), verse(17)]);
      controller.getStartAndEndIndex([verse(1)]);

      expect(controller.startIndex, 0);
      expect(controller.endIndex, 1);
      expect(controller.annotationTitle, 'João 3:1');
    });
  });

  group('getColorName', () {
    test('mapeia cada cor para o índice usado na lista de ícones', () {
      expect(controller.getColorName('todas'), 0);
      expect(controller.getColorName('azul'), 1);
      expect(controller.getColorName('ciano'), 2);
      expect(controller.getColorName('rosa'), 8);
    });

    test('cor desconhecida cai no índice 0 em vez de devolver null', () {
      expect(controller.getColorName('turquesa'), 0);
      expect(controller.getColorName(''), 0);
    });

    test('todos os índices retornados são válidos para uma lista de 9 cores', () {
      const cores = ['todas', 'azul', 'ciano', 'amarelo', 'marrom', 'vermelho', 'laranja', 'verde', 'rosa'];
      final indices = cores.map(controller.getColorName).toSet();
      expect(indices, {0, 1, 2, 3, 4, 5, 6, 7, 8});
    });
  });
}
