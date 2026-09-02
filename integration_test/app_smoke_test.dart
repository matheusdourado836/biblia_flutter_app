import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Deixa o app respirar em tempo real: `pump` sozinho não espera o boot
/// assíncrono (assets, SQLite, Firebase, Sentry) terminar.
Future<void> settle(WidgetTester tester, {int seconds = 8}) async {
  for (var i = 0; i < seconds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // O app só pode ser inicializado uma vez por processo: `main()` chama runApp
  // dentro do SentryFlutter.init, e um segundo boot quebra o binding. Por isso
  // todo o smoke roda em um único teste, em etapas.
  testWidgets('smoke completo do app após o refactor', (tester) async {
    // Não dá para aguardar `main()`: ele só resolve quando o app encerra
    // (o runApp fica dentro do appRunner do SentryFlutter.init).
    await tester.runAsync(() async {
      app.main();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await settle(tester, seconds: 25);

    // A árvore de widgets não fica visível para o binding do teste porque o
    // SentryFlutter.init roda o runApp na própria zone; a UI é conferida por
    // screenshot. Aqui validamos o runtime do app já inicializado.
    expect(app.navigatorKey!.currentContext, isNotNull,
        reason: 'o MaterialApp deveria ter sido montado');

    // ---------- carregamento sob demanda da Bíblia ----------
    final data = BibleData().data;
    expect(data, isNotEmpty, reason: 'a versão de referência deveria estar carregada');
    expect(data[0]["version"], 'nvi',
        reason: 'todo o app indexa data[0] como fonte de nomes de livros');
    expect((data[0]["text"] as List).length, 66);
    expect(data.length, lessThanOrEqualTo(2),
        reason: 'só a versão de referência e a preferida deveriam estar em memória');

    await tester.runAsync(() async {
      // ---------- montagem dos versículos ----------
      final versesProvider = VersesProvider();
      await versesProvider.loadUserData();

      final books = await versesProvider.getAllBooks();
      expect(books.length, 66);
      expect(books.first['bookName'], 'Gênesis');

      final genesis = versesProvider.loadVerses(0, 'Gênesis');
      expect(genesis.keys.length, 50, reason: 'Gênesis tem 50 capítulos');
      expect(genesis[1], isNotEmpty);
      expect(genesis[1][0]['verse'].toString(), contains('No princípio'));

      // Versão ainda não decodificada cai na de referência sem estourar e não
      // pode corromper data[0].
      final acf = versesProvider.loadVerses(0, 'Gênesis', versionName: 'acf');
      expect(acf.keys.length, 50);
      expect(BibleData().data[0]["version"], 'nvi');

      // ---------- busca (roda em isolate) ----------
      final search = SearchVersesProvider();

      final results = await search.searchVerses('No princípio', 'NVI (Nova Versão Internacional)');
      expect(results, isNotEmpty);
      expect(results.first['verse'], contains('No princípio'));

      final spans = search.buildHighlightedSpans(
        results.first,
        baseStyle: const TextStyle(fontSize: 16),
      );
      expect(spans.map((s) => s.text).join(), results.first['verse'],
          reason: 'o destaque não pode alterar o texto do versículo');

      // Regressão: o filtro por livro nunca era aplicado (comparava String com
      // ValueNotifier), então a busca varria a Bíblia inteira.
      final somenteGenesis = await search.searchVerses(
        'Deus',
        'NVI (Nova Versão Internacional)',
        findInBookIndex: 0,
      );
      expect(somenteGenesis, isNotEmpty);
      expect(somenteGenesis.every((r) => r['book'] == 'Gênesis'), isTrue,
          reason: 'com um livro selecionado, só ele deveria aparecer');

      final bibliaToda = await search.searchVerses('Deus', 'NVI (Nova Versão Internacional)');
      expect(bibliaToda.length, greaterThan(somenteGenesis.length));

      // Filtro por testamento.
      final novoTestamento = await search.searchVerses(
        'Jesus',
        'NVI (Nova Versão Internacional)',
        findIn: 'novo testamento',
      );
      expect(novoTestamento, isNotEmpty);
      expect(novoTestamento.every((r) => r['bookIndex'] >= 39), isTrue);

      // Regressão: na busca precisa o casamento é feito sobre o texto
      // normalizado, então indexOf no texto cru pode devolver -1.
      final precisa = await search.searchVerses(
        'terra e a terra',
        'NVI (Nova Versão Internacional)',
        preciseSearch: true,
      );
      for (final r in precisa.take(50)) {
        expect(
          () => search.buildHighlightedSpans(r, baseStyle: const TextStyle(fontSize: 16)),
          returnsNormally,
        );
      }
    });

    expect(tester.takeException(), isNull, reason: 'nenhuma exceção deveria ter escapado');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
