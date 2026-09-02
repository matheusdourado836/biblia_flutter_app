

import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Indice plano de uma versao da Biblia, montado uma unica vez e reaproveitado
/// entre as buscas. Manter os textos em uma lista simples (em vez da estrutura
/// aninhada do JSON) e o que permite delegar a varredura para um isolate.
class _SearchIndex {
  final List<String> texts;

  /// bookIndex, capitulo e numero do versiculo empacotados em um unico int.
  final Int32List meta;

  const _SearchIndex(this.texts, this.meta);

  static int pack(int bookIndex, int chapter, int verseNumber) =>
      (bookIndex << 16) | (chapter << 8) | verseNumber;

  static int bookOf(int packed) => packed >> 16;

  static int chapterOf(int packed) => (packed >> 8) & 0xFF;

  static int verseOf(int packed) => packed & 0xFF;
}

class _SearchArgs {
  final List<String> texts;
  final Int32List meta;
  final String query;
  final bool preciseSearch;
  final int startBook;
  final int endBookExclusive;

  const _SearchArgs({
    required this.texts,
    required this.meta,
    required this.query,
    required this.preciseSearch,
    required this.startBook,
    required this.endBookExclusive,
  });
}

String _normalizeText(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[^\w\s]'), '') // Remove pontuacoes
    .replaceAll(RegExp(r'\s+'), ' ') // Substitui multiplos espacos por um so
    .trim();

bool _matchesPreciseSearch(String verse, List<String> queryWords) {
  final verseWords = _normalizeText(verse).split(' ');

  if (queryWords.length == 1) {
    return verseWords.contains(queryWords.first);
  }

  for (int i = 0; i <= verseWords.length - queryWords.length; i++) {
    if (listEquals(verseWords.sublist(i, i + queryWords.length), queryWords)) {
      return true;
    }
  }
  return false;
}

/// Executada em um isolate (`compute`). Devolve pares [indice, posicaoDoMatch].
/// posicaoDoMatch vem -1 quando o trecho so casa apos a normalizacao, caso em
/// que a UI renderiza o versiculo sem destaque em vez de quebrar.
List<int> _runSearch(_SearchArgs args) {
  final results = <int>[];
  final queryLower = args.query.toLowerCase();
  final queryWords = _normalizeText(args.query).split(' ');

  for (int i = 0; i < args.texts.length; i++) {
    final packed = args.meta[i];
    final bookIndex = _SearchIndex.bookOf(packed);
    if (bookIndex < args.startBook) continue;
    if (bookIndex >= args.endBookExclusive) break;

    final text = args.texts[i];
    final lower = text.toLowerCase();

    final bool match = args.preciseSearch
        ? _matchesPreciseSearch(text, queryWords)
        : lower.contains(queryLower);

    if (match) {
      results.add(i);
      results.add(lower.indexOf(queryLower));
    }
  }

  return results;
}

class SearchVersesProvider extends ChangeNotifier {
  static final BibleData bibleData = BibleData();

  /// Usado por `searching_verse.dart` (busca dentro de um capitulo aberto).
  List<TextSpan> highlightedWords = [];

  final Map<String, _SearchIndex> _indexCache = {};

  bool _searching = false;

  bool get searching => _searching;

  int _versionIndexOf(String versionName) {
    final formatted = versionToName(versionName);
    final index = bibleData.data.indexWhere((b) => b["version"] == formatted);

    return index == -1 ? 0 : index;
  }

  _SearchIndex _indexFor(int versionIndex) {
    final version = bibleData.data[versionIndex]["version"] as String;

    // Descarta índices de versões que o usuário apagou em "gerenciar downloads";
    // sem isso eles ficavam em memória para sempre.
    _indexCache.removeWhere((cached, _) => !bibleData.isLoaded(cached));

    final cached = _indexCache[version];
    if (cached != null) return cached;

    final texts = <String>[];
    final meta = <int>[];
    final books = bibleData.data[versionIndex]["text"] as List<dynamic>;

    for (int bookIndex = 0; bookIndex < books.length; bookIndex++) {
      final chapters = books[bookIndex]['chapters'] as List<dynamic>;
      for (int chapter = 0; chapter < chapters.length; chapter++) {
        final verses = chapters[chapter] as List<dynamic>;
        for (int verse = 0; verse < verses.length; verse++) {
          // Mantem a divisao por ';' usada historicamente pela tela de busca.
          for (final segment in verses[verse].toString().split(';')) {
            final trimmed = segment.trim();
            if (trimmed.isEmpty) continue;
            texts.add(trimmed);
            meta.add(_SearchIndex.pack(bookIndex, chapter + 1, verse + 1));
          }
        }
      }
    }

    final index = _SearchIndex(texts, Int32List.fromList(meta));
    _indexCache[version] = index;

    return index;
  }

  /// Busca versiculos fora da thread de UI.
  ///
  /// [versionName] e o rotulo escolhido no seletor de versao (ex.: "NVI (Nova
  /// Versao Internacional)"); a resolucao para o arquivo correto passa por
  /// `versionToName`, e nao mais pela posicao na lista de opcoes.
  Future<List<Map<String, dynamic>>> searchVerses(
    String query,
    String versionName, {
    String findIn = 'toda a biblia',
    int findInBookIndex = -1,
    bool preciseSearch = false,
  }) async {
    int startBook = 0, endBookExclusive = 66;

    switch (findIn) {
      case 'antigo testamento':
        endBookExclusive = 39;
        break;
      case 'novo testamento':
        startBook = 39;
        break;
    }

    if (findInBookIndex != -1) {
      startBook = findInBookIndex;
      endBookExclusive = findInBookIndex + 1;
    }

    final versionIndex = _versionIndexOf(versionName);
    final index = _indexFor(versionIndex);
    final books = bibleData.data[versionIndex]["text"] as List<dynamic>;

    _searching = true;
    notifyListeners();

    final List<int> raw;
    try {
      raw = await compute(
        _runSearch,
        _SearchArgs(
          texts: index.texts,
          meta: index.meta,
          query: query,
          preciseSearch: preciseSearch,
          startBook: startBook,
          endBookExclusive: endBookExclusive,
        ),
      );
    } finally {
      _searching = false;
    }

    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < raw.length; i += 2) {
      final position = raw[i];
      final matchStart = raw[i + 1];
      final packed = index.meta[position];
      final bookIndex = _SearchIndex.bookOf(packed);
      final bookData = books[bookIndex];

      results.add({
        'book': bookData['name'],
        'abbrev': bookData['abbrev'],
        'qtdChapters': (bookData['chapters'] as List<dynamic>).length,
        'chapter': _SearchIndex.chapterOf(packed),
        'bookIndex': bookIndex,
        'verse': index.texts[position],
        'verseNumber': _SearchIndex.verseOf(packed),
        'matchStart': matchStart,
        'matchLength': query.length,
      });
    }

    notifyListeners();

    return results;
  }

  /// Monta os trechos destacados apenas para o item que esta sendo desenhado.
  /// Antes isso era feito para todos os resultados de uma vez, o que criava
  /// dezenas de milhares de `TextSpan` a cada busca.
  List<TextSpan> buildHighlightedSpans(
    Map<String, dynamic> result, {
    required TextStyle? baseStyle,
    TextStyle? highlightStyle,
  }) {
    final String verse = result['verse'];
    final int start = result['matchStart'] ?? -1;
    final int length = result['matchLength'] ?? 0;

    if (start < 0 || length <= 0 || start + length > verse.length) {
      return [TextSpan(text: verse, style: baseStyle)];
    }

    return [
      if (start > 0) TextSpan(text: verse.substring(0, start), style: baseStyle),
      TextSpan(
        text: verse.substring(start, start + length),
        style: (highlightStyle ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
      if (start + length < verse.length)
        TextSpan(text: verse.substring(start + length), style: baseStyle),
    ];
  }

  void changeColorOfMatchedWord(String query, String verse, {bool textOnColoredBackground = false}) {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      highlightedWords = [TextSpan(text: verse)];
      return;
    }
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    final baseStyle = (textOnColoredBackground)
        ? const TextStyle(color: Colors.black)
        : Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: versesProvider.fontSize);

    final index = verse.toLowerCase().indexOf(query.toLowerCase());

    // Sem correspondencia literal (acontece na busca precisa, que compara o
    // texto normalizado): devolve o versiculo inteiro em vez de estourar.
    if (index < 0 || query.isEmpty) {
      highlightedWords = [TextSpan(text: verse, style: baseStyle)];
      return;
    }

    final highlightStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: versesProvider.fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.redAccent,
    );

    final spans = <TextSpan>[];
    int cursor = 0;
    final lowerVerse = verse.toLowerCase();
    final lowerQuery = query.toLowerCase();

    while (true) {
      final match = lowerVerse.indexOf(lowerQuery, cursor);
      if (match < 0) break;
      if (match > cursor) {
        spans.add(TextSpan(text: verse.substring(cursor, match), style: baseStyle));
      }
      spans.add(TextSpan(
        text: verse.substring(match, match + lowerQuery.length),
        style: highlightStyle,
      ));
      cursor = match + lowerQuery.length;
    }

    if (cursor < verse.length) {
      spans.add(TextSpan(text: verse.substring(cursor), style: baseStyle));
    }

    highlightedWords = spans;
  }

  void share(String bookName, String verse, int chapter, int verseNumber) {
    SharePlus.instance.share(
      ShareParams(text: '$bookName $chapter:$verseNumber $verse'),
    );
  }

  void copyText(String bookName, String verse, int chapter, int verseNumber) {
    Clipboard.setData(ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }
}
