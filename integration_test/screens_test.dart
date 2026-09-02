import 'package:biblia_flutter_app/core/app_providers.dart';
import 'package:biblia_flutter_app/core/services_initializer.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/firebase_options.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/chapter_screen.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/widgets/chapters_card.dart';
import 'package:biblia_flutter_app/screens/home_screen/home_screen.dart';
import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

/// O `main()` do app roda o runApp dentro da zone do SentryFlutter, e a árvore
/// não fica visível para o binding de teste. Aqui fazemos a mesma inicialização
/// e montamos o MyApp direto, para poder navegar de verdade pelas telas.
Future<void> bootApp(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await ServicesInitializer.initialize();
  });
  await tester.pumpWidget(MultiProvider(providers: appProviders, child: const MyApp()));
  await settle(tester, seconds: 6);
}

/// Anúncios, shimmer e flutter_animate deixam a árvore sempre animando, então
/// `pumpAndSettle` nunca retorna: avançamos em passos com tempo real.
Future<void> settle(WidgetTester tester, {int seconds = 3}) async {
  for (var i = 0; i < seconds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 600)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> goTo(WidgetTester tester, String route, {Object? args}) async {
  navigatorKey!.currentState!.pushNamed(route, arguments: args);
  await settle(tester, seconds: 5);
}

Future<void> goBack(WidgetTester tester) async {
  if (navigatorKey!.currentState!.canPop()) {
    navigatorKey!.currentState!.pop();
  }
  await settle(tester, seconds: 3);
}

/// Falha o teste se a tela atual estourou uma exceção de render.
void expectNoErrorScreen(WidgetTester tester, String tela) {
  expect(tester.takeException(), isNull, reason: 'exceção ao abrir $tela');
  expect(find.byType(ErrorWidget), findsNothing, reason: '$tela renderizou um ErrorWidget');
  expect(find.textContaining('Rota não encontrada'), findsNothing, reason: '$tela caiu na rota de erro');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('percorre as telas principais sem quebrar', (tester) async {
    await bootApp(tester);

    // ---------------- home ----------------
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'o app deveria abrir na home');
    expect(find.text('Gênesis'), findsWidgets, reason: 'a home deveria listar os livros');
    expectNoErrorScreen(tester, 'home');

    // alterna o layout da lista de livros (FAB)
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await settle(tester);
      expectNoErrorScreen(tester, 'home (layout alternativo)');
      await tester.tap(fab.first);
      await settle(tester);
    }

    // ---------------- capítulos ----------------
    // Navegamos pela rota com os mesmos argumentos que os cards da home passam;
    // o finder por texto depende do layout escolhido e é frágil demais.
    await goTo(tester, 'chapter_screen', args: <String, dynamic>{
      'bookName': 'Gênesis', 'abbrev': 'gn', 'bookIndex': 0, 'chapters': 50,
    });
    expectNoErrorScreen(tester, 'chapter_screen');
    expect(find.byType(ChapterScreen), findsOneWidget, reason: 'deveria abrir a tela de capítulos');
    expect(find.byType(ChapterCard), findsOneWidget, reason: 'a grade de capítulos deveria estar montada');

    // ---------------- versículos ----------------
    // Mesma sequência do ChapterCard: carrega os versículos no provider e
    // então abre a rota.
    final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    versesProvider.loadVerses(0, 'Gênesis');
    await goTo(tester, 'verses_screen', args: <String, dynamic>{
      'bookName': 'Gênesis', 'abbrev': 'gn', 'bookIndex': 0,
      'chapters': 50, 'chapter': 1, 'verseNumber': 1,
    });
    expectNoErrorScreen(tester, 'verses_screen');
    expect(find.byType(VersesScreen), findsOneWidget, reason: 'deveria abrir a tela de versículos');
    expect(find.textContaining('No princípio', findRichText: true), findsWidgets,
        reason: 'os versículos de Gênesis 1 deveriam aparecer');

    await goBack(tester);
    await goBack(tester);
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'deveria voltar para a home');

    // ---------------- demais rotas ----------------
    for (final rota in <String>[
      'search_screen',
      'saved_verses',
      'annotations_screen',
      'settings',
      'random_verse_screen',
      'devocionais_screen',
      'feed_screen',
      'ai_screen',
      'reading_groups_screen',
    ]) {
      await goTo(tester, rota);
      expectNoErrorScreen(tester, rota);
      await goBack(tester);
      await settle(tester, seconds: 2);
    }

    // ---------------- busca de ponta a ponta pela UI ----------------
    await goTo(tester, 'search_screen');
    final campo = find.byType(TextField);
    expect(campo, findsWidgets, reason: 'a tela de busca deveria ter um campo de texto');
    await tester.enterText(campo.first, 'No princípio');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester, seconds: 8);
    expectNoErrorScreen(tester, 'search_screen (com resultados)');
    expect(find.textContaining('Resultados'), findsWidgets,
        reason: 'a busca deveria informar a quantidade de resultados');
    await goBack(tester);

    // ---------------- tema claro/escuro ----------------
    final themeProvider = Provider.of<ThemeProvider>(navigatorKey!.currentContext!, listen: false);
    final temaInicial = themeProvider.isOn;
    themeProvider.toggleTheme();
    await settle(tester, seconds: 3);
    expect(themeProvider.isOn, isNot(temaInicial), reason: 'o tema deveria ter alternado');
    expectNoErrorScreen(tester, 'home (tema alternado)');
    themeProvider.toggleTheme();
    await settle(tester, seconds: 3);
    expect(themeProvider.isOn, temaInicial, reason: 'o tema deveria voltar ao original');

    // ---------------- tamanho da fonte ----------------
    final versesProviderFinal = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    final fonteInicial = versesProviderFinal.fontSize;
    versesProviderFinal.newFontSize(fonteInicial + 4, true);
    await settle(tester, seconds: 2);
    expect(versesProviderFinal.fontSize, fonteInicial + 4);
    versesProviderFinal.newFontSize(fonteInicial, true);
    await settle(tester, seconds: 2);

    expect(tester.takeException(), isNull, reason: 'nenhuma exceção deveria ter escapado');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
