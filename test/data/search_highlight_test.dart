import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> result(String verse, {required int matchStart, required int matchLength}) => {
      'verse': verse,
      'matchStart': matchStart,
      'matchLength': matchLength,
    };

String textOf(List<TextSpan> spans) => spans.map((s) => s.text).join();

void main() {
  late SearchVersesProvider provider;
  const base = TextStyle(fontSize: 16);

  setUp(() => provider = SearchVersesProvider());

  group('buildHighlightedSpans', () {
    test('destaca o trecho encontrado sem alterar o texto do versículo', () {
      const verse = 'No princípio criou Deus os céus e a terra';
      final spans = provider.buildHighlightedSpans(
        result(verse, matchStart: 19, matchLength: 4),
        baseStyle: base,
      );

      expect(textOf(spans), verse);
      expect(spans.any((s) => s.text == 'Deus' && s.style?.fontWeight == FontWeight.bold), isTrue);
    });

    test('match no início não cria trecho vazio à esquerda', () {
      final spans = provider.buildHighlightedSpans(
        result('Deus é amor', matchStart: 0, matchLength: 4),
        baseStyle: base,
      );

      expect(spans.first.text, 'Deus');
      expect(textOf(spans), 'Deus é amor');
    });

    test('match no fim não cria trecho vazio à direita', () {
      final spans = provider.buildHighlightedSpans(
        result('O Senhor é o meu pastor', matchStart: 17, matchLength: 6),
        baseStyle: base,
      );

      expect(spans.last.text, 'pastor');
      expect(textOf(spans), 'O Senhor é o meu pastor');
    });

    // Regressão: na busca precisa o casamento acontece sobre o texto
    // normalizado, então indexOf no texto original pode devolver -1.
    test('sem posição de match devolve o versículo inteiro em vez de estourar', () {
      const verse = 'Bem-aventurados os mansos, porque eles herdarão a terra';

      expect(
        () => provider.buildHighlightedSpans(
          result(verse, matchStart: -1, matchLength: 6),
          baseStyle: base,
        ),
        returnsNormally,
      );

      final spans = provider.buildHighlightedSpans(
        result(verse, matchStart: -1, matchLength: 6),
        baseStyle: base,
      );
      expect(spans, hasLength(1));
      expect(spans.single.text, verse);
    });

    test('match que ultrapassa o tamanho do versículo não estoura', () {
      const verse = 'Deus é amor';
      final spans = provider.buildHighlightedSpans(
        result(verse, matchStart: 8, matchLength: 50),
        baseStyle: base,
      );

      expect(textOf(spans), verse);
    });
  });
}
